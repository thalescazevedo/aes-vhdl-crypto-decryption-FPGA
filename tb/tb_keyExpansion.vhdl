library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AES_pack.all;

entity tb_keyExpansion is
end entity tb_keyExpansion;

architecture sim of tb_keyExpansion is

    -- -------------------------------------------------------------------------
    -- Local type: array of 128-bit round keys used for expected-value tables
    -- -------------------------------------------------------------------------
    type expected_array is array(natural range <>) of std_logic_vector(127 downto 0);

    -- =========================================================================
    -- Sinais de Controle do Top-Level
    -- =========================================================================
    signal clk          : std_logic := '0';
    signal rst_a        : std_logic := '1';
    signal init         : std_logic := '0';
    signal op           : std_logic := '0';
    signal done         : std_logic;
    signal dummy_text   : std_logic_vector(127 downto 0) := (others => '0');
    signal dummy_cipher : std_logic_vector(127 downto 0);

    signal s_aes_type   : std_logic_vector(1 downto 0)   := "00";
    signal s_user_key   : std_logic_vector(255 downto 0) := (others => '0');
    
    -- =========================================================================
    -- Input key constants
    -- =========================================================================
    constant KEY_AES128 : std_logic_vector(255 downto 0) :=
        x"2b7e151628aed2a6abf7158809cf4f3c" &   
        x"00000000000000000000000000000000";   

    constant KEY_AES192 : std_logic_vector(255 downto 0) :=
        x"8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b" &  
        x"0000000000000000";                                  

    constant KEY_AES256 : std_logic_vector(255 downto 0) :=
        x"603deb1015ca71be2b73aef0857d7781" &   
        x"1f352c073b6108d72d9810a30914dff4";    

    -- =========================================================================
    -- Expected round keys — FIPS 197 Appendix A
    -- =========================================================================
    constant EXP_AES128 : expected_array(0 to 10) := (
        x"2b7e151628aed2a6abf7158809cf4f3c", x"a0fafe1788542cb123a339392a6c7605", 
        x"f2c295f27a96b9435935807a7359f67f", x"3d80477d4716fe3e1e237e446d7a883b", 
        x"ef44a541a8525b7fb671253bdb0bad00", x"d4d1c6f87c839d87caf2b8bc11f915bc", 
        x"6d88a37a110b3efddbf98641ca0093fd", x"4e54f70e5f5fc9f384a64fb24ea6dc4f", 
        x"ead27321b58dbad2312bf5607f8d292f", x"ac7766f319fadc2128d12941575c006e", 
        x"d014f9a8c9ee2589e13f0cc8b6630ca6"
    );

    constant EXP_AES192 : expected_array(0 to 12) := (
        x"8e73b0f7da0e6452c810f32b809079e5", x"62f8ead2522c6b7bfe0c91f72402f5a5", 
        x"ec12068e6c827f6b0e7a95b95c56fec2", x"4db7b4bd69b5411885a74796e92538fd", 
        x"e75fad44bb095386485af05721efb14f", x"a448f6d94d6dce24aa326360113b30e6", 
        x"a25e7ed583b1cf9a27f939436a94f767", x"c0a69407d19da4e1ec1786eb6fa64971", 
        x"485f703222cb8755e26d135233f0b7b3", x"40beeb282f18a2596747d26b458c553e", 
        x"a7e1466c9411f1df821f750aad07d753", x"ca4005388fcc5006282d166abc3ce7b5", 
        x"e98ba06f448c773c8ecc720401002202"
    );

    constant EXP_AES256 : expected_array(0 to 14) := (
        x"603deb1015ca71be2b73aef0857d7781", x"1f352c073b6108d72d9810a30914dff4", 
        x"9ba354118e6925afa51a8b5f2067fcde", x"a8b09c1a93d194cdbe49846eb75d5b9a", 
        x"d59aecb85bf3c917fee94248de8ebe96", x"b5a9328a2678a647983122292f6c79b3", 
        x"812c81addadf48ba24360af2fab8b464", x"98c5bfc9bebd198e268c3ba709e04214", 
        x"68007bacb2df331696e939e46c518d80", x"c814e20476a9fb8a5025c02d59c58239", 
        x"de1369676ccc5a71fa2563959674ee15", x"5886ca5d2e2f31d77e0af1fa27cf73c3", 
        x"749c47ab18501ddae2757e4f7401905a", x"cafaaae3e4d59b349adf6acebd10190d", 
        x"fe4890d1e6188d0b046df344706c631e"
    );

    -- =========================================================================
    -- Function extract_round_key
    -- =========================================================================
    function extract_round_key(rk : allKeys; round : integer) return std_logic_vector is
        variable result : std_logic_vector(127 downto 0);
        variable base   : integer;
    begin
        base := round * 4;
        for w in 0 to 3 loop
            for b in 0 to 3 loop
                result(127 - w*32 - b*8 downto 120 - w*32 - b*8) := rk(base + w)(b);
            end loop;
        end loop;
        return result;
    end function extract_round_key;

