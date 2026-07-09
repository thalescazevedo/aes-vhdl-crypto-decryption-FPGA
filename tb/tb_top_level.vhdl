library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AES_pack.all;

entity tb_top_level is
end entity tb_top_level;

architecture tb of tb_top_level is
    signal clk        : std_logic := '0';
    signal rst_a      : std_logic := '1';
    signal init       : std_logic := '0';
    signal aes_type   : std_logic_vector(1 downto 0) := "00";
    signal user_key   : std_logic_vector(255 downto 0) := (others => '0');
    signal user_text  : std_logic_vector(127 downto 0) := (others => '0');
    signal ciphertext : std_logic_vector(127 downto 0);
    signal done       : std_logic;

    -- =========================================================================
    -- ARRAYS E CONSTANTES PARA OS TESTES FIPS-197
    -- =========================================================================
    type expected_array_128 is array(0 to 10) of std_logic_vector(127 downto 0);
    constant FIPS_EXPECTED_128 : expected_array_128 := (
        0  => x"00102030405060708090a0b0c0d0e0f0", -- Start of Round 1
        1  => x"89d810e8855ace682d1843d8cb128fe4", -- Start of Round 2
        2  => x"4915598f55e5d7a0daca94fa1f0a63f7", -- Start of Round 3
        3  => x"fa636a2825b339c940668a3157244d17", -- Start of Round 4
        4  => x"247240236966b3fa6ed2753288425b6c", -- Start of Round 5
        5  => x"c81677bc9b7ac93b25027992b0261996", -- Start of Round 6 
        6  => x"c62fe109f75eedc3cc79395d84f9cf5d", -- Start of Round 7
        7  => x"d1876c0f79c4300ab45594add66ff41f", -- Start of Round 8
        8  => x"fde3bad205e5d0d73547964ef1fe37f1", -- Start of Round 9
        9  => x"bd6e7c3df2b5779e0b61216e8b10b689", -- Start of Round 10
        10 => x"69c4e0d86a7b0430d8cdb78070b4c55a"  -- Output Final
    );

    type expected_array_192 is array(0 to 12) of std_logic_vector(127 downto 0);
    constant FIPS_EXPECTED_192 : expected_array_192 := (
        0  => x"00102030405060708090a0b0c0d0e0f0",
        1  => x"4f63760643e0aa85aff8c9d041fa0de4",
        2  => x"cb02818c17d2af9c62aa64428bb25fd7",
        3  => x"f75c7778a327c8ed8cfebfc1a6c37f53",
        4  => x"22ffc916a81474416496f19c64ae2532",
        5  => x"80121e0776fd1d8a8d8c31bc965d1fee",
        6  => x"671EF1FD4E2A1E03DFDCB1EF3D789B30",
        7  => x"0c0370d00c01e622166b8accd6db3a2c",
        8  => x"7255dad30fb80310e00d6c6b40d0527c",
        9  => x"a906b254968af4e9b4bdb2d2f0c44336",
        10 => x"88ec930ef5e7e4b6cc32f4c906d29414",
        11 => x"afb73eeb1cd1b85162280f27fb20d585",
        12 => x"dda97ca4864cdfe06eaf70a0ec0d7191"
    );

    type expected_array_256 is array(0 to 14) of std_logic_vector(127 downto 0);
    constant FIPS_EXPECTED_256 : expected_array_256 := (
        0  => x"00102030405060708090a0b0c0d0e0f0",
        1  => x"4f63760643e0aa85efa7213201a4e705",
        2  => x"1859fbc28a1c00a078ed8aadc42f6109",
        3  => x"975c66c1cb9f3fa8a93a28df8ee10f63",
        4  => x"1c05f271a417e04ff921c5c104701554",
        5  => x"c357aae11b45b7b0a2c7bd28a8dc99fa",
        6  => x"7f074143cb4e243ec10c815d8375d54c",
        7  => x"d653a4696ca0bc0f5acaab5db96c5e7d",
        8  => x"5aa858395fd28d7d05e1a38868f3b9c5",
        9  => x"4a824851c57e7e47643de50c2af3e8c9",
        10 => x"c14907f6ca3b3aa070e9aa313b52b5ec",
        11 => x"5f9c6abfbac634aa50409fa766677653",
        12 => x"516604954353950314fb86e401922521",
        13 => x"627bceb9999d5aaac945ecf423f56da5",
        14 => x"8ea2b7ca516745bfeafc49904b496089"
    );

