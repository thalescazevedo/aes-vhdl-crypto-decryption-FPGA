library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.roms_package.all;

entity sbox_memory_dualport is
    port(
		clk, read_ram_sbox   : in  std_logic;
        -- Porta A
        addr_a : in  std_logic_vector(7 downto 0);
        dout_a : out std_logic_vector(7 downto 0);
        -- Porta B
        addr_b : in  std_logic_vector(7 downto 0);
        dout_b : out std_logic_vector(7 downto 0)
	);
end sbox_memory_dualport;


architecture behavior of sbox_memory_dualport is

    signal ram_sbox : sbox_type := SBOX;
    
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if read_ram_sbox = '1' then
                dout_a <= ram_sbox(to_integer(unsigned(addr_a)));
                dout_b <= ram_sbox(to_integer(unsigned(addr_b)));
            end if;
        end if;
    end process;
    
end architecture behavior;


