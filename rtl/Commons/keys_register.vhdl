library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AES_pack.all;

entity keys_register is

	port(
		clk, enable : in  std_logic;  -- clock (clk) e carga (enable)
		rst_a       : in  std_logic;  -- reset assíncrono
		d           : in  allKeys; -- dado de entrada
		q           : out allKeys  -- dado armazenado
	);
end keys_register;

architecture behavior OF keys_register is
    signal salvar : allKeys;
begin
     process(clk, rst_a)
        BEGIN
            IF (rst_a = '1') THEN
                salvar <= (others => (others => (others => '0')));
            ELSIF (rising_edge(clk)) THEN
                IF (enable = '1') THEN
                    salvar <= d;
                END IF;
            END IF; 
    END PROCESS;

    q <= salvar;
    
end architecture behavior;