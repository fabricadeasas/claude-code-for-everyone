---
name: versionamento-baixar
description: Baixa para este computador um projeto que já está no GitHub (git clone) para quem não é programador, sem jargão. Use quando a pessoa quiser trabalhar num projeto que está na nuvem mas não neste computador, trocar de computador, pegar um projeto de outra pessoa ou disser "baixa o projeto X", "traz meu projeto do GitHub" ou usar a palavra clone.
---

# Baixar um projeto do GitHub

Para a pessoa: "baixei o projeto do GitHub para este computador, com todas as versões".

## Passo a passo
1. Confira o GitHub CLI: `gh auth status`. Se não estiver instalado, ofereça instalar (Windows: `winget install --id GitHub.cli`; Mac: `brew install gh`). Se não estiver logado, peça para a pessoa rodar `gh auth login` e seguir o navegador: o login é dela, não seu.
2. Descubra qual projeto. Se ela não souber o nome exato, liste os dela (`gh repo list --limit 100`) e confirme qual é.
3. Combine onde guardar. Sugira uma pasta de projetos fora de pastas sincronizadas (Dropbox, OneDrive, iCloud, Google Drive): elas copiam os arquivos internos das versões pela metade e podem estragar o histórico.
4. Se já existe uma pasta com esse projeto neste computador, não baixe por cima: siga a skill `fabrica-de-asas:versionamento-sincronizar` nela.
5. `gh repo clone <dono>/<projeto> "<pasta>"`.
6. Entre na linha de trabalho: `git switch dev` (ou `develop`, se for a que o projeto usa). Se não existir, crie como diz a skill `fabrica-de-asas:versionamento-sincronizar`.
7. Olhe o projeto baixado e avise o que não vem junto: senhas e chaves (`.env`) nunca ficam no GitHub. Se houver um `.env.example` ou instruções no README, ofereça montar o `.env` com ela.
8. Conte em uma linha onde o projeto ficou.
