library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AES_pack.all;

entity invMixColumns is
    port(
        in_matriz  : in  matriz_4x4;
        out_matriz : out matriz_4x4
    );
end entity invMixColumns;

architecture behavior of invMixColumns is
begin

    process(in_matriz)
        variable b0, b1, b2, b3 : std_logic_vector(7 downto 0);
        
        -- Variáveis auxiliares para multiplicações por 2, 4 e 8
        variable x2_0, x4_0, x8_0 : std_logic_vector(7 downto 0);
        variable x2_1, x4_1, x8_1 : std_logic_vector(7 downto 0);
        variable x2_2, x4_2, x8_2 : std_logic_vector(7 downto 0);
        variable x2_3, x4_3, x8_3 : std_logic_vector(7 downto 0);
    begin
        for j in 0 to 3 loop
            -- 1. Leitura da coluna e cálculo instantâneo das multiplicações usando o seu xtime
            b0 := in_matriz(0, j); x2_0 := xtime(b0); x4_0 := xtime(x2_0); x8_0 := xtime(x4_0);
            b1 := in_matriz(1, j); x2_1 := xtime(b1); x4_1 := xtime(x2_1); x8_1 := xtime(x4_1);
            b2 := in_matriz(2, j); x2_2 := xtime(b2); x4_2 := xtime(x2_2); x8_2 := xtime(x4_2);
            b3 := in_matriz(3, j); x2_3 := xtime(b3); x4_3 := xtime(x2_3); x8_3 := xtime(x4_3);

            -- 2. Montagem direta baseada na matriz inversa:
            -- 0E = x8^x4^x2  |  0B = x8^x2^x  |  0D = x8^x4^x  |  09 = x8^x
            out_matriz(0, j) <= (x8_0 xor x4_0 xor x2_0) xor (x8_1 xor x2_1 xor b1) xor (x8_2 xor x4_2 xor b2) xor (x8_3 xor b3);
            out_matriz(1, j) <= (x8_0 xor b0) xor (x8_1 xor x4_1 xor x2_1) xor (x8_2 xor x2_2 xor b2) xor (x8_3 xor x4_3 xor b3);
            out_matriz(2, j) <= (x8_0 xor x4_0 xor b0) xor (x8_1 xor b1) xor (x8_2 xor x4_2 xor x2_2) xor (x8_3 xor x2_3 xor b3);
            out_matriz(3, j) <= (x8_0 xor x2_0 xor b0) xor (x8_1 xor x4_1 xor b1) xor (x8_2 xor b2) xor (x8_3 xor x4_3 xor x2_3);
        end loop;
    end process;

end architecture behavior;