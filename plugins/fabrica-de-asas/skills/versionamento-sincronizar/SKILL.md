---
name: versionamento-sincronizar
description: Sincroniza as versões do projeto com o GitHub para quem não é programador, sem jargão. Primeiro traz as novidades da nuvem (git pull) e depois manda as versões novas (git push), se houver. Use no começo de cada conversa num projeto que tem cópia no GitHub, logo depois de salvar uma versão, quando o projeto ainda não tem cópia na nuvem (criar o repositório), quando um pull ou push der erro, ou quando a pessoa disser "manda para o GitHub", "atualiza", "traz o que fiz no outro computador" ou usar as palavras pull, push ou sync.
---

# Sincronizar com a nuvem

Para a pessoa: "trouxe as novidades da nuvem" (pull) e "mandei a cópia para o GitHub" (push). Sempre nessa ordem: primeiro trazer, depois mandar.

## Passo a passo
1. `git remote -v`. Se não houver cópia na nuvem, veja "Sem cópia na nuvem".
2. Traga as novidades: `git pull --no-rebase`.
   - `Already up to date` ou deu certo: siga. No começo da conversa, não comente.
   - `CONFLICT`: siga a skill `fabrica-de-asas:versionamento-fundir`.
   - `would be overwritten`: há mudanças ainda não salvas que batem com as novidades. Salve uma versão antes (skill `fabrica-de-asas:versionamento-salvar`) e tente de novo.
3. Se esta pasta tem versões que a nuvem não tem (`git status` diz `ahead`), mande: `git push`. Antes, veja a exceção abaixo.
4. Conte em uma linha o que aconteceu, sem colar a saída do git.

## Exceção: quando mandar para a nuvem coloca no ar
Alguns projetos publicam sozinhos quando recebem uma versão nova (automação no GitHub, Vercel, Netlify, servidor que puxa da nuvem). Confira antes do primeiro envio: pasta `.github/workflows`, arquivos `vercel.json` ou `netlify.toml`, instruções de publicação no projeto. Se for o caso:
- **Pergunte antes de mandar**: "Mandar para a nuvem vai colocar esta mudança no ar para todo mundo. Posso mandar?"

## Sem cópia na nuvem
1. Ofereça em uma frase: "Quer guardar uma cópia privada das versões no seu GitHub? Se o computador der problema, nada se perde."
2. Confira o GitHub CLI: `gh auth status`. Se não estiver instalado, ofereça instalar (Windows: `winget install --id GitHub.cli`; Mac: `brew install gh`). Se não estiver logado, peça para a pessoa rodar `gh auth login` e seguir o navegador: o login é dela, não seu.
3. `gh repo create <nome-do-projeto> --private --source=. --push`.
4. Nunca crie o repositório como público sem a pessoa pedir isso com essas palavras.

## Quando dá erro
| O git diz | O que está acontecendo | O que fazer |
| --- | --- | --- |
| `rejected` / `fetch first` / `non-fast-forward` | A nuvem ganhou versões novas enquanto você trabalhava | Volte ao passo 2 e mande de novo |
| `Authentication failed` / `Permission denied` | Falta login no GitHub | Peça para a pessoa rodar `gh auth login` e acompanhe |
| `Repository not found` | Endereço errado ou sem acesso | Confira `git remote -v` e se a conta logada (`gh auth status`) é a dona do repositório |
| `exceeds GitHub's file size limit` / `large files` | Arquivo grande demais para o GitHub | Tire o arquivo das versões (`git rm --cached`), ponha no `.gitignore`, salve de novo e explique onde guardar arquivos grandes |

Nunca use `git push --force`: o plugin bloqueia, porque ele apaga versões que estão na nuvem.
