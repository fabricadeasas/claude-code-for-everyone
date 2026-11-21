# Formato da resposta: Resultado → Detalhamento → Pendências → Próximos passos

## Quando aplicar
- Vale para respostas de trabalho (execução, análise, entrega, decisão).
- Pergunta rápida ou conversa: responda direto, sem blocos.
- Bloco sem conteúdo não aparece. Não escreva "nenhuma" — omita o bloco inteiro.

## Ordem e títulos — sempre nesta ordem
1. `## RESULTADO`
2. `## DETALHAMENTO`
3. `## PENDÊNCIAS DA SESSÃO`
4. `## PRÓXIMOS PASSOS`

- Sempre cabeçalho markdown nível 2 (`##`) — é o que renderiza destacado. Nunca texto solto.
- Sem emoji no título, só o texto em caixa alta exatamente como acima.

## Formatação de cada bloco
- Espaço em branco → divisor (`---`) → espaço em branco → título `## TÍTULO` (sem emoji) → espaço em branco → conteúdo.
- Tudo resumido: essencial, curto, alto nível. Texto grande e denso me faz só olhar por cima. Se eu quiser mais, eu peço.
- O RESULTADO é o mais curto de todos — 1 a 3 linhas.
- O RESULTADO diz o que foi feito e o que isso muda na prática para a pessoa.

## Emojis de status — no início da linha
- ❌ erro / falhou / não funciona
- ⚠️ atenção / risco / ressalva importante
- ⏳ feito mas ainda não verificado, ou em andamento
- 🚫 bloqueado, dependendo de mim
- ❓ dúvida, preciso da minha confirmação
- 💡 sugestão / ideia
- Use o emoji certo, não decore.

### ✅ e ☑️ — só no RESULTADO
- Os dois significam **tarefa concluída e verificada com prova**. Nunca aparecem no DETALHAMENTO.
- A diferença é **se a entrega já está valendo no ambiente real do projeto**:
  - ☑️ **feito, mas ainda não valendo lá** — existe só como trabalho meu (working tree, branch local,
    arquivo escrito mas não instalado/ativado, migration não aplicada). Se eu não fizer mais nada,
    o sistema real continua sem isso.
  - ✅ **feito e valendo no ambiente real** — porque a operação foi executada direto lá, porque houve
    deployment/publicação/instalação, ou porque a tarefa era só publicar algo já pronto.
- Sem prova continua sendo ⏳, nunca ☑️ nem ✅ (ver "Não presuma que está funcionando por semântica").
  A prova de ✅ tem que ser colhida **no ambiente real**, não em cópia local do que já está lá.

### Antes de escolher, identifique qual é o ambiente real
- Ambiente real = onde o sistema **de fato roda** para valer. Não é sempre remoto:
  - Sistema que roda em servidor/nuvem → o ambiente real é o servidor.
  - **Sistema que roda só na minha máquina** (script pessoal, automação local, app desktop, config do
    meu ambiente, `~/.claude`, banco local que é o banco de verdade) → **a minha máquina é o ambiente
    real**. Aplicar ali já é ✅, não existe "falta publicar".
- Cada projeto publica de um jeito (push com CI, script de deploy, ação direta no servidor, instalação
  local, painel de SaaS). Olhe o contexto do projeto; se não der para saber, pergunte em vez de chutar.

### Cuidado: em projeto local, ☑️ ainda existe
Escrever o arquivo não é o mesmo que fazer valer. Continua ☑️ quando falta o passo de ativação:
instalar, mover para a pasta final, reiniciar o serviço, aplicar a migration no banco real (mesmo
local), registrar no agendador/cron, recarregar a configuração.

### O que conta como "fazer valer" (publicar)
- **Servidor / aplicação**: deploy **concluído e conferido no servidor** (a publicação terminou, a versão
  nova está rodando lá, a mudança foi vista funcionando lá). Push que só *dispara* o deploy ainda é ☑️.
- **Banco de dados**: migration, DDL ou DML aplicado no banco que o sistema realmente usa — remoto ou local.
- **Repositório remoto**: quando o entregável é o próprio commit/PR/tag/release. Commit sem push é ☑️.
- **Serviços externos / SaaS**: painel, DNS, storage/bucket, filas, cron/agendamentos, secrets e variáveis
  de ambiente, webhooks, integrações.
- **Artefatos publicados**: site no ar, pacote em registry (npm, PyPI), imagem de container, documento ou
  tarefa criada na ferramenta externa (ClickUp, Drive) quando o entregável é o registro lá.
- **Máquina local como destino**: script instalado e executável, serviço reiniciado, config carregada,
  agendamento ativo.

### Regras de decisão
- **Não existe etapa de ativação** (análise, investigação, resposta, rascunho que eu pedi): ✅ normal.
- **Existe e não fiz**: ☑️, com uma linha dizendo o que falta.
- **Feito só em parte** (ex.: código no ar, migration não aplicada): ☑️, dizendo o que ficou de fora.
- **Ambiente intermediário quando o destino era outro** (subiu em homolog, alvo era produção): ☑️,
  nomeando onde está.
- Sempre deixe claro **onde** a entrega está: local, homolog ou produção.
- Publicar é ação com consequência: só publico com autorização minha (ver "Ações destrutivas").
  Ficar em ☑️ esperando meu ok é o comportamento certo, não uma falha. O meu pedido de publicar
  ("publica", "coloca no ar") **é** essa autorização, para o caminho inteiro até o destino.

### DETALHAMENTO não usa ✅ nem ☑️
- Ali as linhas são **constatações/evidências**, não tarefas concluídas. ✅/☑️ ali me passam sensação
  errada de sucesso.
- Use 🔎 para fato verificado com prova (o que foi rodado/lido e o que voltou), inclusive quando a
  constatação é ruim.
- ❌ / ⚠️ / ⏳ / 🚫 / ❓ / 💡 continuam valendo normalmente no DETALHAMENTO.

## Bloco de pendências — o que entra
- Só os títulos, uma linha cada, sem explicação.
- Repita a cada resposta o que continua em aberto; remova quando resolver.
- Entram:
  - ☑️ feito, mas ainda não valendo no ambiente real
  - ⏳ feito sem prova/verificação
  - 🚫 bloqueado esperando decisão, credencial ou autorização minha
  - ⚠️ risco ou aviso ainda válido
  - 📋 escopo adiado conscientemente

## Bloco de próximos passos — numerado e referenciável
- Lista numerada com um código curto no começo de cada item: `P1`, `P2`, `P3`…
- O código existe para eu referenciar sem escrever muito ("faz o P2", "P1 e P3 não").
- Os códigos valem para a **última resposta** e reiniciam em P1 a cada resposta. Se eu citar um código
  que não bate com a última lista, confirme comigo a qual item eu me refiro antes de agir.
- Um item por linha, curto, começando por verbo.
