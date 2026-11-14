# Claude Code for everyone

**English** · [Português (Brasil)](README.pt-BR.md)

Out of the box, Claude Code is set up to talk to programmers. It answers in jargon and assumes you know what to ask for: automated tests, access control, SQL injection protection, a backup before touching the database.

People who don't program don't know these things exist, so they never ask for them. This package solves both sides of the problem with two text files:

- **Communication style** (`plain-language.md`): Claude starts explaining in everyday language, without jargon, telling you what changed in practice and not what code changed.
- **Guidelines** (`CLAUDE.md`): Claude starts following good engineering practices on its own, without you asking, the way a software engineer would. It becomes your development team, and you're the boss.

## Who it's for

For anyone who uses Claude Code to build or maintain a system without being from the field: business owners, analysts, professionals from other areas who learned to ask AI for things. If you're a programmer, it works too, but the guidelines were written with people who don't know what to demand in mind.

## Easiest way: the plugin

The `fabrica-de-asas` plugin installs everything on its own and keeps it up to date. You don't copy or edit any file.

For now, the plugin is only available in Portuguese.

| What it brings | In practice |
| --- | --- |
| **Preferences that update themselves** | The guidelines and the way of talking arrive and get refreshed without you touching anything |
| **Versions without jargon** | Claude saves the versions of your project and sends the copy to GitHub on its own. You only hear the word "version". You can also ask directly: `/fabrica-de-asas:versionamento-salvar`, `-sincronizar`, `-baixar` and `-fundir` |
| **Publishing without scares** | Claude works on a test version. Production only gets changes after a warning and your ok (`/fabrica-de-asas:versionamento-publicar-prod`). If the project doesn't have a server set up on GitHub yet, it tells you there's nothing to publish |
| **Safety lock** | Commands that would delete versions, send passwords to the cloud or change production without going through the test version are blocked before they run |
| **You're in control** | Change a preference, turn them all off, or choose whether updates arrive on their own, with a question, or only when you ask |

### How to install

In Claude Code, type:

```
/plugin install fabrica-de-asas --marketplace fabricadeasas/claude-code-for-everyone
```

It needs Claude Code 2.1.275 or newer. In earlier versions, it takes two commands:

```
/plugin marketplace add fabricadeasas/claude-code-for-everyone
/plugin install fabrica-de-asas@fabricadeasas
```

You can also ask Claude itself: "Install the fabrica-de-asas plugin from the fabricadeasas/claude-code-for-everyone marketplace and turn on its automatic updates."

The preferences take effect **starting with the second conversation**: in the first one, the plugin only puts them in place.

Requirement: Git installed. On Windows, the plugin uses Git Bash, which comes with Git.

### Automatic updates

Claude Code ships with automatic updates turned off for plugins that aren't from Anthropic. To get new versions on your own, turn it on once: ask Claude "turn on automatic updates for the Fábrica de Asas plugin", or use `/plugin` → Marketplaces → fabricadeasas → Enable auto-update.

### Adjust or turn off

Talk to Claude, no commands to memorize:

- "I want to change a Fábrica de Asas preference": it writes the change to your `CLAUDE.md`, which always outweighs the plugin's default.
- "Turn off the Fábrica de Asas preferences": only yours apply from then on.
- "Ask me before updating the preferences" or "only update when I ask".

### How it works inside

```
.claude-plugin/marketplace.json           catálogo (o "marketplace" fabricadeasas)
plugins/fabrica-de-asas/rules/            as preferências, em arquivos curtos por assunto
plugins/fabrica-de-asas/skills/           versionamento-*, publicar com segurança, controle das preferências
plugins/fabrica-de-asas/hooks/hooks.json  gatilhos: início de conversa e trava do git
plugins/fabrica-de-asas/scripts/          o que os gatilhos executam
```

At the start of each conversation, the plugin copies the preferences to `~/.claude/rules/fabrica-de-asas/`, a folder Claude Code reads on its own and with no size limit. Your choices (on or off, update mode) are kept in the plugin's data folder, which survives updates.

## Manual installation (no plugin)

```
pt-BR/CLAUDE.md               diretrizes de engenharia (português)
pt-BR/linguagem-simples.md    estilo de comunicação (português)
en/CLAUDE.md                  diretrizes de engenharia (inglês)
en/plain-language.md          estilo de comunicação (inglês)
```

Pick the folder for your language. The content is the same in both; only the language changes. With the manual route, updates don't arrive on their own.

Both files go into your personal Claude folder, so they apply to all your projects. `~` is your user folder:

| System | Folder |
| --- | --- |
| Windows | `C:\Users\seu-nome\.claude\` |
| Mac | `/Users/seu-nome/.claude/` |
| Linux | `/home/seu-nome/.claude/` |

If the `.claude` folder doesn't exist, create it.

### 1. Communication style

Copy `plain-language.md` to `~/.claude/output-styles/` (create the folder if needed). Then open `~/.claude/settings.json` and point to the style by the name in the file's `name` field:

```json
{
  "outputStyle": "Plain language"
}
```

It takes effect from the next session (or after `/clear`).

### 2. Guidelines

Copy `CLAUDE.md` to `~/.claude/CLAUDE.md`. If you already have a `CLAUDE.md` there, add the content to what's already there instead of replacing it.

## The trap almost everyone falls into

By default, a custom response style wipes out Claude Code's software engineering instructions (reviewing its own work, keeping the scope of the change in check, verifying what it did). In other words: it starts talking nicely and programming worse.

The `keep-coding-instructions: true` line in the style's header is what prevents this. It keeps the technical competence intact and changes only the way it talks. If you adapt the file, don't remove that line.

## What this doesn't guarantee

This is guidance, not a lock. It greatly increases the chance the standard shows up, but it isn't a deterministic guarantee: in a very long conversation, or after a context compaction, some rule may slip through. For what truly needs to be guaranteed, there are Claude Code hooks, which run outside the model.

And the most important warning: this raises the floor, it doesn't replace you. Having the files is no reason to stop asking questions or to accept everything without reading. If you didn't understand a decision, ask for it to be explained again.

## Living documents

These files will keep being adjusted as practice shows what works: rules Claude ignores come out, missing rules go in, confusing wording gets rewritten. Follow the repository to get the new versions. If you adapted the text for your case, keep your changes separate, so it's easy to reapply them on top of the new version.

## Languages

Portuguese is the source. English is generated from it automatically, and a checker in CI makes sure the two never drift apart: if a Portuguese file changes, the build breaks until the translation is regenerated; if someone edits the translation by hand, the build breaks too.

To contribute, edit only the files in `pt-BR/` (or `README.pt-BR.md`) and run:

```bash
npm run translate
```

The command uses the Claude Code on your machine (`claude -p`, you need to be logged in) to translate, checks block by block that the translation has the same structure as the original, and updates `translations.lock.json`. To check without generating anything, `npm run check`.

## About

Created by [Guilherme Almeida Girardi](https://github.com/ggirardi1) as part of the Superpoderes com IA course, from [Fábrica de Asas](https://fabricadeasas.com.br). MIT License.
