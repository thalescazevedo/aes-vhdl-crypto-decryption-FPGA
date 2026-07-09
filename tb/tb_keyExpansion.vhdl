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
    -- UUT signals
    -- =========================================================================
    signal s_aes_type   : std_logic_vector(1 downto 0)   := "00";
    signal s_user_key   : std_logic_vector(255 downto 0) := (others => '0');
    signal s_round_keys : allKeys;

    -- =========================================================================
    -- Input key constants
    --
    -- IMPORTANT: getKeyWord (AES_pack) always reads word_index=0 from bits
    -- [255:224], regardless of the nk/key_words parameter (that parameter is
    -- received but never used inside the function body). This means the real
    -- key bytes must be placed in the MOST significant bits of the 256-bit
    -- vector (left-aligned), with any unused trailing bits padded with zero.
    --
    --   AES-128 nk=4 : key occupies bits [255:128]  -> 128 trailing zero bits
    --   AES-192 nk=6 : key occupies bits [255:64]    ->  64 trailing zero bits
    --   AES-256 nk=8 : key occupies bits [255:0]     ->   0 trailing zero bits
    -- =========================================================================
    constant KEY_AES128 : std_logic_vector(255 downto 0) :=
        x"2b7e151628aed2a6abf7158809cf4f3c" &   -- bits [255:128] = key
        x"00000000000000000000000000000000";   -- bits [127:0]   unused

    constant KEY_AES192 : std_logic_vector(255 downto 0) :=
        x"8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b" &  -- bits [255:64] = key
        x"0000000000000000";                                  -- bits [63:0]   unused

    constant KEY_AES256 : std_logic_vector(255 downto 0) :=
        x"603deb1015ca71be2b73aef0857d7781" &   -- bits [255:128]
        x"1f352c073b6108d72d9810a30914dff4";    -- bits [127:0]

    -- =========================================================================
    -- Expected round keys — FIPS 197 Appendix A
    -- =========================================================================

    -- AES-128 : 11 round keys (Nr = 10)
    constant EXP_AES128 : expected_array(0 to 10) := (
        x"2b7e151628aed2a6abf7158809cf4f3c",   -- Round  0
        x"a0fafe1788542cb123a339392a6c7605",   -- Round  1
        x"f2c295f27a96b9435935807a7359f67f",   -- Round  2
        x"3d80477d4716fe3e1e237e446d7a883b",   -- Round  3
        x"ef44a541a8525b7fb671253bdb0bad00",   -- Round  4
        x"d4d1c6f87c839d87caf2b8bc11f915bc",   -- Round  5
        x"6d88a37a110b3efddbf98641ca0093fd",   -- Round  6
        x"4e54f70e5f5fc9f384a64fb24ea6dc4f",   -- Round  7
        x"ead27321b58dbad2312bf5607f8d292f",   -- Round  8
        x"ac7766f319fadc2128d12941575c006e",   -- Round  9
        x"d014f9a8c9ee2589e13f0cc8b6630ca6"    -- Round 10
    );

    -- AES-192 : 13 round keys (Nr = 12)
    constant EXP_AES192 : expected_array(0 to 12) := (
        x"8e73b0f7da0e6452c810f32b809079e5",   -- Round  0
        x"62f8ead2522c6b7bfe0c91f72402f5a5",   -- Round  1
        x"ec12068e6c827f6b0e7a95b95c56fec2",   -- Round  2
        x"4db7b4bd69b5411885a74796e92538fd",   -- Round  3
        x"e75fad44bb095386485af05721efb14f",   -- Round  4
        x"a448f6d94d6dce24aa326360113b30e6",   -- Round  5
        x"a25e7ed583b1cf9a27f939436a94f767",   -- Round  6
        x"c0a69407d19da4e1ec1786eb6fa64971",   -- Round  7
        x"485f703222cb8755e26d135233f0b7b3",   -- Round  8
        x"40beeb282f18a2596747d26b458c553e",   -- Round  9
        x"a7e1466c9411f1df821f750aad07d753",   -- Round 10
        x"ca4005388fcc5006282d166abc3ce7b5",   -- Round 11
        x"e98ba06f448c773c8ecc720401002202"    -- Round 12
    );

    -- AES-256 : 15 round keys (Nr = 14)
    constant EXP_AES256 : expected_array(0 to 14) := (
        x"603deb1015ca71be2b73aef0857d7781",   -- Round  0
        x"1f352c073b6108d72d9810a30914dff4",   -- Round  1
        x"9ba354118e6925afa51a8b5f2067fcde",   -- Round  2
        x"a8b09c1a93d194cdbe49846eb75d5b9a",   -- Round  3
        x"d59aecb85bf3c917fee94248de8ebe96",   -- Round  4
        x"b5a9328a2678a647983122292f6c79b3",   -- Round  5
        x"812c81addadf48ba24360af2fab8b464",   -- Round  6
        x"98c5bfc9bebd198e268c3ba709e04214",   -- Round  7
        x"68007bacb2df331696e939e46c518d80",   -- Round  8
        x"c814e20476a9fb8a5025c02d59c58239",   -- Round  9
        x"de1369676ccc5a71fa2563959674ee15",   -- Round 10
        x"5886ca5d2e2f31d77e0af1fa27cf73c3",   -- Round 11
        x"749c47ab18501ddae2757e4f7401905a",   -- Round 12
        x"cafaaae3e4d59b349adf6acebd10190d",   -- Round 13
        x"fe4890d1e6188d0b046df344706c631e"    -- Round 14
    );

    -- =========================================================================
    -- extract_round_key
    -- Rebuilds a 128-bit round key from four consecutive words in allKeys.
    --   allKeys  = array(0 to 59) of word
    --   word     = array(0 to 3) of std_logic_vector(7 downto 0)
    --   word(0)  = MSByte  ->  word maps to bits [31:0] MSB-first
    --   Round r uses words [r*4 .. r*4+3]
    -- =========================================================================
    function extract_round_key(rk : allKeys; round : integer)
            return std_logic_vector is
        variable result : std_logic_vector(127 downto 0);
        variable base   : integer;
    begin
        base := round * 4;
        for w in 0 to 3 loop
            for b in 0 to 3 loop
                result(127 - w*32 - b*8 downto 120 - w*32 - b*8) :=
                    rk(base + w)(b);
            end loop;
        end loop;
        return result;
    end function extract_round_key;

