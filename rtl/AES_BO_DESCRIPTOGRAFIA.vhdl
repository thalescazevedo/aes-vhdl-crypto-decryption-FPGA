library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AES_pack.all;
use work.roms_package.all;

entity AES_BO_DESCRIPTOGRAFIA is
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
        i0              : in std_logic;
        s_invsubbytes   : in std_logic     
    );
end entity AES_BO_DESCRIPTOGRAFIA;

architecture behavior of AES_BO_DESCRIPTOGRAFIA is

    signal inv_currentRoundInteger : integer := 0;
    signal inv_primeiraWord        : integer := 0;

    signal in_user_text_matriz             : matriz_4x4;
    signal partial_decypher                : matriz_4x4;
    signal partial_decypher_subbytes       : matriz_4x4;
    signal partial_decypher_shiftrows      : matriz_4x4;
    signal in_partial_decypher_addroundkey : matriz_4x4;
    signal partial_decypher_addroundkey    : matriz_4x4;
    signal partial_decypher_mixcolumns     : matriz_4x4;
    signal partial_decypher_invMC_or_no    : matriz_4x4;
    signal atual_round_key                 : matriz_4x4;
    
    signal i0orilr                         : std_logic;

    begin

    in_user_text_matriz <= vetor128bits_to_matriz_4x4(user_text);
    i0orilr <= i0 or ilr;
    --------------------------------------------------------------------
    --          selecionando apenas a chave da rodada                 --
    --------------------------------------------------------------------

    inv_currentRoundInteger <= to_integer(unsigned(round_counter));
    inv_primeiraWord        <= (inv_currentRoundInteger*4)-4;

    process(allRoundKeys, inv_primeiraWord)
        variable temp_matriz : matriz_4x4;
        variable idx : integer;
    begin
        idx := inv_primeiraWord;
        if idx < 0 or idx > 56 then  
            idx := 0;
        end if;

        temp_matriz := setWord(temp_matriz, 0, allRoundKeys(idx));
        temp_matriz := setWord(temp_matriz, 1, allRoundKeys(idx+1));
        temp_matriz := setWord(temp_matriz, 2, allRoundKeys(idx+2));
        temp_matriz := setWord(temp_matriz, 3, allRoundKeys(idx+3));

        atual_round_key <= temp_matriz;
    end process;


------------------------------------------------------------------------
------------------------------------------------------------------------


    SB: entity work.invsubBytes(behavior)
        port map (  clk                     => clk,
                    read_ram_inverse_sbox   => s_invsubbytes,
                    in_matriz               => partial_decypher,
                    out_matriz              => partial_decypher_subbytes
        );
    
    SR: entity work.invshiftrows(behavior)
        port map (  in_matriz       => partial_decypher_subbytes,
                    out_matriz      => partial_decypher_shiftrows
        );

    M0: entity work.mux2x1(behavior) -- determina se  manda pro add round key rodada 15 crua ou trabalhada do seletor sr
        port map (  sel         => i0,
                    in_0        => partial_decypher_shiftrows,
                    in_1        => in_user_text_matriz,
                    y           => in_partial_decypher_addroundkey
        );


    ARK: entity work.addRoundKey(behavior)
        port map (  in_matriz       => in_partial_decypher_addroundkey,
                    keySchedule     => atual_round_key, -- mexi aqui
                    out_matriz      => partial_decypher_addroundkey
        );


    MC: entity work.invmixColumns(behavior)
        port map (  in_matriz       => partial_decypher_addroundkey,
                    out_matriz      => partial_decypher_mixcolumns
        );

    M1: entity work.mux2x1(behavior) -- determina se pega o resultado pulando ou nao o mixColumns. so pula na ultima rodada, por isso o signal ILR - is last round
        port map (  sel         => i0orilr,
                    in_0        => partial_decypher_mixcolumns,
                    in_1        => partial_decypher_addroundkey,
                    y           => partial_decypher_invMC_or_no
        );


    RN: entity work.matriz4x4_register(behavior) -- registrae a saida do M1.
        port map (  clk     => clk,
                    rst_a   => rst_a,
                    enable  => rp,
                    d       => partial_decypher_invMC_or_no,
                    q       => partial_decypher
        );

    cipher_text <= matriz_4x4_to_128bits(partial_decypher);

    end behavior;