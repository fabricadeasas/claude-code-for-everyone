---
name: versionamento-salvar
description: Salva uma versão do projeto (git commit) para quem não é programador, sem jargão. Use sempre que for fazer um commit, depois de terminar e verificar uma mudança, antes de uma mudança grande ou arriscada, quando a pasta ainda não guarda versões (git init), ou quando a pessoa disser "salva isso", "guarda uma versão", "salva como está" ou usar a palavra commit.
---

# Salvar uma versão

Para a pessoa, salvar uma versão é tirar uma foto do projeto como está agora, para poder voltar a ela depois. Você faz isso sozinho, sem pedir que ela faça.

## Quando salvar (sem perguntar)
- Depois de cada mudança que você fez **e verificou** (testes passaram, a tela funcionou). Mudança não verificada não vira versão.
- Antes de uma mudança grande, arriscada ou destrutiva: salve o estado atual primeiro, para dar para voltar.
- Uma versão por assunto. Se a pasta tem mudanças de assuntos diferentes, salve uma versão para cada.

## Como salvar
1. Veja o que mudou e em que linha está: `git status`. Versões são salvas na linha `dev`, nunca na `main` (produção). Se estiver na `main`, passe para a `dev` antes (`git switch dev`, ou `git switch -c dev` se ela ainda não existe); as mudanças não salvas vêm junto.
2. Confira que nada secreto ou pesado vai entrar: `.env` e arquivos com senha ou chave, `node_modules`, `vendor`, pastas de build, `backups`, banco local, vídeos e planilhas grandes. O que não deve entrar vai para o `.gitignore`.
3. Adicione os arquivos do assunto (`git add <arquivos>`). Evite `git add -A` sem ter olhado o `git status`.
4. `git commit -m "<descrição>"`. A descrição é curta, no idioma da pessoa (a não ser que o CLAUDE.md dela peça outro), e diz o que mudou na prática ("Formulário de contato envia e-mail para o dono"), não o que mudou no código.
5. Mande a cópia para a nuvem seguindo a skill `fabrica-de-asas:versionamento-sincronizar`.
6. Conte em uma linha: "Salvei uma versão: <descrição>." Não cole a saída do git.

## Primeira vez numa pasta sem versões
Se `git status` disser `not a git repository` e for um projeto de software:
1. Peça o ok em uma frase: "Quer que eu comece a guardar as versões deste projeto? Assim dá para voltar atrás sempre que precisar."
2. Crie o `.gitignore` antes de tudo, com o que está no passo 2 acima.
3. `git init -b main` e salve a primeira versão na `main`.
4. Crie a linha de trabalho: `git switch -c dev`. Daqui em diante, tudo é salvo na `dev`.
5. Para a cópia na nuvem, siga a skill `fabrica-de-asas:versionamento-sincronizar`.

## Se o git pedir nome e e-mail
`Please tell me who you are`: pergunte o nome e o e-mail que a pessoa usa no GitHub e configure com `git config --global user.name` e `git config --global user.email`.
