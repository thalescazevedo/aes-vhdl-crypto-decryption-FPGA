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
        i0              : in std_logic       
    );
end entity AES_BO_DESCRIPTOGRAFIA;