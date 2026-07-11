library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AES_pack.all;

entity AES_BO is
    port(
        -- Sinais de top-level
        clk          : in  std_logic;
        rst_a        : in  std_logic;
        op           : in  std_logic;
        user_key     : in  std_logic_vector(255 downto 0);
        user_text    : in  std_logic_vector(127 downto 0);
        aes_type     : in  std_logic_vector(1 downto 0);
        cipher_text  : out std_logic_vector(127 downto 0);
        -- Sinais de controle vindos do AES_BC
        init          : in std_logic;
        read_memory   : in std_logic;
        round_counter : in std_logic_vector(3 downto 0);
        rp            : in std_logic;
        ilr           : in std_logic;
        i0            : in std_logic;
        R_WORD        : in std_logic;
        rcon_idx      : in integer range 1 to 10;
        keyWord       : in integer;
        s_subbytes    : in std_logic;
        s_invsubbytes : in std_logic
    );
end entity AES_BO;

architecture behavior of AES_BO is

    signal allRoundKeys : allkeys;
    signal crypto       : std_logic_vector(127 downto 0);
    signal decrypted    : std_logic_vector(127 downto 0);

BEGIN

    CHAVE: entity work.AES_BO_KEYEXPANSION(behavior)
        port map(            
            clk             => clk,      
            rst_a           => rst_a,
            init            => init,
            read_memory     => read_memory,
            i0              => i0, 
            rcon_idx        => rcon_idx,
            R_WORD          => R_WORD,
            user_key        => user_key,  
            aes_type        => aes_type,
            keyWord         => keyWord,
            allRoundKeysOut => allRoundKeys            
        );


    CRIPTO: entity work.AES_BO_CRIPTOGRAFIA(behavior)
        port map(
            clk             => clk,      
            rst_a           => rst_a,
            user_key        => user_key,  
            user_text       => user_text,
            cipher_text     => crypto,
            allRoundKeys    => allRoundKeys,
            round_counter   => round_counter,
            rp              => rp, 
            ilr             => ilr,
            i0              => i0,
            s_subbytes      => s_subbytes
        );

    DECRYPTO: entity work.AES_BO_DESCRIPTOGRAFIA(behavior)
        port map(
            clk             => clk,      
            rst_a           => rst_a,
            user_key        => user_key,  
            user_text       => user_text,
            cipher_text     => decrypted,
            allRoundKeys    => allRoundKeys,
            round_counter   => round_counter,
            rp              => rp, 
            ilr             => ilr,
            i0              => i0,
            s_invsubbytes   => s_invsubbytes
        );

    CRYPTO_OR_DECRYPTO: entity work.mux2x1_stdlogic
        generic map(
            N => 128 
        )
        port map(
            sel  => op,      
            in_0 => crypto,
            in_1 => decrypted,
            y    => cipher_text
        );

END behavior;