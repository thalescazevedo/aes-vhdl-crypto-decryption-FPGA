library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AES_pack.all;
use work.roms_package.all;

-- a geracao das chaves de rodada ocorrerá uma vez só. Geraremos todas as chaves no estado s2, previo a scalc.

entity keyExpansion is
	port(
		aes_type    : in  std_logic_vector(1 downto 0);
        user_key    : in  std_logic_vector(255 downto 0);
        outKeys     : out allKeys 
	);
end entity keyExpansion;

architecture behavior OF keyExpansion is
begin
    KE: process(aes_type, user_key) is
        variable W          : allKeys;
        variable temp       : word;
        variable rcon_idx   : integer := 1;
        variable nk         : integer;
        variable max_words  : integer;
        variable rcon_w     : word;
    begin

        for i in 0 to 59 loop
            for j in 0 to 3 loop
                W(i)(j) := (others => '0'); -- Zera o std_logic_vector(7 downto 0)
            end loop;
        end loop;

        if aes_type = "01" then
            nk := 6;
        elsif aes_type = "10" then
            nk := 8;
        else
            nk := 4;
        end if;

        max_words := 4 * (nk + 7);

        -- preenche com a chave do usuario as primeiras words
        for i in 0 to 7 loop 
            if i < nk then
                W(i) := getKeyWord(user_key, i, nk);
            end if;
        end loop;

        rcon_idx := 1;
        
        for i in 4 to 59 loop
            -- Pula execucoes desnecessarias e trata limites dinamicos do loop
            if i >= nk and i < max_words then
                temp := W(i - 1);
                if (i mod nk) = 0 then
                    rcon_w(0) := RCON(rcon_idx);
                    rcon_w(1) := x"00";
                    rcon_w(2) := x"00";
                    rcon_w(3) := x"00";
                    temp := XorWord(SubWord(RotWord(temp)), rcon_w);
                    rcon_idx := rcon_idx + 1;
                elsif nk > 6 and (i mod nk) = 4 then
                    temp := SubWord(temp);
                end if;

                W(i) := XorWord(W(i - nk), temp);
            end if;
        end loop;
        outKeys <= W;
    end process KE;
end architecture behavior;