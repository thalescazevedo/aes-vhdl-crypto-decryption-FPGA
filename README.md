# aes-vhdl-crypto-decryption-FPGA
Extensão de projeto que implementa o AES em seus 3 tipos em tempo de execução. Agora, a ideia é implementar em um mesmo FPGA o algoritmo de criptografia e descriptografia, além de otimizar o bloco de controle e demais problemas do projeto anterior, principalmente referentes a falta de acesso em RAM a grandes vetores.

Frequência Máxima: 87.6MHz.
Clock adotado: **12 ns**.

* **Primeiro Passo:**
- Otimizar o que já existe, realizando a leitura das S-Box's em memória RAM. (Concluído)

* **Segundo Passo:**
- Executar a verificação do AES com leitura em memória ram. (Concluído)

* **Terceiro Passo:**
- Criar os componentes inversos de SubBytes (em ram), MixColumns e ShiftRows. (Concluído)

* **Quarto Passo:**
- Criar um datapath exclusivo para decriptação, adaptando o AES_BO e o top-level. (Concluído)

* **Quinto Passo:**
- Realizar a verificação do projeto em GHDL. (Concluído)

* **Sexto Passo:**
- Compilar o projeto no Quartus e usar o FMax para calcular o clock ideal. (Concluído)
