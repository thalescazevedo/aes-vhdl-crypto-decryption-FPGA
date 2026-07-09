library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AES_pack.all;

entity tb_shiftrows is
end entity tb_shiftrows;

architecture behavior of tb_shiftrows is

    component shiftRows is
        port(
            in_matriz  : in  matriz_4x4;
            out_matriz : out matriz_4x4
        );
    end component;

    signal teste_in_matriz  : matriz_4x4;
    signal teste_out_matriz : matriz_4x4;

begin

    SRteste: shiftRows port map (
        in_matriz  => teste_in_matriz,
        out_matriz => teste_out_matriz
    );

    dados_teste: process
    begin
        -- =========================================================
        -- ESTÍMULOS DE ENTRADA
        -- =========================================================
        
        -- Linha 0
        teste_in_matriz(0, 0) <= x"10"; teste_in_matriz(0, 1) <= x"11"; teste_in_matriz(0, 2) <= x"12"; teste_in_matriz(0, 3) <= x"13";
        
        -- Linha 1
        teste_in_matriz(1, 0) <= x"20"; teste_in_matriz(1, 1) <= x"21"; teste_in_matriz(1, 2) <= x"22"; teste_in_matriz(1, 3) <= x"23";
        
        -- Linha 2
        teste_in_matriz(2, 0) <= x"30"; teste_in_matriz(2, 1) <= x"31"; teste_in_matriz(2, 2) <= x"32"; teste_in_matriz(2, 3) <= x"33";
        
        -- Linha 3
        teste_in_matriz(3, 0) <= x"40"; teste_in_matriz(3, 1) <= x"41"; teste_in_matriz(3, 2) <= x"42"; teste_in_matriz(3, 3) <= x"43";

        -- Aguarda o tempo de propagação combinacional
        wait for 20 ns;

        -- =========================================================
        -- VERIFICAÇÕES (ASSERTS) DA SAÍDA ESPERADA
        -- =========================================================
        
        -- Linha 0 (Shift 0): 10, 11, 12, 13
        assert teste_out_matriz(0, 0) = x"10" report "Erro na pos (0,0) - Esperado: 10" severity error;
        assert teste_out_matriz(0, 1) = x"11" report "Erro na pos (0,1) - Esperado: 11" severity error;
        assert teste_out_matriz(0, 2) = x"12" report "Erro na pos (0,2) - Esperado: 12" severity error;
        assert teste_out_matriz(0, 3) = x"13" report "Erro na pos (0,3) - Esperado: 13" severity error;

        -- Linha 1 (Shift 1): 21, 22, 23, 20
        assert teste_out_matriz(1, 0) = x"21" report "Erro na pos (1,0) - Esperado: 21" severity error;
        assert teste_out_matriz(1, 1) = x"22" report "Erro na pos (1,1) - Esperado: 22" severity error;
        assert teste_out_matriz(1, 2) = x"23" report "Erro na pos (1,2) - Esperado: 23" severity error;
        assert teste_out_matriz(1, 3) = x"20" report "Erro na pos (1,3) - Esperado: 20" severity error;

        -- Linha 2 (Shift 2): 32, 33, 30, 31
        assert teste_out_matriz(2, 0) = x"32" report "Erro na pos (2,0) - Esperado: 32" severity error;
        assert teste_out_matriz(2, 1) = x"33" report "Erro na pos (2,1) - Esperado: 33" severity error;
        assert teste_out_matriz(2, 2) = x"30" report "Erro na pos (2,2) - Esperado: 30" severity error;
        assert teste_out_matriz(2, 3) = x"31" report "Erro na pos (2,3) - Esperado: 31" severity error;

        -- Linha 3 (Shift 3): 43, 40, 41, 42
        assert teste_out_matriz(3, 0) = x"43" report "Erro na pos (3,0) - Esperado: 43" severity error;
        assert teste_out_matriz(3, 1) = x"40" report "Erro na pos (3,1) - Esperado: 40" severity error;
        assert teste_out_matriz(3, 2) = x"41" report "Erro na pos (3,2) - Esperado: 41" severity error;
        assert teste_out_matriz(3, 3) = x"42" report "Erro na pos (3,3) - Esperado: 42" severity error;

        -- Mensagem de sucesso caso nenhum assert falhe
        report "Fim do teste ShiftRows. Se não houver mensagens de erro acima, o teste PASSOU com sucesso!" severity note;

        wait;
    end process;

end architecture behavior;