begin

    -- =========================================================================
    -- Unit under test
    -- =========================================================================
    uut : entity work.keyExpansion
        port map (
            aes_type => s_aes_type,
            user_key => s_user_key,
            outKeys  => s_round_keys
        );

    -- =========================================================================
    -- Stimulus & checking process
    -- =========================================================================
    stim : process
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
                report "PASS  " & test_label & "  Round " & integer'image(round)
                    severity note;
                pass_cnt := pass_cnt + 1;
            else
                report "FAIL  " & test_label & "  Round " & integer'image(round)
                    & "  expected=" & to_hstring(expected)
                    & "  got="      & to_hstring(got)
                    severity error;
                fail_cnt := fail_cnt + 1;
            end if;
        end procedure check_round;

    begin
        wait for 20 ns;

        -- =====================================================================
        -- TEST BLOCK 1 — AES-128  (aes_type = "00",  Nr = 10,  11 round keys)
        -- =====================================================================
        report "----------------------------------------";
        report "BLOCK 1 : AES-128";
        report "----------------------------------------";
        s_aes_type <= "00";
        s_user_key <= KEY_AES128;
        wait for 10 ns;

        for r in EXP_AES128'range loop
            check_round("AES-128", r, EXP_AES128(r));
        end loop;

        -- =====================================================================
        -- TEST BLOCK 2 — AES-192  (aes_type = "01",  Nr = 12,  13 round keys)
        -- =====================================================================
        report "----------------------------------------";
        report "BLOCK 2 : AES-192";
        report "----------------------------------------";
        s_aes_type <= "01";
        s_user_key <= KEY_AES192;
        wait for 10 ns;

        for r in EXP_AES192'range loop
            check_round("AES-192", r, EXP_AES192(r));
        end loop;

        -- =====================================================================
        -- TEST BLOCK 3 — AES-256  (aes_type = "10",  Nr = 14,  15 round keys)
        -- =====================================================================
        report "----------------------------------------";
        report "BLOCK 3 : AES-256";
        report "----------------------------------------";
        s_aes_type <= "10";
        s_user_key <= KEY_AES256;
        wait for 10 ns;

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
            report integer'image(fail_cnt) & " ROUND KEY(S) INCORRECT"
                severity failure;
        end if;
        report "========================================";

        wait;
    end process stim;

end architecture sim;

--Comando pra simular em ghdl--

-- ghdl -a --workdir=work_tb1 --std=08 src/Commons/roms_package.vhdl
-- ghdl -a --workdir=work_tb1 --std=08 src/AES_PACK.vhdl
-- ghdl -a --workdir=work_tb1 --std=08 src/AES_Components/keyExpansion.vhdl
-- ghdl -a --workdir=work_tb1 --std=08 tb/tb1.vhdl
-- ghdl -e --workdir=work_tb1 --std=08 tb1
-- ghdl -r --workdir=work_tb1 --std=08 tb1
