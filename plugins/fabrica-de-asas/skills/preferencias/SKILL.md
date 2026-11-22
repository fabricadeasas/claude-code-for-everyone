---
name: preferencias
description: Controla as preferências da Fábrica de Asas que o plugin instala. Use quando a pessoa quiser ver, mudar, desligar ou religar as preferências da Fábrica de Asas, escolher como recebe as atualizações (automática, perguntar antes, só quando pedir), trazer ou recusar uma atualização, ver o que mudou numa atualização, ligar a atualização automática do plugin ou remover o plugin. Use também quando o começo da conversa avisar que há uma atualização das preferências.
---

# Preferências da Fábrica de Asas

O plugin guarda as preferências em `~/.claude/rules/fabrica-de-asas/`, uma pasta que o Claude Code lê sozinho no começo de cada conversa. Tudo que muda aqui vale **a partir da próxima conversa**; diga isso à pessoa sempre que mudar algo.

Todos os comandos abaixo usam o mesmo script. Rode com a ferramenta Bash, exatamente assim, trocando só o final:

```bash
CLAUDE_PLUGIN_DATA="${CLAUDE_PLUGIN_DATA}" bash "${CLAUDE_PLUGIN_ROOT}/scripts/preferences.sh" status
```

| Final do comando | Para que serve |
| --- | --- |
| `status` | Mostra se está ligado, o modo de atualização e se há versão nova |
| `diff` | Mostra o que muda entre a versão instalada e a nova |
| `apply` | Traz a versão nova agora |
| `decline` | Não perguntar mais sobre esta versão nova (pergunta de novo na próxima) |
| `on` / `off` | Liga ou desliga todas as preferências da Fábrica de Asas |
| `updates auto` | Atualiza sozinho e avisa (padrão) |
| `updates ask` | Pergunta antes de atualizar |
| `updates manual` | Só atualiza quando a pessoa pedir |

O script responde em linhas técnicas (`state=update-available`). Não mostre isso: traduza em uma frase.

## Quando há uma atualização e a pessoa pediu para ser consultada
1. Pergunte em uma frase se ela quer trazer as novidades agora e ofereça mostrar o que mudou.
2. Se ela quiser ver: rode `diff` e resuma as mudanças em poucas linhas, em linguagem simples (o que você passa a fazer diferente), sem colar o diff.
3. Sim: `apply`. Não: `decline`.

## Mudar uma preferência específica
As preferências da Fábrica de Asas são o padrão; o CLAUDE.md da pessoa vale mais. Para mudar uma só, não edite a pasta do plugin (a atualização apaga): escreva a mudança no CLAUDE.md pessoal dela.
1. Entenda o que ela quer mudar e confirme em uma frase.
2. Abra `~/.claude/CLAUDE.md` (crie se não existir) e acrescente ou atualize a seção `## Minhas mudanças nas preferências da Fábrica de Asas`, com uma linha por mudança, clara o bastante para valer sozinha. Exemplo: `- Não precisa usar Tailwind; uso Bootstrap nos meus projetos.`
3. Não apague nada que já estava no CLAUDE.md dela.
4. Conte o que ficou escrito e que vale a partir da próxima conversa.

Se a mudança valer só para um projeto, escreva no CLAUDE.md da pasta do projeto em vez do pessoal.

## Desligar tudo e usar só as próprias preferências
Rode `off`. A pasta some e passam a valer só os CLAUDE.md da pessoa. As skills do plugin (versionamento) continuam disponíveis; para tirar tudo, veja "Remover o plugin". Para voltar: `on`.

## Atualização do plugin
As novidades da Fábrica de Asas chegam quando o próprio plugin se atualiza. Para marketplaces que não são da Anthropic, isso vem **desligado** de fábrica, então confira:
1. Leia `~/.claude/settings.json` e procure `extraKnownMarketplaces` → `fabricadeasas` → `autoUpdate`.
2. Se não estiver `true`, ofereça ligar. Com o ok, acrescente `"autoUpdate": true` dentro da entrada `fabricadeasas` que já existe, sem mexer no resto do arquivo. Se a entrada não existir, crie:
   ```json
   "extraKnownMarketplaces": {
     "fabricadeasas": {
       "source": { "source": "github", "repo": "fabricadeasas/claude-plugins" },
       "autoUpdate": true
     }
   }
   ```
3. Confira que o arquivo continua sendo um JSON válido depois da edição.

Pelo terminal do Claude Code também dá: `/plugin` → Marketplaces → fabricadeasas → Enable auto-update.

## Remover o plugin
1. Rode `off` primeiro, para a pasta de preferências sair junto.
2. Depois: `claude plugin uninstall fabrica-de-asas@fabricadeasas` (ou `/plugin` → Installed → fabrica-de-asas → Uninstall).

## Se algo não funcionar
- O script precisa do Git instalado (no Windows ele usa o Git Bash). Se `bash` não for encontrado, ajude a instalar o Git (`winget install --id Git.Git`).
- Se o `status` disser `edited_by_hand=yes`, alguém mexeu na pasta de preferências. Explique que a próxima atualização desfaz isso e ofereça passar a mudança para o CLAUDE.md dela.
