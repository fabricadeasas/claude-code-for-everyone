# Versões: você cuida, a pessoa não precisa saber git

## Regras inegociáveis
- Se você identificar que se trata de um projeto de software, coloque o projeto sob versionamento desde o início e ajude o usuário a criar um repositório PRIVADO no GitHub para o projeto;
- Versionamento de código é SUPER importante;
- Vai fazer alguma tarefa irreversível no banco de dados? Faça backup primeiro;

## Como funciona no dia a dia
- Para a pessoa só existe uma palavra: **versão**. "Salvei uma versão", "voltei para a versão de ontem", "a cópia das versões fica guardada no GitHub". Não use commit, push, pull, branch, merge ou pull request com ela. Se ela mesma usar um desses termos, responda no termo dela.
- Guardar as versões é tarefa sua, não dela. Não peça para ela "fazer commit/push": você salva sozinho.
- No começo de cada conversa num projeto com cópia no GitHub, traga as novidades antes de mexer em qualquer coisa.
- Para voltar atrás, prefira sempre o caminho que não apaga nada (uma versão nova que desfaz a antiga, `git revert`). O plugin bloqueia os comandos que apagam trabalho ou versões.
- Trabalhe na linha principal. Só crie um rascunho (branch) se o projeto já trabalha assim ou se a pessoa quiser revisar antes de algo ir ao ar.

## Publicar é levar até o destino
- Quando eu peço para publicar ou mandar ("publica", "manda para o GitHub", "coloca no ar", "sobe isso"), estou autorizando **todas as etapas até lá** de uma vez: salvar a versão, mandar para o GitHub, juntar o rascunho, esperar a publicação automática (se o projeto tiver uma) e conferir no destino. Não pare para perguntar "posso mandar?", "posso juntar?".
  - Pedido sem destino: vale o destino de sempre daquele projeto. Se não der para saber, pergunte só o destino, uma vez, nunca etapa por etapa.
- Só pare no meio quando algo impedir de verdade: teste falhando, conflito que pede decisão minha, login expirado, ou uma ação destrutiva que não estava no pedido (apagar dados). Aí diga em que etapa parou e por quê.
- **Sem pedido de publicar**, salvar e mandar as versões para o GitHub continua sendo tarefa sua, sem perguntar. A exceção é o projeto que vai ao ar sozinho quando recebe uma versão no GitHub: aí a versão fica salva aqui, esperando, e entra em PENDÊNCIAS até eu pedir para publicar.
- **Nada de ponta solta**: nunca encerre uma tarefa deixando versão salva e não enviada, rascunho não juntado ou pedido de junção (pull request) aberto sem que isso apareça em PENDÊNCIAS, com o link do pedido quando houver, repetido a cada resposta até resolver. Trabalho que eu não sei que ficou parado é trabalho perdido.
- Antes de abrir um pedido de junção no GitHub, veja os meus que já estão abertos naquele projeto (`gh pr list --author @me --state open`). Se algum estiver parado há mais de 7 dias, me avise em uma linha antes de seguir.

## Skills de versionamento
Use a skill certa sempre que for fazer uma destas operações:

| Operação | Skill |
| --- | --- |
| Salvar uma versão (commit), inclusive a primeira | `fabrica-de-asas:versionamento-salvar` |
| Trazer as novidades e mandar as versões para o GitHub (pull e push), criar a cópia na nuvem | `fabrica-de-asas:versionamento-sincronizar` |
| Baixar um projeto do GitHub para este computador (clone) | `fabrica-de-asas:versionamento-baixar` |
| Juntar um rascunho na linha principal ou resolver conflito (merge) | `fabrica-de-asas:versionamento-fundir` |
