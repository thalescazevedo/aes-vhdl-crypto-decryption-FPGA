library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AES_pack.all;
use work.roms_package.all;

entity AES_BO_CRIPTOGRAFIA is
    port(
        -- BO geral--
        clk         : in  std_logic;     -- clk
        rst_a       : in  std_logic;     -- reset assíncrono
        user_key    : in  std_logic_vector(255 downto 0); 
        user_text   : in  std_logic_vector(127 downto 0); 
        cipher_text : out std_logic_vector(127 downto 0);  
        allRoundKeys: in  allKeys;
        -- bloco de controle --
        round_counter   : in std_logic_vector(3 downto 0);
        rp              : in std_logic;      
        ilr             : in std_logic;      
        i0              : in std_logic       
    );
end entity AES_BO_CRIPTOGRAFIA;

architecture behavior of AES_BO_CRIPTOGRAFIA is
    signal round0_cipher                    : matriz_4x4;
    signal partial_cipher                   : matriz_4x4;
    signal partial_cipher_subbytes          : matriz_4x4;
    signal partial_cipher_shiftrows         : matriz_4x4;
    signal partial_cipher_mixcolumns        : matriz_4x4;
    signal in_partial_cipher_addroundkey    : matriz_4x4;
    signal round_partial_cipher             : matriz_4x4;
    signal partial_cipher_addroundkey       : matriz_4x4;
    signal atual_round_key                  : matriz_4x4;
    signal primeiraWord                     : integer := 0;
    signal currentRoundInteger              : integer := 0;

begin

    -- Primeiro passo: Colocar a primeira chave da rodada fazendo um xor entre user key e user text.
    round0_cipher <= vetor128bits_to_matriz_4x4(user_key(255 downto 128) xor user_text);

    SB: entity work.subBytes(behavior)
        port map (  in_matriz       => partial_cipher,
                    out_matriz      => partial_cipher_subbytes
        );
    
    SR: entity work.shiftrows(behavior)
        port map (  in_matriz       => partial_cipher_subbytes,
                    out_matriz      => partial_cipher_shiftrows
        );

    MC: entity work.mixColumns(behavior)
        port map (  in_matriz       => partial_cipher_shiftrows,
                    out_matriz      => partial_cipher_mixcolumns
        );

    M1: entity work.mux2x1(behavior) -- determina se pega o resultado pulando ou nao o mixColumns. so pula na ultima rodada, por isso o signal ILR - is last round
        port map (  sel         => ilr,
                    in_0        => partial_cipher_mixcolumns,
                    in_1        => partial_cipher_shiftrows,
                    y           => in_partial_cipher_addroundkey
        );


    --------------------------------------------------------------------
    --          selecionando apenas a chave da rodada                 --
    --------------------------------------------------------------------

    currentRoundInteger <= to_integer(unsigned(round_counter));
    primeiraWord        <= currentRoundInteger*4;

    process(allRoundKeys, primeiraWord)
        variable temp_matriz : matriz_4x4;
        variable idx : integer;
    begin
        idx := primeiraWord;
        if idx < 0 or idx > 56 then  
            idx := 0;
        end if;

        temp_matriz := setWord(temp_matriz, 0, allRoundKeys(idx));
        temp_matriz := setWord(temp_matriz, 1, allRoundKeys(idx+1));
        temp_matriz := setWord(temp_matriz, 2, allRoundKeys(idx+2));
        temp_matriz := setWord(temp_matriz, 3, allRoundKeys(idx+3));

        atual_round_key <= temp_matriz;
    end process;

    ARK: entity work.addRoundKey(behavior)
        port map (  in_matriz       => in_partial_cipher_addroundkey,
                    keySchedule     => atual_round_key, -- mexi aqui
                    out_matriz      => partial_cipher_addroundkey
        );
    

    ---------------- finalizacao da rodada ----------------------------

    M0: entity work.mux2x1(behavior) -- Esse mux determina se o processo vai advir da rodada 0 ou de qqr outra
        port map (  sel         => i0,
                    in_0        => partial_cipher_addroundkey,
                    in_1        => round0_cipher,
                    y           => round_partial_cipher
        );

    RN: entity work.matriz4x4_register(behavior) -- registrae a saida do M0.
        port map (  clk     => clk,
                    rst_a   => rst_a,
                    enable  => rp,
                    d       => round_partial_cipher,
                    q       => partial_cipher
        );

    cipher_text <= matriz_4x4_to_128bits(partial_cipher);

end architecture behavior;