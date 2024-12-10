# Simulação de Formigueiro Versão HxH: Formiga Quimera

Este repositório contém o código e a documentação para o projeto **Simulação de Formigueiro Versão HxH: Formiga Quimera**, desenvolvido durante a disciplina de **Inteligência Artificial** da **Universidade Federal do Maranhão (UFMA)**. O projeto utiliza o framework **NetLogo** para modelar um ecossistema complexo onde formigas quimeras do universo Hunter x Hunter.

---

## 🎥 Vídeo de Apresentação

[Youtube: Clique aqui](https://youtu.be/u3gbNbh9V3o)

## 🐜 **Descrição do Projeto**

### **O Formigueiro**

- **Formação Inicial**: O formigueiro surge em um ponto aleatório do mapa, com uma área delimitada.
- **Rainha Quimera**: Uma rainha mutante que consome qualquer ser vivo para adquirir novos genes para prole.
- **Hierarquia das Formigas**:
  - **Soldados**: Vermelho Carmim (#FF2400) - Dano e vida básico.
  - **Capitães**: Laranja Fogo (#FF6A00) - Dano e vida médios.
  - **Generais**: Rosa Fúcsia (#FF00FF) - Dano e vida altos.
  - **Guardas Reais**: Rosa Magenta (#FF007F) - Dano e vida muito altos, com capacidade de reconhecimento de área.
  - **Rei e Rainha**: Amarelo Ouro (#FFC300) - Os mais fortes da colônia.

### **Ciclo de Vida e Evolução**

1. A rainha se alimenta de fontes básicas, gerando formigas vermelhas.
2. Ao invadir aldeias humanas e consumir humanos, a rainha gera **formigas capitãs**.
3. Ao consumir caçadores comuns, a rainha gera **formigas generais**;
4. Quando formigas derrotam **caçadores de elite**, a rainha pode gerar **guardas reais**.
5. Após o nascimento do **terceiro guarda real**, o **rei** surge e a rainha atual morre.
6. O rei precisa encontrar uma nova rainha para criar um novo formigueiro e continuar a espécie.

### **Os Caçadores**

- **Caçadores Comuns**: Azul Royal (#4169E1) - Vida básica.
- **Caçadores de Elite**: Verde Esmeralda (#2ECC71) - Vida muito elevada.
- **Caçadores Lendários**: Turquesa Neon (#40E0D0) - Vida extremamente alta.

À medida que a colônia cresce e ameaça aldeias, caçadores aparecem com força crescente. A dinâmica entre formigas e caçadores é definida por níveis de força, onde apenas formigas mais fortes enfrentam caçadores de igual ou inferior nível.

### **Aldeias**

- Surgem aleatoriamente no mapa e contêm humanos, que são fonte de alimento para a rainha.
- Após atingir um limite de humanos consumidos, caçadores começam a aparecer.

### **Catástrofes**

-- Inicia uma tempestade no inicio da simulação que retira vida das formigas e reposiciona elas.

### **Desafio Final**

- Se um **caçador lendário** encontrar o **rei**, surge a **Rosa dos Pobres**, um evento que extermina todas as quimeras.

---

## 🚀 **Como Rodar o Projeto**

I - Opção 1:

1. Baixe e instale o **NetLogo**.
2. Clone este repositório.
3. Abra o arquivo `.nlogo` no NetLogo.
4. Execute a simulação e observe a evolução do formigueiro e as interações com o ambiente.

II - Opção 2:

1. Acesso site do netlogo e gere um novo arquivo: [Netlogo](https://www.netlogoweb.org/launch#NewModel)

---

## 📚 **Conceitos Aplicados**

- **Modelagem Baseada em Agentes (ABM)**: Simulação de comportamentos individuais para observar fenômenos emergentes.
- **Inteligência Artificial**: Implementação de decisões estratégicas por parte dos agentes.
- **Evolução e Adaptação**: Comportamentos e características dos agentes se ajustam ao ambiente dinâmico.

---

## 🏛 **Universidade Federal do Maranhão (UFMA)**

Disciplina: **Inteligência Artificial**  
Aluno: Gabriel Felipe Carvalho Silva
Aluno: Judson Rodrigues Ciribelli
