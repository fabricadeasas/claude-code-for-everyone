---
name: versionamento-fundir
description: Junta duas linhas de versões do projeto (git merge) e resolve conflitos para quem não é programador, sem jargão. Use quando for juntar um rascunho (branch) na linha de trabalho dev, quando um pull ou merge der CONFLICT, ou quando a pessoa disser "junta o rascunho", "deu conflito" ou usar as palavras merge, branch ou PR. Levar a dev para produção (main) não é aqui: é a skill versionamento-publicar-prod.
---

# Fundir versões

Com a pessoa: um branch é um "rascunho", e fundir é "juntar o rascunho". Conflito é "a mesma parte do arquivo mudou nos dois lados".

A linha de trabalho é a `dev` (ou `develop`). A `main` é produção e só recebe versões pela skill `fabrica-de-asas:versionamento-publicar-prod`: nunca junte nada na `main` por aqui.

## Antes de juntar
1. Salve o que estiver pendente (skill `fabrica-de-asas:versionamento-salvar`). Fundir com mudanças não salvas mistura as coisas.
2. Traga as novidades (skill `fabrica-de-asas:versionamento-sincronizar`).

## Juntar um rascunho na `dev`
- `git switch dev` e `git merge <rascunho>`.
- Se o projeto revisa por pull request antes de juntar na `dev`: `gh pr create --base dev --head <rascunho>` e `gh pr merge --merge`.
- Depois de juntar e mandar para a nuvem, ofereça apagar o rascunho com `git branch -d <rascunho>`. O `-d` minúsculo só apaga o que já foi juntado; nunca use `-D`.

## Quando dá conflito
1. Veja quais arquivos têm conflito: `git status`.
2. Abra cada um e entenda os dois lados: o que mudou aqui e o que mudou no outro lado.
3. Se for óbvio como juntar (mudanças em coisas diferentes, uma completa a outra), junte as duas, sem perder nenhuma, e conte em uma frase.
4. Se precisar escolher, mostre as duas opções em linguagem simples (o que cada uma faz na prática) e pergunte. Nunca escolha um lado inteiro às cegas (`-X ours`, `-X theirs`, `--ours`, `--theirs`).
5. Teste o resultado (testes, a tela) antes de concluir. Depois `git add` nos arquivos resolvidos e `git commit`.
6. Se o conflito ficou confuso demais, desista da fusão sem perder nada com `git merge --abort` e explique o que fazer.
