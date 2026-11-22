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
- Trabalhe na linha principal. Só crie um rascunho (branch) se o projeto já trabalha assim, se a pessoa quiser revisar antes de algo ir ao ar, ou se mandar a linha principal para a nuvem coloca no ar sozinho (veja a skill de sincronizar).

## Salvar e publicar: um pedido, o caminho inteiro
- **Salvar** ("salva", "guarda", "salva para eu ver depois") é um passo só: a versão e a cópia no GitHub, sem perguntar nada no meio. Salvar nunca coloca nada no ar: se o projeto vai ao ar sozinho quando a linha principal recebe uma versão, a cópia vai num rascunho (veja a skill de sincronizar).
- **Publicar** ("publica", "coloca no ar", "sobe") é a autorização para todas as etapas até estar no ar e conferido: salvar, juntar o rascunho, mandar, acompanhar a publicação e conferir no site. Não pare para perguntar "posso salvar?", "posso juntar?", "posso mandar?", e não fale em commit, push ou merge.

### Antes de publicar, veja se há para onde
Muita gente diz "publica" querendo dizer "salva". Antes de qualquer coisa, confira se o projeto publica em algum lugar: automação de publicação em `.github/workflows` (que manda o projeto para um servidor, não só roda testes), `vercel.json`, `netlify.toml` ou instruções de publicação no projeto.
- **Não publica em lugar nenhum**: o projeto só guarda o código, então publicar é salvar. Salve (versão e cópia no GitHub) e conte em uma linha: "Este projeto ainda não tem onde ficar no ar, então salvei a versão e a cópia no GitHub."
- **Publica**: aí publicar é publicar mesmo, até o destino.

### Para onde publicar: só com o destino claro
- Destino dito com todas as letras vale como está: "nos testes", "em homologação" é o ambiente de testes; "em produção", "no ar para todo mundo", "para os clientes" é produção.
- Se o projeto tem mais de um destino (ambiente de testes e produção) e a pessoa disse só "publica", "sobe" ou "manda", não suponha. Pergunte o destino, uma vez: "No ambiente de testes ou no ar para todo mundo?". Na dúvida, nunca publique em produção.
- Se há um destino só, "publica" é ele.
- Pare no meio só quando algo impedir de verdade: teste falhando, conflito que pede uma decisão dela, login expirado, ou uma ação destrutiva que não estava no pedido (por exemplo, apagar dados). Diga em que ponto parou e por quê.
- **Nada de ponta solta**: nunca encerre uma tarefa deixando versão salva e não enviada, rascunho não juntado ou pedido de junção (pull request) aberto sem que isso apareça em PENDÊNCIAS, com o link do pedido quando houver, repetido a cada resposta até resolver. Trabalho que eu não sei que ficou parado é trabalho perdido.
- Antes de abrir um pedido de junção no GitHub, veja os meus que já estão abertos naquele projeto (`gh pr list --author @me --state open`). Se algum estiver parado há mais de 7 dias, me avise em uma linha antes de seguir.

## Skills de versionamento
Use a skill certa sempre que for fazer uma destas operações:

| Operação | Skill |
| --- | --- |
| Salvar uma versão e guardar a cópia no GitHub (commit e push), inclusive a primeira | `fabrica-de-asas:versionamento-salvar` |
| Trazer as novidades e mandar as versões para o GitHub (pull e push), criar a cópia na nuvem | `fabrica-de-asas:versionamento-sincronizar` |
| Baixar um projeto do GitHub para este computador (clone) | `fabrica-de-asas:versionamento-baixar` |
| Juntar um rascunho na linha principal ou resolver conflito (merge) | `fabrica-de-asas:versionamento-fundir` |
