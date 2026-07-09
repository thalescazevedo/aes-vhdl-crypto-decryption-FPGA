library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AES_pack.all;
 
entity tb_mixColumns is
end entity tb_mixColumns;
 
architecture behavior of tb_mixColumns is
 
    component mixColumns is
        port(
            in_matriz  : in  matriz_4x4;
            out_matriz : out matriz_4x4
        );
    end component;
 
    signal in_matriz  : matriz_4x4;
    signal out_matriz : matriz_4x4;
 
begin
    mixC : mixColumns
        port map(
            in_matriz  => in_matriz,
            out_matriz => out_matriz
        );
 
    process
    begin
 
        -- =========================================================
        -- ESTÍMULOS DE ENTRADA
        -- =========================================================
        -- Entrada esperada depois do SubBytes e ShiftRows da rodada 1
        
        -- Coluna 0
        in_matriz(0, 0) <= x"D4";
        in_matriz(1, 0) <= x"BF";
        in_matriz(2, 0) <= x"5D";
        in_matriz(3, 0) <= x"30";
 
        -- Coluna 1
        in_matriz(0, 1) <= x"E0";
        in_matriz(1, 1) <= x"B4";
        in_matriz(2, 1) <= x"52";
        in_matriz(3, 1) <= x"AE";
 
        -- Coluna 2
        in_matriz(0, 2) <= x"B8";
        in_matriz(1, 2) <= x"41";
        in_matriz(2, 2) <= x"11";
        in_matriz(3, 2) <= x"F1";
 
        -- Coluna 3
        in_matriz(0, 3) <= x"1E";
        in_matriz(1, 3) <= x"27";
        in_matriz(2, 3) <= x"98";
        in_matriz(3, 3) <= x"E5";
 
        -- Aguarda o tempo necessário para o processamento combinacional/sequencial
        wait for 20 ns;
 
        -- =========================================================
        -- VERIFICAÇÕES (ASSERTS) DA SAÍDA ESPERADA
        -- =========================================================
        
        -- Coluna 0
        assert out_matriz(0, 0) = x"04" report "Erro na pos (0,0) - Esperado: 04" severity error;
        assert out_matriz(1, 0) = x"66" report "Erro na pos (1,0) - Esperado: 66" severity error;
        assert out_matriz(2, 0) = x"81" report "Erro na pos (2,0) - Esperado: 81" severity error;
        assert out_matriz(3, 0) = x"E5" report "Erro na pos (3,0) - Esperado: E5" severity error;

        -- Coluna 1
        assert out_matriz(0, 1) = x"E0" report "Erro na pos (0,1) - Esperado: E0" severity error;
        assert out_matriz(1, 1) = x"CB" report "Erro na pos (1,1) - Esperado: CB" severity error;
        assert out_matriz(2, 1) = x"19" report "Erro na pos (2,1) - Esperado: 19" severity error;
        assert out_matriz(3, 1) = x"9A" report "Erro na pos (3,1) - Esperado: 9A" severity error;

        -- Coluna 2
        assert out_matriz(0, 2) = x"48" report "Erro na pos (0,2) - Esperado: 48" severity error;
        assert out_matriz(1, 2) = x"F8" report "Erro na pos (1,2) - Esperado: F8" severity error;
        assert out_matriz(2, 2) = x"D3" report "Erro na pos (2,2) - Esperado: D3" severity error;
        assert out_matriz(3, 2) = x"7A" report "Erro na pos (3,2) - Esperado: 7A" severity error;

        -- Coluna 3
        assert out_matriz(0, 3) = x"28" report "Erro na pos (0,3) - Esperado: 28" severity error;
        assert out_matriz(1, 3) = x"06" report "Erro na pos (1,3) - Esperado: 06" severity error;
        assert out_matriz(2, 3) = x"26" report "Erro na pos (2,3) - Esperado: 26" severity error;
        assert out_matriz(3, 3) = x"4C" report "Erro na pos (3,3) - Esperado: 4C" severity error;

        -- Mensagem de sucesso caso nenhum assert falhe
        report "Fim do teste MixColumns. Se não houver mensagens de erro acima, o teste PASSOU com sucesso!" severity note;
 
        wait;
    end process;
 
end architecture behavior;