begin
    -- O ALIAS FOI REMOVIDO DAQUI

    -- Geração do Clock
    clk <= not clk after 5 ns;

    -- =========================================================================
    -- Instância do Top-Level AES (Para rodar a Máquina de Estados)
    -- =========================================================================
    uut : entity work.AES(behavior)
        port map (
            clk         => clk,
            rst_a       => rst_a,
            init        => init,
            op          => op,
            aes_type    => s_aes_type,
            user_key    => s_user_key,
            user_text   => dummy_text,
            cipher_text => dummy_cipher,
            done        => done
        );

    -- =========================================================================
    -- Stimulus & checking process
    -- =========================================================================
    stim : process
        -- =========================================================================
        -- O ALIAS VEM AQUI! (Na área declarativa do processo "stim", ANTES da procedure)
        -- Dessa forma ele enxerga o 'uut' já elaborado e a procedure enxerga o alias.
        -- =========================================================================
        alias s_round_keys is << signal .tb_keyExpansion.uut.inst_AES_BO.allRoundKeys : work.AES_pack.allKeys >>;

        variable got      : std_logic_vector(127 downto 0);
        variable pass_cnt : integer := 0;
        variable fail_cnt : integer := 0;

        procedure check_round(
            test_label : string;
            round      : integer;
            expected   : std_logic_vector(127 downto 0)
        ) is begin
            got := extract_round_key(s_round_keys, round);
            if got = expected then
                report "PASS  " & test_label & "  Round " & integer'image(round) severity note;
                pass_cnt := pass_cnt + 1;
            else
                report "FAIL  " & test_label & "  Round " & integer'image(round)
                    & "  expected=" & to_hstring(expected)
                    & "  got="      & to_hstring(got) severity error;
                fail_cnt := fail_cnt + 1;
            end if;
        end procedure check_round;

    begin
        -- Reset inicial do sistema
        rst_a <= '1';
        wait until rising_edge(clk);
        rst_a <= '0';
        wait until rising_edge(clk);

        -- =====================================================================
        -- TEST BLOCK 1 — AES-128
        -- =====================================================================
        report "----------------------------------------";
        report "BLOCK 1 : AES-128";
        report "----------------------------------------";
        s_aes_type <= "00";
        s_user_key <= KEY_AES128;
        
        init <= '1';
        wait until rising_edge(clk);
        init <= '0';

        -- Aguarda o hardware terminar o cálculo da chave inteira e a criptografia
        wait until done = '1' for 4000 ns;
        wait until falling_edge(clk); -- Estabilidade dos sinais

        for r in EXP_AES128'range loop
            check_round("AES-128", r, EXP_AES128(r));
        end loop;
        wait until rising_edge(clk);


        -- =====================================================================
        -- TEST BLOCK 2 — AES-192
        -- =====================================================================
        report "----------------------------------------";
        report "BLOCK 2 : AES-192";
        report "----------------------------------------";
        s_aes_type <= "01";
        s_user_key <= KEY_AES192;
        
        init <= '1';
        wait until rising_edge(clk);
        init <= '0';

        wait until done = '1' for 4000 ns;
        wait until falling_edge(clk);

        for r in EXP_AES192'range loop
            check_round("AES-192", r, EXP_AES192(r));
        end loop;
        wait until rising_edge(clk);


        -- =====================================================================
        -- TEST BLOCK 3 — AES-256
        -- =====================================================================
        report "----------------------------------------";
        report "BLOCK 3 : AES-256";
        report "----------------------------------------";
        s_aes_type <= "10";
        s_user_key <= KEY_AES256;
        
        init <= '1';
        wait until rising_edge(clk);
        init <= '0';

        wait until done = '1' for 4000 ns;
        wait until falling_edge(clk);

        for r in EXP_AES256'range loop
            check_round("AES-256", r, EXP_AES256(r));
        end loop;

        -- =====================================================================
        -- Summary
        -- =====================================================================
        report "========================================";
        report "RESULT : " & integer'image(pass_cnt) & " passed, "
                           & integer'image(fail_cnt) & " failed"
                           & "  (total = " & integer'image(pass_cnt + fail_cnt) & ")";
        if fail_cnt = 0 then
            report "ALL 39 ROUND KEYS VERIFIED CORRECTLY" severity note;
        else
            report integer'image(fail_cnt) & " ROUND KEY(S) INCORRECT" severity failure;
        end if;
        report "========================================";

        std.env.stop;
    end process stim;

end architecture sim;