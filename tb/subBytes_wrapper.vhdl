library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AES_PACK.all;
use work.roms_package.all;

-- Wrapper entity para encapsular o subBytes
entity subBytes_wrapper is
    port(
        in_data  : in  std_logic_vector(127 downto 0);
        out_data : out std_logic_vector(127 downto 0)
    );
end entity subBytes_wrapper;

architecture behavioral of subBytes_wrapper is
    signal matriz_in  : matriz_4x4;
    signal matriz_out : matriz_4x4;
begin
    matriz_in <= vetor128bits_to_matriz_4x4(in_data);
    
    uut: entity work.subBytes
        port map(
            in_matriz  => matriz_in,
            out_matriz => matriz_out
        );
    
    out_data <= matriz_4x4_to_128bits(matriz_out);
end architecture behavioral;

