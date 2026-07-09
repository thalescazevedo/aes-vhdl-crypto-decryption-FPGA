library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AES_pack.all;
use work.roms_package.all;

entity AES_BO_KEYEXPANSION is
    port(
  
        clk             : in  std_logic;
        rst_a           : in  std_logic;
        
        init            : in  std_logic; 
        read_memory     : in  std_logic; 
        i0              : in  std_logic; 
        rcon_idx        : in  integer range 1 to 10; 
        R_WORD          : in  std_logic;
        
        user_key        : in  std_logic_vector(255 downto 0);  
        aes_type        : in  std_logic_vector(1 downto 0);
        keyWord         : in  Integer;
        
        allRoundKeysOut : out allKeys
    );
end entity AES_BO_KEYEXPANSION;

architecture behavior of AES_BO_KEYEXPANSION is

    signal keys              :      allkeys;
    signal rcon_w            :      word;
    signal flagmod0          :      std_logic;
    signal flagmod4          :      std_logic;
    signal temp              :      word;
    signal temp_KE           :      word;
    signal temp_KE_2         :      word;
    signal temp_KE_EXP1      :      word;
    signal temp_KE_EXP1_reg  :      word;
    signal temp_KE_EXP2      :      word;
    signal temp_KE_EXP2_2    :      word;
    signal temp_KE_EXP3      :      word;
    signal flagsor           :      std_logic;
    signal finaltemp         :      word;

BEGIN

    flagmod0 <= is_mod_nk(keyWord, aes_type);
    flagmod4 <= is_aes256_mod_4(keyWord, aes_type);

    rcon_w(0) <= RCON(rcon_idx) when flagmod0 = '1' else x"00";
    rcon_w(1) <= x"00";
    rcon_w(2) <= x"00";
    rcon_w(3) <= x"00";

    temp_KE <= keys(keyWord - 1) when keyWord > 0 else keys(0);
    temp_KE_2 <= rotWord(temp_KE);


    -- tratando o dado --
    -- esse mux define se o que entra no SubWord é com ou sem rotword
    MKS4: entity work.mux2x1_word
        port map(   sel         => flagmod4,
                    in_0        => temp_KE_2,         -- temp = keys(i-nk)
                    in_1        => temp_KE,       -- temp = rotWord(temp)
                    y           => temp_KE_EXP1
        );

    SUB_WORD: entity work.subWord
        port map(
            clk           => clk, 
            read_memory   => read_memory, -- SINAL DE ATIVAÇAO QUE ESTA NO ESTADO KE_EXP2
            word_in       => temp_KE_EXP1,
            word_out      => temp_KE_EXP2
        );

    temp_KE_EXP2_2 <= xorWord(temp_KE_EXP2, rcon_w);

    -- esse mux vai definir se o proximo xorword vai ser com ou sem o xor da rcon
    MKS: entity work.mux2x1_word
        port map(   sel         => flagmod4,
                    in_0        => temp_KE_EXP2_2,
                    in_1        => temp_KE_EXP2,
                    y           => temp_KE_EXP3
        );

------------------------- define se o xor final é com dado tratado ou original -------------
    flagsor <= flagmod0 or flagmod4;

    MKSF: entity work.mux2x1_word                   
        port map(   sel         => flagsor,
                    in_0        => temp_KE,
                    in_1        => temp_KE_EXP3,
                    y           => temp
        );

-- sempre acontece e esta correto
    finaltemp <= xorWord(keys(keyWord - get_nk(aes_type)), temp) 
            when keyWord >= get_nk(aes_type) else keys(0);

    REGI: entity work.keys_register(behavior)
        port map(   clk         => clk, 
                    rst_a       => rst_a, 
		            init        => init,
                    enable      => R_WORD,
                    user_key    => user_key,
                    aes_type    => aes_type,
                    address     => keyWord,
                    word_in     => finaltemp,
		            q           => keys   
        );

    allRoundKeysOut <= keys;

end behavior;