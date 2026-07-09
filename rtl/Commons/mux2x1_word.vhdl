library ieee;
use ieee.std_logic_1164.all;
use work.AES_pack.all;

entity mux2x1_word is
	port(
		sel        : in  std_logic;                         -- sinal de seleção
		in_0, in_1 : in  word;                        		-- entradas do mux
		y          : out word                         	-- saída do mux
	);
end mux2x1_word;

architecture behavior of mux2x1_word is

begin
    y <= in_0 when (sel = '0') else in_1;
end architecture behavior;