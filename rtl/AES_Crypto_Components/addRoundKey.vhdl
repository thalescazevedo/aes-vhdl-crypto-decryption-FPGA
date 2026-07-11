library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AES_pack.all;
-- não mexa na declaracao da entidade!!!!!
entity addRoundKey is

	port(
        in_matriz         : in      matriz_4x4;
        keySchedule       : in      matriz_4x4;
        out_matriz        : out     matriz_4x4
	);
end entity addRoundKey;

architecture behavior of addRoundKey is

begin
    ------------------------------------------------------------
    -- XOR do add round key
    ------------------------------------------------------------

	-- coluna 0
	out_matriz(0, 0) <= in_matriz(0, 0) xor keySchedule(0, 0);
    out_matriz(1, 0) <= in_matriz(1, 0) xor keySchedule(1, 0);
    out_matriz(2, 0) <= in_matriz(2, 0) xor keySchedule(2, 0);
    out_matriz(3, 0) <= in_matriz(3, 0) xor keySchedule(3, 0);
	-- coluna 1
	out_matriz(0, 1) <= in_matriz(0, 1) xor keySchedule(0, 1);
    out_matriz(1, 1) <= in_matriz(1, 1) xor keySchedule(1, 1);
    out_matriz(2, 1) <= in_matriz(2, 1) xor keySchedule(2, 1);
    out_matriz(3, 1) <= in_matriz(3, 1) xor keySchedule(3, 1);
	-- coluna 2
	out_matriz(0, 2) <= in_matriz(0, 2) xor keySchedule(0, 2);
    out_matriz(1, 2) <= in_matriz(1, 2) xor keySchedule(1, 2);
    out_matriz(2, 2) <= in_matriz(2, 2) xor keySchedule(2, 2);
    out_matriz(3, 2) <= in_matriz(3, 2) xor keySchedule(3, 2);
	--coluna 3
	out_matriz(0, 3) <= in_matriz(0, 3) xor keySchedule(0, 3);
    out_matriz(1, 3) <= in_matriz(1, 3) xor keySchedule(1, 3);
    out_matriz(2, 3) <= in_matriz(2, 3) xor keySchedule(2, 3);
    out_matriz(3, 3) <= in_matriz(3, 3) xor keySchedule(3, 3);


end architecture behavior; 
