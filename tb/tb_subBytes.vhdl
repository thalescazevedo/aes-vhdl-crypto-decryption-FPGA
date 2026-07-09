library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AES_PACK.all;
use work.roms_package.all;

entity tb_subBytes is
end entity tb_subBytes;

architecture tb of tb_subBytes is

    -- Sinais padronizados (1D) para conectar ao wrapper sintetizado
    signal input_vector  : std_logic_vector(127 downto 0) := (others => '0');
    signal output_vector : std_logic_vector(127 downto 0);
    
    -- Sinal de matriz apenas para facilitar a verificação matemática no testbench
    signal matriz_out_tb : matriz_4x4; 

begin

    -- Instancia o Wrapper (que será o alvo da sua síntese e simulação gate-level)
    DUV: entity work.subBytes_wrapper
        port map(
            in_data  => input_vector,
            out_data => output_vector
        );

    -- Transforma a saída achatada de volta para matriz apenas para facilitar os asserts
    matriz_out_tb <= vetor128bits_to_matriz_4x4(std_logic_vector(output_vector));

    process
        variable base: integer;
        variable valor: integer;
        variable matriz_in_tb : matriz_4x4;
    begin
        for bloco in 0 to 15 loop

            base := bloco * 16;

            -- Preenche a matriz temporária com os valores de teste
            for i in 0 to 3 loop
                for j in 0 to 3 loop
                    valor := base + i*4 + j;
                    matriz_in_tb(i,j) := std_logic_vector(to_unsigned(valor,8));
                end loop;
            end loop;
            
            -- Aplica a conversão de matriz para vetor e injeta na porta do DUV
            input_vector <= matriz_4x4_to_128bits(matriz_in_tb);
            
            wait for 10 ns;

            ----------------------------------------------------------------
            -- Verifica a saída usando a matriz espelhada do testbench
            ----------------------------------------------------------------
            for i in 0 to 3 loop
                for j in 0 to 3 loop

                    valor := base + i*4 + j;

                    assert matriz_out_tb(i,j) = SBOX(valor)
                    report "Erro para valor decimal: " & integer'image(valor)
                    severity error;

                end loop;
            end loop;

            report "Bloco " & integer'image(bloco) & " aprovado";

        end loop;

        report "TODOS OS 256 TESTES PASSARAM";
        wait;

    end process;
end architecture tb;