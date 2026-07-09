library ieee;
use ieee.std_logic_1164.all;
use work.AES_pack.all;

entity mux2x1_stdlogic is
    generic(
		N : positive -- número de bits das entradas e da saída
	);
	port(
		sel        : in  std_logic;                                             -- sinal de seleção
		in_0, in_1 : in  std_logic_vector(N-1 downto 0);                        -- entradas do mux
		y          : out std_logic_vector(N-1 downto 0)                         -- saída do mux
	);
end mux2x1_stdlogic;

architecture behavior of mux2x1_stdlogic is

begin
    y <= in_0 when (sel = '0') else in_1;
end architecture behavior;