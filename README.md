# aes-vhdl-crypto-decryption-FPGA
Extensão de projeto que implementa o AES em seus 3 tipos em tempo de execução. Agora, a ideia é implementar em um mesmo FPGA o algoritmo de criptografia e descriptografia, além de otimizar o bloco de controle e demais problemas do projeto anterior, principalmente referentes a falta de acesso em RAM a grandes vetores.

* **Primeiro Passo:**
- Otimizar o que já existe, realizando a leitura das S-Box's em memória RAM.