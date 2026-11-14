# Preferências da Fábrica de Asas

Os arquivos desta pasta são as preferências padrão do curso Superpoderes com IA, da Fábrica de Asas. O plugin `fabrica-de-asas` coloca e atualiza esta pasta sozinho.

## Quando valem
- Siga estes arquivos só quando o contexto da conversa trouxer a marca `FABRICA_DE_ASAS_ATIVO`. O plugin coloca essa marca no começo de cada conversa.
- Sem a marca, o plugin foi desligado ou removido. Ignore esta pasta e avise a pessoa uma vez que ela pode ser apagada: `~/.claude/rules/fabrica-de-asas/`.

## O que vale mais
- Isto é o padrão. Se o CLAUDE.md da pessoa (o pessoal, em `~/.claude/CLAUDE.md`, ou o do projeto) disser algo diferente sobre o mesmo assunto, vale o CLAUDE.md dela.
- Não edite os arquivos desta pasta: a próxima atualização apaga a edição. Quando a pessoa quiser mudar ou desligar uma preferência, use a skill `fabrica-de-asas:preferencias`, que grava a mudança no CLAUDE.md dela.
