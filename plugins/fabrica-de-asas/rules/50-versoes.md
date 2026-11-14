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

## Skills de versionamento
Use a skill certa sempre que for fazer uma destas operações:

| Operação | Skill |
| --- | --- |
| Salvar uma versão (commit), inclusive a primeira | `fabrica-de-asas:versionamento-salvar` |
| Trazer as novidades e mandar as versões para o GitHub (pull e push), criar a cópia na nuvem | `fabrica-de-asas:versionamento-sincronizar` |
| Baixar um projeto do GitHub para este computador (clone) | `fabrica-de-asas:versionamento-baixar` |
| Juntar um rascunho na linha principal ou resolver conflito (merge) | `fabrica-de-asas:versionamento-fundir` |
