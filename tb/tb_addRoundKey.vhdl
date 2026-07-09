library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AES_pack.all;

entity tb_addRoundKey is
end entity tb_addRoundKey;

architecture behavior of tb_addRoundKey is

    component addRoundKey is
        port(
            in_matriz         : in      matriz_4x4;
            keySchedule       : in      matriz_4x4;
            out_matriz        : out     matriz_4x4
        );
    end component;

    -- Sinais de teste corrigidos para dar match com a entidade
    signal teste_in_matriz       : matriz_4x4;
    signal teste_keySchedule     : matriz_4x4;
    signal teste_out_matriz      : matriz_4x4;

begin

    DUT: addRoundKey port map (
        in_matriz         => teste_in_matriz,
        keySchedule       => teste_keySchedule,
        out_matriz        => teste_out_matriz
    );

    process
    begin
        -- =========================================================
        -- VERIFICAÇÃO DO CÁLCULO XOR
        -- =========================================================
        
        -- Matriz de entrada (in_matriz) de teste
        teste_in_matriz(0, 0) <= x"11"; teste_in_matriz(0, 1) <= x"22"; teste_in_matriz(0, 2) <= x"33"; teste_in_matriz(0, 3) <= x"44";
        teste_in_matriz(1, 0) <= x"55"; teste_in_matriz(1, 1) <= x"66"; teste_in_matriz(1, 2) <= x"77"; teste_in_matriz(1, 3) <= x"88";
        teste_in_matriz(2, 0) <= x"99"; teste_in_matriz(2, 1) <= x"AA"; teste_in_matriz(2, 2) <= x"BB"; teste_in_matriz(2, 3) <= x"CC";
        teste_in_matriz(3, 0) <= x"DD"; teste_in_matriz(3, 1) <= x"EE"; teste_in_matriz(3, 2) <= x"FF"; teste_in_matriz(3, 3) <= x"00";

        -- Preenchendo a chave (keySchedule) que agora é uma matriz_4x4 (estilo linha, coluna)
        teste_keySchedule(0, 0) <= x"10"; teste_keySchedule(0, 1) <= x"50"; teste_keySchedule(0, 2) <= x"90"; teste_keySchedule(0, 3) <= x"D0";
        teste_keySchedule(1, 0) <= x"20"; teste_keySchedule(1, 1) <= x"60"; teste_keySchedule(1, 2) <= x"A0"; teste_keySchedule(1, 3) <= x"E0";
        teste_keySchedule(2, 0) <= x"30"; teste_keySchedule(2, 1) <= x"70"; teste_keySchedule(2, 2) <= x"B0"; teste_keySchedule(2, 3) <= x"F0";
        teste_keySchedule(3, 0) <= x"40"; teste_keySchedule(3, 1) <= x"80"; teste_keySchedule(3, 2) <= x"C0"; teste_keySchedule(3, 3) <= x"00";

        wait for 20 ns;

        -- Testando o resultado do XOR:
        assert teste_out_matriz(0, 0) = x"01" report "Falha Parte 2 - XOR Errado pos (0,0)" severity error;
        assert teste_out_matriz(1, 0) = x"35" report "Falha Parte 2 - XOR Errado pos (1,0)" severity error; -- Correção: x"55" xor x"20" = x"35"
        assert teste_out_matriz(2, 0) = x"A9" report "Falha Parte 2 - XOR Errado pos (2,0)" severity error; -- Correção: x"99" xor x"30" = x"A9"
        assert teste_out_matriz(3, 0) = x"9D" report "Falha Parte 2 - XOR Errado pos (3,0)" severity error; -- Correção: x"DD" xor x"40" = x"9D"

        -- Outras colunas
        assert teste_out_matriz(0, 1) = x"72" report "Falha Parte 2 - XOR Errado pos (0,1)" severity error; -- Correção: x"22" xor x"50" = x"72"
        assert teste_out_matriz(1, 2) = x"D7" report "Falha Parte 2 - XOR Errado pos (1,2)" severity error; -- Correção: x"77" xor x"A0" = x"D7"
        assert teste_out_matriz(3, 3) = x"00" report "Falha Parte 2 - XOR Errado pos (3,3)" severity error; -- x"00" xor x"00" = x"00"

        report "Fim do teste addRoundKey. Se nao houver mensagens de erro acima, os testes PASSARAM com sucesso!" severity note;

        wait;
    end process;

end architecture behavior;