begin
    DUV: ENTITY work.AES(behavior)
    port map(
        clk         => clk, 
        init        => init, 
        aes_type    => aes_type, 
        user_key    => user_key, 
        user_text   => user_text,
        cipher_text => ciphertext, 
        done        => done, 
        rst_a       => rst_a
    );
    
    clk <= not clk after 5 ns;

    process
    begin
        -- ===================================================================
        -- TESTE DETALHADO RODADA A RODADA (FIPS-197 AES-128)
        -- ===================================================================
        report "--------------------------------------------------------" severity note;
        report "INICIANDO TESTE DETALHADO (AES-128 FIPS)" severity note;
        report "--------------------------------------------------------" severity note;

        rst_a <= '1';
        wait until rising_edge(clk);
        rst_a <= '0';
        wait until rising_edge(clk);

        aes_type  <= "00";
        user_text <= x"00112233445566778899aabbccddeeff";
        user_key(255 downto 128) <= x"000102030405060708090a0b0c0d0e0f";
        user_key(127 downto 0)   <= (others => '0');

        init <= '1';
        wait until rising_edge(clk);
        init <= '0';

        wait until falling_edge(clk);
        wait until falling_edge(clk);

        for i in 0 to 10 loop
            assert ciphertext = FIPS_EXPECTED_128(i)
                report "AES-128 FALHA CRITICA NA RODADA " & integer'image(i+1) & 
                       " | Esperado: " & to_hstring(FIPS_EXPECTED_128(i)) & 
                       " | Obtido: "   & to_hstring(ciphertext)
                severity error;

            if i < 10 then
                wait until falling_edge(clk);
            end if;
        end loop;

        assert done = '1' report "AES-128: Sinal DONE não ativado!" severity error;
        report "Teste Detalhado AES-128 PASSOU com sucesso!" severity note;
        wait until rising_edge(clk);


        -- ===================================================================
        -- TESTE DETALHADO RODADA A RODADA (FIPS-197 AES-192)
        -- ===================================================================
        report "--------------------------------------------------------" severity note;
        report "INICIANDO TESTE DETALHADO (AES-192 FIPS)" severity note;
        report "--------------------------------------------------------" severity note;

        rst_a <= '1';
        wait until rising_edge(clk);
        rst_a <= '0';
        wait until rising_edge(clk);

        aes_type  <= "01";
        user_text <= x"00112233445566778899aabbccddeeff";
        -- Alinhado aos bits mais significativos para casar com sua extração de chaves
        user_key  <= x"000102030405060708090a0b0c0d0e0f1011121314151617" & (63 downto 0 => '0');

        init <= '1';
        wait until rising_edge(clk);
        init <= '0';

        wait until falling_edge(clk);
        wait until falling_edge(clk);

        for i in 0 to 12 loop
            assert ciphertext = FIPS_EXPECTED_192(i)
                report "AES-192 FALHA CRITICA NA RODADA " & integer'image(i+1) & 
                       " | Esperado: " & to_hstring(FIPS_EXPECTED_192(i)) & 
                       " | Obtido: "   & to_hstring(ciphertext)
                severity error;

            if i < 12 then
                wait until falling_edge(clk);
            end if;
        end loop;

        assert done = '1' report "AES-192: Sinal DONE não ativado!" severity error;
        report "Teste Detalhado AES-192 PASSOU com sucesso!" severity note;
        wait until rising_edge(clk);


        -- ===================================================================
        -- TESTE DETALHADO RODADA A RODADA (FIPS-197 AES-256)
        -- ===================================================================
        report "--------------------------------------------------------" severity note;
        report "INICIANDO TESTE DETALHADO (AES-256 FIPS)" severity note;
        report "--------------------------------------------------------" severity note;

        rst_a <= '1';
        wait until rising_edge(clk);
        rst_a <= '0';
        wait until rising_edge(clk);

        aes_type  <= "10";
        user_text <= x"00112233445566778899aabbccddeeff";
        user_key  <= x"000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f";

        init <= '1';
        wait until rising_edge(clk);
        init <= '0';

        wait until falling_edge(clk);
        wait until falling_edge(clk);

        for i in 0 to 14 loop
            assert ciphertext = FIPS_EXPECTED_256(i)
                report "AES-256 FALHA CRITICA NA RODADA " & integer'image(i+1) & 
                       " | Esperado: " & to_hstring(FIPS_EXPECTED_256(i)) & 
                       " | Obtido: "   & to_hstring(ciphertext)
                severity error;

            if i < 14 then
                wait until falling_edge(clk);
            end if;
        end loop;

        assert done = '1' report "AES-256: Sinal DONE não ativado!" severity error;
        report "Teste Detalhado AES-256 PASSOU com sucesso!" severity note;
        wait;
    end process;
    
end architecture tb;