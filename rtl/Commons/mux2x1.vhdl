library ieee;
use ieee.std_logic_1164.all;
use work.AES_pack.all;

entity mux2x1 is
	port(
		sel        : in  std_logic;                         -- sinal de seleção
		in_0, in_1 : in  matriz_4x4;                        -- entradas do mux
		y          : out matriz_4x4                         -- saída do mux
	);
end mux2x1;

architecture behavior of mux2x1 is

begin
    y <= in_0 when (sel = '0') else in_1;
end architecture behavior;