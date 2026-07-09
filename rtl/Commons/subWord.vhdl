library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AES_pack.all;


entity subWord is

	port(
        clk             : in  std_logic;
        read_memory     : in  std_logic;
        word_in         : in  word;
        word_out        : out word
	);
end entity subWord;

architecture behavior of subWord is

    SBOX_1: entity work.sbox_memory_dualport
        port map(
            clk           => clk, 
            read_ram_sbox => read_memory,
            addr_a        => word_in(0), 
            dout_a        => word_out(0),
            addr_b        => word_in(1), 
            dout_b        => word_out(1)
        );

    SBOX_2: entity work.sbox_memory_dualport
        port map(
            clk           => clk, 
            read_ram_sbox => read_memory,
            addr_a        => word_in(2), 
            dout_a        => word_out(2),
            addr_b        => word_in(3), 
            dout_b        => word_out(3)
        );

end architecture behavior;