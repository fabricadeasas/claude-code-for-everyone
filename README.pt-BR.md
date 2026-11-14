# Claude Code para todos

[English](README.md) · **Português (Brasil)**

O Claude Code vem configurado de fábrica para conversar com programadores. Ele responde em jargão e parte do princípio de que você sabe o que pedir: teste automatizado, controle de acesso, proteção contra injeção de SQL, backup antes de mexer no banco.

Quem não programa não sabe que essas coisas existem, então nunca pede. Este pacote resolve os dois lados do problema com dois arquivos de texto:

- **Estilo de comunicação** (`linguagem-simples.md`): o Claude passa a explicar em linguagem do dia a dia, sem jargão, dizendo o que mudou na prática e não que código mudou.
- **Diretrizes** (`CLAUDE.md`): o Claude passa a seguir as boas práticas de engenharia sozinho, sem que você peça, como um engenheiro de software faria. Ele vira a sua equipe de desenvolvimento, e você é o chefe.

## Para quem é

Para quem usa o Claude Code para construir ou manter um sistema sem ser da área: dono de negócio, analista, profissional de outra área que aprendeu a pedir as coisas para a IA. Se você é programador, também funciona, mas as diretrizes foram escritas pensando em quem não sabe o que cobrar.

## Jeito mais fácil: o plugin

O plugin `fabrica-de-asas` instala tudo sozinho e mantém atualizado. Você não copia nem edita arquivo nenhum.

Por enquanto, o plugin existe só em português.

| O que ele traz | Na prática |
| --- | --- |
| **Preferências que se atualizam** | As diretrizes e o jeito de falar chegam e se renovam sem você mexer em nada |
| **Versões sem jargão** | O Claude salva as versões do seu projeto e manda a cópia para o GitHub sozinho. Você só ouve falar em "versão". Também dá para pedir direto: `/fabrica-de-asas:versionamento-salvar`, `-sincronizar`, `-baixar` e `-fundir` |
| **Publicar sem susto** | O Claude trabalha numa versão de testes. Produção só recebe mudanças com um alerta e o seu ok (`/fabrica-de-asas:versionamento-publicar-prod`). Se o projeto ainda não tem servidor configurado no GitHub, ele avisa que não há o que publicar |
| **Trava de segurança** | Comandos que apagariam versões ou mandariam senhas para a nuvem são bloqueados antes de rodar |
| **Você no controle** | Mude uma preferência, desligue todas, ou escolha se as atualizações chegam sozinhas, com pergunta, ou só quando você pedir |

### Como instalar

No Claude Code, digite:

```
/plugin install fabrica-de-asas --marketplace fabricadeasas/claude-code-for-everyone
```

Precisa do Claude Code 2.1.275 ou mais novo. Em versões anteriores, são dois comandos:

```
/plugin marketplace add fabricadeasas/claude-code-for-everyone
/plugin install fabrica-de-asas@fabricadeasas
```

Também dá para pedir para o próprio Claude: "Instale o plugin fabrica-de-asas do marketplace fabricadeasas/claude-code-for-everyone e ligue a atualização automática dele."

As preferências passam a valer **a partir da segunda conversa**: na primeira, o plugin só as coloca no lugar.

Requisito: Git instalado. No Windows, o plugin usa o Git Bash, que vem junto com o Git.

### Atualização automática

O Claude Code vem com a atualização automática desligada para plugins que não são da Anthropic. Para receber as novidades sozinho, ligue uma vez: peça ao Claude "ligue a atualização automática do plugin da Fábrica de Asas", ou use `/plugin` → Marketplaces → fabricadeasas → Enable auto-update.

### Ajustar ou desligar

Converse com o Claude, sem decorar comando:

- "Quero mudar uma preferência da Fábrica de Asas": ele grava a mudança no seu `CLAUDE.md`, que sempre vale mais que o padrão do plugin.
- "Desliga as preferências da Fábrica de Asas": passam a valer só as suas.
- "Me pergunta antes de atualizar as preferências" ou "só atualiza quando eu pedir".

### Como funciona por dentro

```
.claude-plugin/marketplace.json           catálogo (o "marketplace" fabricadeasas)
plugins/fabrica-de-asas/rules/            as preferências, em arquivos curtos por assunto
plugins/fabrica-de-asas/skills/           versionamento-*, publicar com segurança, controle das preferências
plugins/fabrica-de-asas/hooks/hooks.json  gatilhos: início de conversa e trava do git
plugins/fabrica-de-asas/scripts/          o que os gatilhos executam
```

