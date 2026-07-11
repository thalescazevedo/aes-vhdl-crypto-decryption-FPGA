library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AES_pack.all;

entity AES_BC is
    port(
        -- top level --
        clk           : in  std_logic;      -- clk
        init          : in  std_logic;      -- iniciar
        rst_a         : in  std_logic;
        op            : in  std_logic;
        aes_type      : in  std_logic_vector(1 downto 0);
        done          : out std_logic;   
        
        -- para o bo --
        round_counter : out std_logic_vector(3 downto 0);
        rp            : out std_logic;      
        ilr           : out std_logic;      
        i0            : out std_logic;  
        read_memory   : out std_logic;
        R_WORD        : out std_logic;
        rcon_idx      : out integer range 1 to 10;
        keyWord       : out integer;
        s_subbytes    : out std_logic;
        s_invsubbytes : out std_logic
    );
end entity AES_BC;

architecture behavior of AES_BC is
    Type estado is (S0, S1, KE, KE_EXP1, KE_EXP2, KE_EXP3, OPWAIT, SC1, SC2, Sresult);
    signal EAtual  : estado := S0;
    signal PEstado : estado := S0;
    
    signal s_counter        : unsigned(3 downto 0) := (others => '0');
    signal number_of_rounds : integer := 10;
    signal s_keyword        : integer := 4;
    signal flagmod0         : std_logic;
    signal flagmod4         : std_logic;
    signal s_rconIDX        : integer range 1 to 10;

begin

    round_counter       <= std_logic_vector(s_counter);
    number_of_rounds    <= calc_nestados(aes_type);
    flagmod0            <= is_mod_nk(s_keyword,aes_type);
    flagmod4            <= is_aes256_mod_4(s_keyword,aes_type);
    rcon_idx            <= s_rconIDX;
    keyword             <= s_keyWord;

    CRG: process (clk, rst_a, op)
    BEGIN
        if rst_a = '1' then
            EAtual <= S0;
            s_counter <= "0000";
            s_keyword <= 4;
            s_rconIDX <= 1;
        
        elsif rising_edge(clk) then
            EAtual <= PEstado;

            if EAtual = S0 then 
                if op = '0' then
                    s_counter <= "0000";
                else
                    s_counter <= to_unsigned(calc_nestados(aes_type)+1, 4);
                end if;

            elsif EAtual = S1 then
                s_keyword <= get_nk(aes_type);
                s_rconIDX <= 1;
                if op = '0' then
                    s_counter <= "0001";
                else
                    s_counter <= s_counter - 1;
                end if;

            elsif EAtual = KE_EXP3 then
                s_keyword <= s_keyword + 1;
                if (flagmod0 = '1') then
                    if (s_rconIDX < 10) then
                        s_rconIDX <= s_rconIDX + 1;
                    end if;
                end if;

            elsif EAtual = SC2 then
                if op = '0' then
                    if to_integer(s_counter) < number_of_rounds then
                        s_counter <= s_counter + 1;
                    end if;
                else
                    if to_integer(s_counter) > 0 then
                        s_counter <= s_counter - 1;
                    end if;
                end if;
            
            end if;
        end if;
    end process;
        
    LPE: process (EAtual, init, s_counter, number_of_rounds, s_keyword, aes_type, flagmod0, flagmod4, op)
    BEGIN
        CASE EAtual is
            when S0 =>
                if init = '1' then
                    PEstado <= S1;
                else 
                    PEstado <= S0;
                end if;
            
            when S1 =>
                PEstado <= KE;

            when KE =>

                if ((flagmod0 = '1') or (flagmod4 = '1')) then
                    PEstado <= KE_EXP1;

                else PEstado <= KE_EXP3;
                end if;

            when KE_EXP1 =>
                PEstado <= KE_EXP2;

            when KE_EXP2 =>
                PEstado <= KE_EXP3;

            when KE_EXP3 =>
                if (s_keyword < (4 * (get_nk(aes_type) + 7))-1) then
                    PEstado <= KE;
                else PEstado <= OPWAIT;
                end if;

            when OPWAIT => 
                PEstado <= SC1;

            when SC1 =>
                PEstado <= SC2;

            when SC2 =>
                if op = '0' then
                    if to_integer(s_counter) >= number_of_rounds then
                        PEstado <= Sresult;
                    else
                        PEstado <= OPWAIT; 
                    end if;
                else
                    if to_integer(s_counter) <= 0 then
                        PEstado <= Sresult;
                    else
                        PEstado <= OPWAIT; 
                    end if;
                end if;
            
            when Sresult => 
                PEstado <= S0;
            
            when others => 
                PEstado <= S0;
        end case;    
    end process;
    
    LS: process (EAtual, s_counter, number_of_rounds, op)
    BEGIN
        rp              <= '0';
        done            <= '0';
        i0              <= '0';
        ilr             <= '0';
        R_WORD          <= '0';
        read_memory     <= '0';
        s_subbytes      <= '0';
        s_invsubbytes   <= '0';

        CASE EAtual is
            when S0 => null;
            
            when S1 =>
                i0 <= '1';
                rp <= '1';

            when KE => null;

            when KE_EXP1 => 
                read_memory <= '1';

            when KE_EXP2 => null;
                
            when KE_EXP3 =>
                R_WORD <= '1';

            when OPWAIT =>
                if op = '0' then
                    s_subbytes <= '1';
                else
                    s_invsubbytes <= '1';
                end if;

            when SC1 => 
                null;

            when SC2 => 
                rp <= '1';
                if op = '0' then
                    if to_integer(s_counter) = number_of_rounds then
                        ilr <= '1';
                    end if;
                else
                    if to_integer(s_counter) = 1 then
                        ilr <= '1';
                    end if;
                end if;

            when Sresult => 
                done <= '1';
               
        end case;    
    end process;

end architecture behavior;