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

## Duas linhas: `dev` para trabalhar, `main` para produção
- Trabalhe sempre na linha `dev`, sem a pessoa pedir e sem comentar. Se o projeto ainda não tem `dev`, crie a partir da `main` (veja a skill de sincronizar). Se o projeto já usa `develop` em vez de `dev`, use a `develop`.
- A `main` (ou `master`) é produção. Ela só recebe versões pela skill `fabrica-de-asas:versionamento-publicar-prod`, que sempre alerta e pede confirmação. Fora a primeira versão de um projeto novo, nunca salve nem mande versões direto na `main`.
- Com a pessoa, fale em "ambiente de testes" e "produção" (ou "no ar"), não em `dev` e `main`.
- Se o CLAUDE.md da pessoa ou do projeto pedir outro jeito de trabalhar com as linhas, vale o dela.

## Skills de versionamento
Use a skill certa sempre que for fazer uma destas operações:

| Operação | Skill |
| --- | --- |
| Salvar uma versão (commit), inclusive a primeira | `fabrica-de-asas:versionamento-salvar` |
| Trazer as novidades e mandar as versões para o GitHub (pull e push), criar a cópia na nuvem | `fabrica-de-asas:versionamento-sincronizar` |
| Baixar um projeto do GitHub para este computador (clone) | `fabrica-de-asas:versionamento-baixar` |
| Juntar um rascunho ou resolver conflito (merge) | `fabrica-de-asas:versionamento-fundir` |
| Publicar no ambiente de testes | `fabrica-de-asas:versionamento-publicar-dev` |
| Publicar em produção (colocar no ar) | `fabrica-de-asas:versionamento-publicar-prod` |

# Quando algo vai ficar disponível para o público
Quando você identificar que algo será disponibilizado para acesso público (site no ar, sistema com usuários de fora, app publicado), siga a skill `fabrica-de-asas:publicar-com-seguranca` e não deixe publicar antes de passar por ela.
