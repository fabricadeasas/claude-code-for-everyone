---
name: versionamento-fundir
description: Junta duas linhas de versões do projeto (git merge) e resolve conflitos para quem não é programador, sem jargão. Use quando for juntar um rascunho (branch) na linha principal, quando um pull ou merge der CONFLICT, quando for juntar um pull request, ou quando a pessoa disser "junta o rascunho", "deu conflito" ou usar as palavras merge, branch ou PR.
---

# Fundir versões

Com a pessoa: um branch é um "rascunho", e fundir é "juntar o rascunho na linha principal". Conflito é "a mesma parte do arquivo mudou nos dois lados".

## Antes de juntar
1. Salve o que estiver pendente (skill `fabrica-de-asas:versionamento-salvar`). Fundir com mudanças não salvas mistura as coisas.
2. Traga as novidades da linha principal (skill `fabrica-de-asas:versionamento-sincronizar`).

## Juntar um rascunho na linha principal
- Se o projeto usa pull requests (a linha principal é protegida no GitHub ou o time revisa antes): `gh pr create` e `gh pr merge`.
- Se não: `git switch <principal>` e `git merge <rascunho>`.
- Se juntar na principal coloca no ar (veja a exceção na skill de sincronizar), junte só quando a pessoa tiver pedido para publicar. Esse pedido já é o ok: não pergunte de novo. Sem ele, o trabalho fica no rascunho.
- Depois de juntar e mandar para a nuvem, apague o rascunho, que já não guarda nada que não esteja na principal: `git branch -d <rascunho>` (o `-d` minúsculo só apaga o que já foi juntado; nunca use `-D`). Se juntou por pull request, use `gh pr merge --merge --delete-branch`, que apaga também o rascunho da nuvem.

## Quando dá conflito
1. Veja quais arquivos têm conflito: `git status`.
2. Abra cada um e entenda os dois lados: o que mudou aqui e o que mudou no outro lado.
3. Se for óbvio como juntar (mudanças em coisas diferentes, uma completa a outra), junte as duas, sem perder nenhuma, e conte em uma frase.
4. Se precisar escolher, mostre as duas opções em linguagem simples (o que cada uma faz na prática) e pergunte. Nunca escolha um lado inteiro às cegas (`-X ours`, `-X theirs`, `--ours`, `--theirs`).
5. Teste o resultado (testes, a tela) antes de concluir. Depois `git add` nos arquivos resolvidos e `git commit`.
6. Se o conflito ficou confuso demais, desista da fusão sem perder nada com `git merge --abort` e explique o que fazer.
