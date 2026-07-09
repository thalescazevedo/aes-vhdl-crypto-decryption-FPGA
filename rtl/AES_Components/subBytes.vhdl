library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AES_pack.all;
use work.roms_package.all; -- já está importando o pacote de roms
-- não mexa na declaracao da entidade!!!!!
entity subBytes is

	port(
        in_matriz  : in  matriz_4x4;
        out_matriz : out  matriz_4x4
	);
end entity subBytes;

architecture behavior of subBytes is

begin

        gen_subBytes_linhas: for i in 0 to 3 generate
        begin
                gen_subBytes_colunas: for j in 0 to 3 generate
                begin
                        out_matriz(i,j) <= SBOX(to_integer(unsigned(in_matriz(i, j))));
                end generate gen_subBytes_colunas;
        end generate gen_subBytes_linhas;

end architecture behavior; 
