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
        aes_type      : in  std_logic_vector(1 downto 0);
        done          : out std_logic;   
        
        -- para o bo --
        round_counter : out std_logic_vector(3 downto 0);
        rp            : out std_logic;      
        ilr           : out std_logic;      
        i0            : out std_logic      

    );
end entity AES_BC;

architecture behavior of AES_BC is
    Type estado is (S0, KE, KE_EXP1, KE_EXP2, KE_EXP3, Scalc, Sresult);
    signal EAtual  : estado := S0;
    signal PEstado : estado := S0;
    
    signal s_counter : unsigned(3 downto 0) := (others => '0');
    signal number_of_rounds : integer := 10;
    signal keyword  : integer := 4;
    signal flagmod0 : std_logic;
    signal flagmod4 : std_logic;
begin

    round_counter <= std_logic_vector(s_counter);
    number_of_rounds <= calc_nestados(aes_type);
    flagmod0 <= is_mod_nk(keyword,aes_type);
    flagmod4 <= is_aes256_mod_4(keyword,aes_type);

    CRG: process (clk, rst_a)
    BEGIN
        if rst_a = '1' then
            EAtual <= S0;
            s_counter <= "0000";
            keyword := 4;
        
        elsif rising_edge(clk) then
            EAtual <= PEstado;

            if EAtual = S0 then 
                s_counter <= "0000";

            elsif EAtual = KE then
                s_counter <= "0001";
            
            elsif EAtual = Scalc then
                if to_integer(s_counter) < number_of_rounds then
                    s_counter <= s_counter + 1;
                end if;
            
            end if;
        end if;
    end process;
        
    LPE: process (EAtual, init, s_counter, number_of_rounds, keyword, aes_type)
    BEGIN
        CASE EAtual is
            when S0 =>
                if init = '1' then
                    PEstado <= KE;
                else 
                    PEstado <= S0;
                end if;
            
            when KE =>

                if ((is_mod_nk(keyword,aes_type)) or (is_aes256_mod_4(keyword,aes_type))) then
                    PEstado <= KE_EXP1;

                else PEstado <= KE_EXP3;
                end if;

            when KE_EXP1 =>
                PEstado <= KE_EXP2;

            when KE_EXP2 =>
                PEstado <= KE_EXP3;

            when KE_EXP3 =>
                if (keyword < (4 * (get_nk(aes_type) + 7))) then
                    PEstado <= KE;
                    keyword := keyword + 1;
                else PEstado <= Scalc;
                end if;

            when Scalc =>
                if to_integer(s_counter) < number_of_rounds then
                    PEstado <= Scalc;
                else
                    PEstado <= Sresult; 
                end if;
            
            when Sresult => 
                PEstado <= S0;
            
            when others => 
                PEstado <= S0;
        end case;    
    end process;
    
    LS: process (EAtual, s_counter, number_of_rounds)
    BEGIN
        rp        <= '0';
        done      <= '0';
        i0        <= '0';
        ilr       <= '0';
        
        CASE EAtual is
            when S0 => null;
            
            when S1 => 
                i0 <= '1';
                rp <= '1';
            
            when Scalc => 
                rp <= '1';
                if to_integer(s_counter) = number_of_rounds then
                    ilr <= '1';
                end if;
            
            when Sresult => 
                done <= '1';
               
        end case;    
    end process;

end architecture behavior;