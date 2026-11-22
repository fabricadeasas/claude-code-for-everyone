---
name: planejar
description: Planeja uma mudança junto com a pessoa antes de mexer em qualquer coisa, como o modo plano do Claude Code, mas sem pedir permissão a cada ferramenta. Investiga à vontade (lê arquivos, pesquisa na internet, consulta sistemas só para ler), faz perguntas em forma de enquete, apresenta o plano e só começa a fazer depois da aprovação explícita. Use quando a pessoa disser "vamos planejar", "faz um plano", "planeja isso", "quero um plano antes", "modo plano", "não sai fazendo, me mostra antes", "primeiro me apresenta como vai ser", ou invocar `/fabrica-de-asas:planejar`, mesmo sem dizer a palavra skill.
---

# Planejar antes de fazer

É o modo plano do Claude Code, só que sem a trava de permissões. A pessoa costuma trabalhar com as permissões liberadas (bypass permissions), e o modo plano nativo pede autorização para quase toda ferramenta. Esta skill dá a mesma experiência pela conversa: você investiga livremente, conversa, apresenta o plano e **só faz depois do "pode fazer"**.

A trava aqui é você, não o sistema. Nada impede você de editar um arquivo, então a disciplina é total: enquanto o plano não for aprovado, você não muda nada.

**Não chame `EnterPlanMode` nem `ExitPlanMode`.** Eles ligam o modo plano nativo, que é justamente o que a pessoa quer evitar.

## Fase 1: planejamento (nada muda)

### Pode, à vontade e sem pedir licença
- Ler arquivos, procurar no projeto, ver o histórico de versões.
- Pesquisar e ler páginas na internet e documentação.
- Rodar comandos que só olham (`git status`, `git log`, listar pastas, ver versões instaladas, rodar os testes existentes).
- Consultar bancos, painéis e serviços **só para ler** (`SELECT`, listar, ver configuração, ler logs).
- Abrir o site no navegador para ver como está hoje.
- Usar ajudantes (subagentes) para investigar em paralelo.
- Criar rascunhos e protótipos visuais **fora do projeto** (na pasta temporária da conversa) para mostrar como vai ficar.

### Não pode, até a aprovação
- Criar, editar, mover ou apagar arquivos do projeto.
- Instalar ou atualizar programas e pacotes.
- Salvar versão, mandar para o GitHub, publicar.
- Escrever em banco, painel, planilha ou serviço (`INSERT`, `UPDATE`, mudar configuração, criar registro).
- Enviar mensagem, e-mail ou formulário em nome da pessoa.

Se para entender algo for preciso uma ação que muda alguma coisa, pergunte antes e explique o porquê em uma frase.

### Como conduzir
1. **Entenda o pedido.** Repita em uma ou duas frases o que você entendeu.
2. **Investigue antes de perguntar.** Olhe o projeto e pesquise o que for preciso. Não pergunte o que dá para descobrir sozinho.
3. **Pergunte o que só a pessoa sabe**, em forma de enquete com opções (`AskUserQuestion`), com a sua recomendação como primeira opção. Pergunte sobre o resultado que ela quer, não sobre detalhes técnicos: esses são decisão sua. Se uma resposta muda as outras perguntas, pergunte uma de cada vez.
4. **Avalie os caminhos.** Se houver mais de um jeito bom, mostre lado a lado o que cada um ganha e perde, e diga qual você recomenda.
5. **Apresente o plano** (formato abaixo).
6. **Converse.** A pessoa pode pedir ajustes, cortar partes ou mudar de ideia. Refaça o plano e apresente de novo. Repita quantas vezes for preciso.

### O plano
Curto, em linguagem simples, nesta ordem:
- **O que vai mudar na prática**: o que a pessoa vai ver ou poder fazer quando terminar.
- **Os passos**, numerados, um por linha, começando por verbo.
- **O que fica de fora**, se algo foi deixado para depois.
- **Riscos e cuidados**: o que pode dar errado, o que é difícil de desfazer (apagar dados, publicar), e se haverá cópia de segurança antes.
- **Como vou conferir** que funcionou.

Depois do plano, peça a aprovação com uma enquete (`AskUserQuestion`), com as opções "Aprovar e começar" (primeira), "Quero ajustar" e "Cancelar".

## O que vale como aprovação
- Vale: a opção "Aprovar e começar", ou uma resposta clara como "aprovado", "pode fazer", "manda ver", "segue".
- Não vale: "ok", "legal", "faz sentido" ditos no meio da conversa, ou resposta a outra pergunta. Na dúvida, pergunte: "Posso começar a fazer?".
- Aprovação parcial ("faz só os passos 1 e 2") vale só para aquela parte.
- "Cancelar" ou "deixa pra lá": encerre sem mudar nada.

## Fase 2: execução (depois da aprovação)
1. Monte a lista de tarefas com os passos do plano e siga na ordem.
2. Faça o que foi aprovado, nem mais nem menos. Se aparecer algo fora do plano, anote e mostre no final.
3. Se no meio do caminho o plano precisar mudar de verdade (outro caminho, algo destrutivo que não estava previsto, custo novo), **pare**, explique em uma frase e peça aprovação de novo para a mudança. Ajuste pequeno que não muda o resultado não precisa parar.
4. Confira que funcionou, do jeito que o plano disse que conferiria, antes de dizer que terminou.

As outras preferências continuam valendo nas duas fases: verificação com prova, cópia de segurança antes de ação irreversível, e salvar versão só depois de conferir.
