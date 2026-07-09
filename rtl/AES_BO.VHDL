library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AES_pack.all;

entity AES_BO is
    port(
        -- toplevel--
        clk         : in  std_logic;     -- clk
        rst_a       : in  std_logic;     -- reset assíncrono
        user_key    : in  std_logic_vector(255 downto 0); 
        user_text   : in  std_logic_vector(127 downto 0); 
        cipher_text : out std_logic_vector(127 downto 0);  
        aes_type    : in  std_logic_vector(1 downto 0);

        -- bloco de controle --
        round_counter   : in std_logic_vector(3 downto 0);
        rp              : in std_logic;      
        ilr             : in std_logic;      
        i0              : in std_logic       
    );
end entity AES_BO;

architecture behavior of AES_BO is

    signal allRoundKeys : allkeys;

BEGIN

    CHAVE: entity work.AES_BO_KEYEXPANSION(behavior)
        port map(           
            clk             => clk,      
            rst_a           => rst_a,
            user_key        => user_key,  
            aes_type        => aes_type,
            i0              => i0,  
            allRoundKeysOut => allRoundKeys            
        );


    CRIPTO: entity work.AES_BO_CRIPTOGRAFIA(behavior)
        port map(
            clk             => clk,      
            rst_a           => rst_a,
            user_key        => user_key,  
            user_text       => user_text,
            cipher_text     => cipher_text,
            allRoundKeys    => allRoundKeys,
            round_counter   => round_counter,
            rp              => rp, 
            ilr             => ilr,
            i0              => i0
        );


END behavior;