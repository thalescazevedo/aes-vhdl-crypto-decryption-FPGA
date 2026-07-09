library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AES_pack.all;

entity AES is
    port(
        clk        : in  std_logic;     -- ck
        rst_a      : in  std_logic;     -- reset
        init       : in  std_logic;     -- iniciar
        op         : in  std_logic;     -- crypto or decrypto
        aes_type   : in  std_logic_vector(1 downto 0); -- 00 = aes 128, 01 = aes 192, 10 = aes 256, 11 = x
        user_key   : in  std_logic_vector(255 downto 0); -- 255 pra suportar os 3 aes em tempo de execucao entra sempre com as words na frente: wwww0000, wwwwww00, wwwwwwww.
        user_text  : in  std_logic_vector(127 downto 0); -- texto de 128 bits
        cipher_text: out std_logic_vector(127 downto 0); -- texto cifrado de 128 bits
        done       : out std_logic      -- sinal de conclusão
    );
end entity AES;

architecture behavior of AES is

    signal s_round_counter : std_logic_vector(3 downto 0);
    signal s_rp            : std_logic;
    signal s_ilr           : std_logic;
    signal s_i0            : std_logic;
    -- novos
    signal s_read_memory   : std_logic;
    signal s_R_WORD        : std_logic;
    signal s_rcon_idx      : integer range 1 to 10;
    signal s_keyWord       : integer;
    signal s_s_subbytes    : std_logic;

begin

    inst_AES_BC: entity work.AES_BC(behavior)
        port map(
            clk           => clk,
            init          => init,
            rst_a         => rst_a,
            done          => done,
            aes_type      => aes_type,
            round_counter => s_round_counter,
            rp            => s_rp,
            ilr           => s_ilr,
            i0            => s_i0,
            --novos sinais
            read_memory   => s_read_memory,
            R_WORD        => s_R_WORD,
            rcon_idx      => s_rcon_idx,
            keyWord       => s_keyWord,
            s_subbytes    => s_s_subbytes
        );

    inst_AES_BO: entity work.AES_BO(behavior)
        port map(
            clk           => clk,
            rst_a         => rst_a,
            user_key      => user_key,
            user_text     => user_text,
            cipher_text   => cipher_text,
            aes_type      => aes_type,
            round_counter => s_round_counter,
            rp            => s_rp,
            ilr           => s_ilr,
            i0            => s_i0,
            init          => init,
            --novos sinais
            read_memory   => s_read_memory,
            R_WORD        => s_R_WORD,
            rcon_idx      => s_rcon_idx,
            keyWord       => s_keyWord,
            s_subbytes    => s_s_subbytes
        );

end architecture behavior;