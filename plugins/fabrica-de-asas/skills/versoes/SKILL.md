---
name: versoes
description: Cuida das versões do projeto (git e GitHub) para quem não é programador, sem jargão. Use sempre que for salvar ou guardar uma versão, buscar as novidades da nuvem, voltar atrás, ver o que mudou, criar o repositório no GitHub, começar a trabalhar num projeto que tem git, ou quando um comando git der erro. Use também quando a pessoa disser coisas como "salva isso", "volta como estava", "perdi o que fiz", "manda para o GitHub", "o que mudou desde ontem", ou usar as palavras commit, push, pull, branch ou PR.
---

# Versões sem jargão

A pessoa não sabe git e não precisa saber. Você faz o trabalho de git sozinho e conversa com ela em uma só palavra: **versão**.

## Vocabulário com a pessoa

| Você faz | Você diz |
| --- | --- |
| `git add` + `git commit` | "salvei uma versão" |
| `git push` | "mandei a cópia para o GitHub" (a nuvem) |
| `git pull` | "trouxe as novidades da nuvem" |
| `git revert` | "voltei para como estava, e a versão de agora continua guardada" |
| `git log` | "estas foram as últimas versões" |
| repositório no GitHub | "a cópia das versões na nuvem" |

Nunca cole a saída do git na resposta. Traduza o que aconteceu em uma frase.

## No começo de cada conversa num projeto
1. Veja se a pasta tem versões (`git status`). Se não tiver e for um projeto de software, ofereça começar (veja "Primeira vez").
2. Se tiver cópia na nuvem, traga as novidades sem perguntar: `git pull --ff-only`. Se der certo, não comente. Se não der, veja "Quando dá erro".

## Quando salvar uma versão (sem perguntar)
- Depois de cada mudança que você fez **e verificou** (testes passaram, a tela funcionou). Mudança não verificada não vira versão.
- Antes de uma mudança grande, arriscada ou destrutiva, salve o estado atual primeiro. Assim dá para voltar.
- Uma versão por assunto. A descrição da versão é curta, no idioma da pessoa, e diz o que mudou na prática ("Formulário de contato envia e-mail para o dono"), não o que mudou no código.
- Depois de salvar, mande a cópia para a nuvem (`git push`). Conte para a pessoa em uma linha: "Salvei uma versão e mandei a cópia para o GitHub."

### Exceção: quando mandar para a nuvem coloca no ar
Alguns projetos publicam sozinhos quando recebem uma versão nova (automação no GitHub, Vercel, Netlify, servidor que puxa da nuvem). Confira antes do primeiro envio: pasta `.github/workflows`, arquivos `vercel.json` ou `netlify.toml`, instruções de publicação no projeto. Se for o caso:
- Salve a versão normalmente, mas **pergunte antes de mandar**: "Mandar para a nuvem vai colocar esta mudança no ar para todo mundo. Posso mandar?"
- Siga a skill `fabrica-de-asas:publicar-com-seguranca` antes do primeiro envio que publica.

## Primeira vez num projeto
1. Explique em uma frase e peça o ok: "Quer que eu comece a guardar as versões deste projeto? Fica uma cópia privada no seu GitHub, e dá para voltar atrás sempre que precisar."
2. Antes de salvar a primeira versão, crie ou confira o `.gitignore`. Ficam de fora: `.env` e qualquer arquivo com senha ou chave, `node_modules`, `vendor`, pastas de build, `backups`, arquivos de banco local e arquivos muito grandes (vídeos, planilhas pesadas). Na dúvida sobre um arquivo, pergunte.
3. `git init`, primeira versão.
4. Para a cópia na nuvem, use o GitHub CLI: confira `gh auth status`. Se não estiver logado, peça para a pessoa rodar `gh auth login` e seguir o navegador (o login é dela, não seu). Depois: `gh repo create <nome-do-projeto> --private --source=. --push`.
5. Se o `gh` não estiver instalado, ofereça instalar (Windows: `winget install --id GitHub.cli`; Mac: `brew install gh`).
6. Nunca crie o repositório como público sem a pessoa pedir isso com essas palavras.

## Voltar atrás
- **Desfazer algo que já virou versão**: `git revert <versão>`. Cria uma versão nova que desfaz a antiga; nada se perde.
- **Trazer um arquivo como estava antes**: salve a versão atual primeiro, depois `git restore --source=<versão> -- <arquivo>` e salve de novo.
- **Ver o que mudou**: `git log` e `git diff`, e conte em linguagem simples, por data e assunto.
- Nunca use `git reset --hard`, `git push --force`, `git clean -f`, `git stash drop` ou `git branch -D`. O plugin bloqueia esses comandos, porque eles apagam trabalho sem volta.

## Níveis de risco
1. **Faça sem perguntar**: salvar versão, mandar para a nuvem (fora a exceção acima), trazer novidades, ver histórico.
2. **Avise e faça**: criar o repositório privado, voltar atrás com `git revert`, resolver um conflito simples.
3. **Só com ok explícito, depois de explicar a consequência**: qualquer coisa que mexe em versões que já estão na nuvem, mudar o repositório para público, apagar o repositório. Prefira sempre o caminho que não apaga nada.

## Quando dá erro
Diga o que aconteceu em uma frase, resolva você mesmo quando der, e só peça algo à pessoa quando for coisa dela (login, senha, decisão).

| O git diz | O que está acontecendo | O que fazer |
| --- | --- | --- |
| `rejected` / `fetch first` / `non-fast-forward` | A nuvem tem versões que esta pasta não tem (mudou em outro computador) | `git pull --no-rebase`, resolver se houver conflito, mandar de novo |
| `CONFLICT` | A mesma parte do arquivo mudou em dois lugares | Abra o arquivo e junte as duas mudanças. Se for óbvio, resolva e conte. Se precisar escolher, mostre as duas opções em linguagem simples e pergunte |
| `Authentication failed` / `Permission denied` / `gh auth` | Falta login no GitHub | Peça para a pessoa rodar `gh auth login` e acompanhe |
| `Repository not found` | Endereço errado ou sem acesso | Confira `git remote -v` e se a conta logada é a dona do repositório |
| `file exceeds GitHub's file size limit` / `large files` | Arquivo grande demais para o GitHub | Tire o arquivo das versões, ponha no `.gitignore` e explique onde guardar arquivos grandes |
| `not a git repository` | A pasta ainda não guarda versões | Veja "Primeira vez" |
| `detached HEAD` | A pasta está olhando uma versão antiga | Volte para a linha principal (`git switch -`) sem perder nada; se houver mudanças, salve antes numa linha nova |
| `Please tell me who you are` | Falta o nome e e-mail nas versões | Pergunte o nome e o e-mail do GitHub e configure (`git config --global user.name` / `user.email`) |

## Linhas de trabalho (branches)
Trabalhe na linha principal. Só crie outra linha se o projeto já usa esse jeito de trabalhar ou se mandar para a principal coloca no ar e a pessoa quiser revisar antes. Nesse caso, chame de "rascunho" com ela e explique em uma frase quando for juntar.
