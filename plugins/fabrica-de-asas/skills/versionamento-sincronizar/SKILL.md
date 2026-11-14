---
name: versionamento-sincronizar
description: Sincroniza as versões do projeto com o GitHub para quem não é programador, sem jargão: primeiro traz as novidades da nuvem (git pull) e depois manda as versões novas (git push), se houver, sempre na linha dev. Use no começo de cada conversa num projeto que tem cópia no GitHub, logo depois de salvar uma versão, quando o projeto ainda não tem cópia na nuvem (criar o repositório) ou ainda não tem a linha dev, quando um pull ou push der erro, ou quando a pessoa disser "manda para o GitHub", "atualiza", "traz o que fiz no outro computador" ou usar as palavras pull, push ou sync.
---

# Sincronizar com a nuvem

Para a pessoa: "trouxe as novidades da nuvem" (pull) e "mandei a cópia para o GitHub" (push). Sempre nessa ordem: primeiro trazer, depois mandar.

## Passo a passo
1. `git remote -v`. Se não houver cópia na nuvem, veja "Sem cópia na nuvem".
2. Garanta que está na linha `dev` (`git branch --show-current`):
   - Já existe `dev` (aqui ou em `origin/dev`): `git switch dev`. As mudanças ainda não salvas vêm junto.
   - Não existe: `git switch -c dev` a partir da `main` e `git push -u origin dev`. Não comente com a pessoa.
   - Se o projeto usa `develop`, troque `dev` por `develop` em tudo.
3. Traga as novidades: `git pull --no-rebase`.
   - `Already up to date` ou deu certo: siga. No começo da conversa, não comente.
   - `CONFLICT`: siga a skill `fabrica-de-asas:versionamento-fundir`.
   - `would be overwritten`: há mudanças ainda não salvas que batem com as novidades. Salve uma versão antes (skill `fabrica-de-asas:versionamento-salvar`) e tente de novo.
4. Se a `main` da nuvem tem versões que a `dev` não tem (`git log --oneline dev..origin/main`), traga também: `git pull --no-rebase origin main`.
5. Se esta pasta tem versões que a nuvem não tem (`git status` diz `ahead`), mande: `git push`. Mandar a `dev` não precisa de confirmação.
6. Se a `dev` tem publicação automática no ambiente de testes (veja a skill `fabrica-de-asas:versionamento-publicar-dev`), o envio já publica lá: acompanhe como diz aquela skill.
7. Conte em uma linha o que aconteceu, sem colar a saída do git.

Nunca mande versões para a `main` por aqui. Produção é só pela skill `fabrica-de-asas:versionamento-publicar-prod`.

## Sem cópia na nuvem
1. Ofereça em uma frase: "Quer guardar uma cópia privada das versões no seu GitHub? Se o computador der problema, nada se perde."
2. Confira o GitHub CLI: `gh auth status`. Se não estiver instalado, ofereça instalar (Windows: `winget install --id GitHub.cli`; Mac: `brew install gh`). Se não estiver logado, peça para a pessoa rodar `gh auth login` e seguir o navegador: o login é dela, não seu.
3. `gh repo create <nome-do-projeto> --private --source=. --remote=origin`.
4. Mande a `main` primeiro (ela vira a linha principal no GitHub) e depois a `dev`: `git push -u origin main` e `git push -u origin dev`.
5. Nunca crie o repositório como público sem a pessoa pedir isso com essas palavras.

## Quando dá erro
| O git diz | O que está acontecendo | O que fazer |
| --- | --- | --- |
| `rejected` / `fetch first` / `non-fast-forward` | A nuvem ganhou versões novas enquanto você trabalhava | Volte ao passo 3 e mande de novo |
| `Authentication failed` / `Permission denied` | Falta login no GitHub | Peça para a pessoa rodar `gh auth login` e acompanhe |
| `Repository not found` | Endereço errado ou sem acesso | Confira `git remote -v` e se a conta logada (`gh auth status`) é a dona do repositório |
| `exceeds GitHub's file size limit` / `large files` | Arquivo grande demais para o GitHub | Tire o arquivo das versões (`git rm --cached`), ponha no `.gitignore`, salve de novo e explique onde guardar arquivos grandes |

Nunca use `git push --force`: o plugin bloqueia, porque ele apaga versões que estão na nuvem.
