library ieee;
use ieee.std_logic_1164.all;
use work.AES_pack.all;

entity invSubBytes is
    port(
        clk                     : in  std_logic;
        read_ram_inverse_sbox   : in  std_logic;
        in_matriz               : in  matriz_4x4;
        out_matriz              : out matriz_4x4
    );
end entity invSubBytes;

architecture behavior of invSubBytes is
begin

    -- Coluna 0
    INV_RAM_C0_01: entity work.inverse_sbox_memory_dualport
        port map(
            clk           => clk, 
            read_ram_inverse_sbox => read_ram_inverse_sbox,
            addr_a        => in_matriz(0,0), dout_a => out_matriz(0,0),
            addr_b        => in_matriz(1,0), dout_b => out_matriz(1,0)
        );

    INV_RAM_C0_23: entity work.inverse_sbox_memory_dualport
        port map(
            clk           => clk, 
            read_ram_inverse_sbox => read_ram_inverse_sbox,
            addr_a        => in_matriz(2,0), dout_a => out_matriz(2,0),
            addr_b        => in_matriz(3,0), dout_b => out_matriz(3,0)
        );

    -- Coluna 1
    INV_RAM_C1_01: entity work.inverse_sbox_memory_dualport
        port map(
            clk           => clk, 
            read_ram_inverse_sbox => read_ram_inverse_sbox,
            addr_a        => in_matriz(0,1), dout_a => out_matriz(0,1),
            addr_b        => in_matriz(1,1), dout_b => out_matriz(1,1)
        );

    INV_RAM_C1_23: entity work.inverse_sbox_memory_dualport
        port map(
            clk           => clk, 
            read_ram_inverse_sbox => read_ram_inverse_sbox,
            addr_a        => in_matriz(2,1), dout_a => out_matriz(2,1),
            addr_b        => in_matriz(3,1), dout_b => out_matriz(3,1)
        );

    -- Coluna 2
    INV_RAM_C2_01: entity work.inverse_sbox_memory_dualport
        port map(
            clk           => clk, 
            read_ram_inverse_sbox => read_ram_inverse_sbox,
            addr_a        => in_matriz(0,2), dout_a => out_matriz(0,2),
            addr_b        => in_matriz(1,2), dout_b => out_matriz(1,2)
        );

    INV_RAM_C2_23: entity work.inverse_sbox_memory_dualport
        port map(
            clk           => clk, 
            read_ram_inverse_sbox => read_ram_inverse_sbox,
            addr_a        => in_matriz(2,2), dout_a => out_matriz(2,2),
            addr_b        => in_matriz(3,2), dout_b => out_matriz(3,2)
        );

    -- Coluna 3
    INV_RAM_C3_01: entity work.inverse_sbox_memory_dualport
        port map(
            clk           => clk, 
            read_ram_inverse_sbox => read_ram_inverse_sbox,
            addr_a        => in_matriz(0,3), dout_a => out_matriz(0,3),
            addr_b        => in_matriz(1,3), dout_b => out_matriz(1,3)
        );

    INV_RAM_C3_23: entity work.inverse_sbox_memory_dualport
        port map(
            clk           => clk, 
            read_ram_inverse_sbox => read_ram_inverse_sbox,
            addr_a        => in_matriz(2,3), dout_a => out_matriz(2,3),
            addr_b        => in_matriz(3,3), dout_b => out_matriz(3,3)
        );

end architecture behavior;