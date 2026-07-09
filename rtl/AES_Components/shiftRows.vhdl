library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AES_pack.all;
-- não mexa na declaracao da entidade!!!!!
entity shiftRows is

	port(
        in_matriz  : in  matriz_4x4;
        out_matriz : out  matriz_4x4
	);
end entity shiftRows;

architecture behavior of shiftRows is

begin
    -- LINHA 0: Deslocamento de 0 bytes

	out_matriz(0, 0) <= in_matriz(0, 0);
    out_matriz(0, 1) <= in_matriz(0, 1);
    out_matriz(0, 2) <= in_matriz(0, 2);
    out_matriz(0, 3) <= in_matriz(0, 3);
-- LINHA 1: Deslocamento de 1 byte para a esquerda
    out_matriz(1, 0) <= in_matriz(1, 1);
    out_matriz(1, 1) <= in_matriz(1, 2);
    out_matriz(1, 2) <= in_matriz(1, 3);
    out_matriz(1, 3) <= in_matriz(1, 0);
-- LINHA 2: Deslocamento de 2 bytes para a esquerda
    out_matriz(2, 0) <= in_matriz(2, 2);
    out_matriz(2, 1) <= in_matriz(2, 3);
    out_matriz(2, 2) <= in_matriz(2, 0);
    out_matriz(2, 3) <= in_matriz(2, 1);
-- LINHA 3: Deslocamento de 3 bytes para a esquerda
    out_matriz(3, 0) <= in_matriz(3, 3);
    out_matriz(3, 1) <= in_matriz(3, 0);
    out_matriz(3, 2) <= in_matriz(3, 1);
    out_matriz(3, 3) <= in_matriz(3, 2);




end architecture behavior; 
