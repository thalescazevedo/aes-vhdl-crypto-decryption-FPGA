library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AES_pack.all;

entity n256bits_register is

	port(
		clk, enable : in  std_logic;  -- clock (clk) e carga (enable)
		rst_a       : in  std_logic;  -- reset assíncrono
		d           : in  std_logic_vector(255 downto 0); -- dado de entrada
		q           : out std_logic_vector(255 downto 0)  -- dado armazenado
	);
end entity n256bits_register;

architecture behavior OF n256bits_register is
    signal salvar : std_logic_vector(255 downto 0) := (others => '0'); 
begin
     process(clk, rst_a)
        BEGIN
            IF (rst_a = '1') THEN
                salvar <= (others => '0');
            ELSIF (rising_edge(clk)) THEN
                IF (enable = '1') THEN
                    salvar <= d;
                END IF;
            END IF; 
    END PROCESS;

    q <= salvar;
    
end architecture behavior;