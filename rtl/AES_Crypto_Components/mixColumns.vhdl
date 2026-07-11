library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AES_pack.all;

-- não mexa na declaracao da entidade!!!!!
entity mixColumns is
	port(
        in_matriz  : in  matriz_4x4;
        out_matriz : out  matriz_4x4
	);
end entity mixColumns;

architecture behavior of mixColumns is
begin

    process(in_matriz)
        variable b0, b1, b2, b3 : std_logic_vector(7 downto 0);
    begin
        for j in 0 to 3 loop
            b0 := in_matriz(0, j);
            b1 := in_matriz(1, j);
            b2 := in_matriz(2, j);
            b3 := in_matriz(3, j);
            out_matriz(0, j) <= xtime(b0) xor (xtime(b1) xor b1) xor b2 xor b3;
            out_matriz(1, j) <= b0 xor xtime(b1) xor (xtime(b2) xor b2) xor b3;
            out_matriz(2, j) <= b0 xor b1 xor xtime(b2) xor (xtime(b3) xor b3);
            out_matriz(3, j) <= (xtime(b0) xor b0) xor b1 xor b2 xor xtime(b3);
        end loop;
    end process;

end architecture behavior;
