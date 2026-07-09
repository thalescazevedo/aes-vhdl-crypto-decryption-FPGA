library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AES_pack.all;

entity keys_register is
    port(
        clk          : in  std_logic;
        rst_a        : in  std_logic;
        
        -- Sinais de Controle da FSM
        init         : in  std_logic; -- Sobe em S0 para carregar a chave inicial
        enable : in  std_logic; -- Sobe em KE_EXP3/KEXOR para gravar a palavra
        
        -- Dados de Entrada
        user_key     : in  std_logic_vector(255 downto 0); 
        aes_type     : in  std_logic_vector(1 downto 0);   
        address      : in  integer;                        -- O seu sinal 'keyWord'
        word_in      : in  word;                           -- A palavra processada (temp)
        
        q            : out allKeys 
    );
end keys_register;

architecture behavior OF keys_register is
    signal memory : allKeys;
begin
    process(clk, rst_a)
    begin
        if (rst_a = '1') then
            memory <= (others => (others => (others => '0')));
            
        elsif (rising_edge(clk)) then
            if (init = '1') then
                for i in 0 to 7 loop
                    if i < get_nk(aes_type) then
                        memory(i) <= getKeyWord(user_key, i, get_nk(aes_type));
                    end if;
                end loop;
            
            elsif (enable = '1') then
                memory(address) <= word_in;
            end if;
            
        end if; 
    end process;

    q <= memory;
    
end architecture behavior;