No começo de cada conversa, o plugin copia as preferências para `~/.claude/rules/fabrica-de-asas/`, pasta que o Claude Code lê sozinho e sem limite de tamanho. As suas escolhas (ligado ou desligado, modo de atualização) ficam guardadas na pasta de dados do plugin, que sobrevive às atualizações.

## Instalação manual (sem plugin)

```
pt-BR/CLAUDE.md               diretrizes de engenharia (português)
pt-BR/linguagem-simples.md    estilo de comunicação (português)
en/CLAUDE.md                  diretrizes de engenharia (inglês)
en/plain-language.md          estilo de comunicação (inglês)
```

Escolha a pasta do seu idioma. O conteúdo é o mesmo nas duas; só a língua muda. Do jeito manual, as atualizações não chegam sozinhas.

Os dois arquivos vão para a sua pasta pessoal do Claude, e por isso valem para todos os seus projetos. `~` é a sua pasta de usuário:

| Sistema | Pasta |
| --- | --- |
| Windows | `C:\Users\seu-nome\.claude\` |
| Mac | `/Users/seu-nome/.claude/` |
| Linux | `/home/seu-nome/.claude/` |

Se a pasta `.claude` não existir, crie.

### 1. Estilo de comunicação

Copie `linguagem-simples.md` para `~/.claude/output-styles/` (crie a pasta se precisar). Depois abra `~/.claude/settings.json` e aponte para o estilo pelo nome que está no campo `name` do arquivo:

```json
{
  "outputStyle": "Linguagem simples"
}
```

Vale a partir da próxima sessão (ou depois de `/clear`).

### 2. Diretrizes

Copie `CLAUDE.md` para `~/.claude/CLAUDE.md`. Se você já tem um `CLAUDE.md` ali, acrescente o conteúdo ao que já existe em vez de substituir.

## A armadilha que quase todo mundo cai

Por padrão, um estilo de resposta customizado apaga as instruções de engenharia de software do Claude Code (revisar o próprio trabalho, cuidar do escopo da mudança, verificar o que fez). Ou seja: ele passa a falar bonito e a programar pior.

A linha `keep-coding-instructions: true` no cabeçalho do estilo é o que evita isso. Ela mantém a competência técnica intacta e muda só o jeito de falar. Se você adaptar o arquivo, não tire essa linha.

## O que isto não garante

Isto é orientação, não trava. Aumenta muito a chance de o padrão aparecer, mas não é garantia determinística: em conversa muito longa, ou depois de uma compactação de contexto, alguma regra pode escapar. Para o que precisa ser garantido de verdade, existem os hooks do Claude Code, que rodam fora do modelo.

E o aviso mais importante: isto eleva o piso, não substitui você. Ter os arquivos não é motivo para parar de perguntar ou aceitar tudo sem ler. Se não entendeu uma decisão, peça para explicarem de novo.

## Documentos vivos

Estes arquivos vão continuar sendo ajustados conforme a prática mostrar o que funciona: regra que o Claude ignora sai, regra que faltava entra, redação confusa é reescrita. Acompanhe o repositório para receber as versões novas. Se você adaptou o texto para o seu caso, guarde as suas mudanças separadas, assim fica fácil reaplicá-las por cima da versão nova.

## Idiomas

O português é a fonte. O inglês é gerado a partir dele automaticamente, e um verificador no CI garante que os dois nunca fiquem diferentes: se um arquivo em português muda, o build quebra até a tradução ser regenerada; se alguém edita a tradução na mão, o build quebra também.

Para contribuir, edite só os arquivos em `pt-BR/` (ou `README.pt-BR.md`) e rode:

```bash
npm run translate
```

O comando usa o Claude Code da sua máquina (`claude -p`, precisa estar logado) para traduzir, confere bloco a bloco que a tradução tem a mesma estrutura do original e atualiza o `translations.lock.json`. Para conferir sem gerar nada, `npm run check`.

## Sobre

Criado por [Guilherme Almeida Girardi](https://github.com/ggirardi1) como parte do curso Superpoderes com IA, da [Fábrica de Asas](https://fabricadeasas.com.br). Licença MIT.
