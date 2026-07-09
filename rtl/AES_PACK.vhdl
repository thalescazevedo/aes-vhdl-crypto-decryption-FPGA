library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.roms_package.all;

package AES_pack is

    type matriz_4x4 is array(0 to 3, 0 to 3) of std_logic_vector(7 downto 0); -- matriz de 4x4 bytes (128 bits)(16 bytes)
    
    function calc_nestados(aes_type : std_logic_vector(1 downto 0)) return integer;

    type word is array(0 to 3) of std_logic_vector(7 downto 0); -- tipo para representar uma palavra de 4 bytes (32 bits) (Linha da matriz)

    type allKeys is array(0 to 59) of word;

    function RotWord(input : word) return word; -- funcao que rotaciona uma palavra para a esquerda (ex: [a0, a1, a2, a3] vira [a1, a2, a3, a0])
    
    function SubWord(input : word) return word; -- funcao que aplica a SBOX em cada byte da palavra (ex: [a0, a1, a2, a3] vira [SBOX[a0], SBOX[a1], SBOX[a2], SBOX[a3]])

    function getKeyWord(key_vec : std_logic_vector(255 downto 0); word_index : integer; key_words : integer) return word; -- funcao que extrai uma palavra da chave completa respeitando a janela util de cada AES

    function getWord(input : matriz_4x4; col : integer) return word; -- funcao que extrai uma palavra (coluna) da matriz (ex: getWord(matriz, 2) retorna a palavra formada pelos bytes da coluna 2 da matriz)

    function setWord(input : matriz_4x4; col : integer; w : word) return matriz_4x4; -- funcao que insere uma palavra (coluna) na matriz (ex: setWord(matriz, 2, w) retorna a matriz com a coluna 2 substituida pelos bytes da palavra w)

    function XorWord(a, b : word) return word; -- funcao que aplica o XOR entre duas palavras (ex: [a0, a1, a2, a3] XOR [b0, b1, b2, b3] vira [a0 XOR b0, a1 XOR b1, a2 XOR b2, a3 XOR b3])

    function vetor128bits_to_matriz_4x4(input : std_logic_vector(127 downto 0)) return matriz_4x4; -- funcao que converte o vetor para matriz,
        -- com a ressalva de que o preenchimento e feito por colunas
    
    function xtime(b : std_logic_vector(7 downto 0)) return std_logic_vector; -- funcao de multiplicar por 2 e evitar overflow com xor (nicolas usa essa tambem)
    
    function matriz_4x4_to_128bits(input: matriz_4x4) return std_logic_vector;

end package AES_pack;


package body AES_pack is

    function calc_nestados(aes_type : std_logic_vector(1 downto 0)) return integer is
        begin
            case aes_type is
                when "00" => 
                    return 10; -- AES-128
                when "01" => 
                    return 12; -- AES-192
                when "10" => 
                    return 14; -- AES-256
                when others => 
                    return 10; 
            end case;
    end function;

    function setWord(input : matriz_4x4; col : integer; w : word) return matriz_4x4 is
        variable r : matriz_4x4;
    begin
        r := input;
        for row in 0 to 3 loop
            r(row, col) := w(row);
        end loop;
        return r;
    end function setWord;

    function getWord(input : matriz_4x4; col : integer) return word is
        variable r : word;
    begin
        for row in 0 to 3 loop
            r(row) := input(row, col);
        end loop;
        return r;
    end function getWord;

    function XorWord(a, b : word) return word is
        variable output : word;
    begin
        for i in 0 to 3 loop
            output(i) := a(i) xor b(i);
        end loop;
        return output;
    end function;

    function RotWord(input : word) return word is
        variable output : word;
    begin
        output(0) := input(1);
        output(1) := input(2);
        output(2) := input(3);
        output(3) := input(0);
        return output;
    end function;

    function SubWord(input : word) return word is
        variable output : word;
    begin
        for i in 0 to 3 loop
            output(i) := SBOX(to_integer(unsigned(input(i))));
        end loop;
        return output;
    end function;

    function getKeyWord(key_vec : std_logic_vector(255 downto 0); word_index : integer; key_words : integer) return word is
        variable output : word;
        variable base_bit : integer;
    begin

        base_bit := 255 - (word_index * 32);

        for byte_index in 0 to 3 loop
            output(byte_index) := key_vec(base_bit - byte_index * 8 downto base_bit - byte_index * 8 - 7);
        end loop;

        return output;
    end function getKeyWord;

    function vetor128bits_to_matriz_4x4(input : std_logic_vector(127 downto 0)) return matriz_4x4 is
        variable output : matriz_4x4;
    begin
        for i in 0 to 3 loop
            for j in 0 to 3 loop
                output(i, j) := input((127 - (i + j*4)*8) downto (120 - (i + j*4)*8));
            end loop;
        end loop;
        return output;
    end function;

    function xtime(b : std_logic_vector(7 downto 0)) return std_logic_vector is
        variable result : std_logic_vector(7 downto 0);
    begin
        result := b(6 downto 0) & '0';
        if b(7) = '1' then
            result := result xor "00011011";
        end if;
        return result;
    end function;

    function matriz_4x4_to_128bits(input: matriz_4x4) return std_logic_vector is
        variable output : std_logic_vector(127 downto 0);
    begin
        for i in 0 to 3 loop
            for j in 0 to 3 loop
                output((127 - (i + j*4)*8) downto (120 - (i + j*4)*8)) := input(i, j);
            end loop;
        end loop;
        return output;
    end function;

end package body AES_pack;
