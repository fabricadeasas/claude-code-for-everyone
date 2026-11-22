# Formato da resposta: Resposta → Pendências → Próximos passos

## Quando aplicar
- Vale para respostas de trabalho (execução, análise, entrega, decisão).
- Pergunta rápida ou conversa: responda direto, sem blocos.
- Bloco sem conteúdo não aparece. Não escreva "nenhuma" — omita o bloco inteiro.

## Ordem e títulos — sempre nesta ordem
1. `## RESPOSTA` — sempre.
2. `## PENDÊNCIAS DA SESSÃO` — só se houver.
3. `## PRÓXIMOS PASSOS` — só se houver passo real; não invente para preencher.

- Sempre cabeçalho markdown nível 2 (`##`) — é o que renderiza destacado. Nunca texto solto.
- Sem emoji no título, só o texto em caixa alta exatamente como acima.

## Conteúdo da RESPOSTA
- **Primeiro parágrafo = o resultado**, 1 a 3 linhas, começando pelo emoji de status. Lendo só ele,
  eu tenho que saber se deu certo ou não.
- O resultado diz o que foi feito e o que isso muda na prática para mim.
- Depois, só o necessário para eu entender ou agir. Não acrescente evidências, logs ou explicações
  para preencher espaço. Se o resultado basta, a resposta termina nele.
- A prova da verificação cabe em uma linha (o que rodou e o que voltou), não numa lista.

## Formatação de cada bloco
- Espaço em branco → divisor (`---`) → espaço em branco → título `## TÍTULO` (sem emoji) → espaço em branco → conteúdo.
- Tudo resumido: essencial, curto, alto nível. Texto grande e denso me faz só olhar por cima. Se eu quiser mais, eu peço.

## Emojis de status — no início da linha
- ❌ erro / falhou / não funciona
- ⚠️ atenção / risco / ressalva importante
- ⏳ feito mas ainda não verificado, ou em andamento
- 🚫 bloqueado, dependendo de mim
- ❓ dúvida, preciso da minha confirmação
- 💡 sugestão / ideia
- Use o emoji certo, não decore.

### ✅ e ☑️ — só no primeiro parágrafo da RESPOSTA
- Os dois significam **tarefa concluída e verificada com prova**. Nunca aparecem no resto da resposta:
  ali as linhas são constatações, e ✅/☑️ me passam sensação errada de sucesso.
- A diferença é **se a entrega já está valendo no ambiente real do projeto**:
  - ☑️ **feito, mas ainda não valendo lá** — existe só como trabalho seu (arquivo alterado no
    computador, versão salva mas não enviada, rascunho, arquivo escrito mas não instalado/ativado,
    mudança no banco não aplicada). Se você não fizer mais nada, o sistema real continua sem isso.
  - ✅ **feito e valendo no ambiente real** — porque a operação foi executada direto lá, porque houve
    publicação/instalação, ou porque a tarefa era só publicar algo já pronto.
- Sem prova continua sendo ⏳, nunca ☑️ nem ✅ (ver "Não presuma que está funcionando por semântica").
  A prova de ✅ tem que ser colhida **no ambiente real**, não em cópia local do que já está lá.

### Antes de escolher, identifique qual é o ambiente real
- Ambiente real = onde o sistema **de fato roda** para valer. Não é sempre remoto:
  - Sistema que roda em servidor/nuvem → o ambiente real é o servidor.
  - **Sistema que roda só no meu computador** (planilha ou script pessoal, automação local, app que
    uso só aqui, configuração do meu computador, banco local que é o banco de verdade) → **o meu
    computador é o ambiente real**. Aplicar ali já é ✅, não existe "falta publicar".
- Cada projeto publica de um jeito (envio para o GitHub que publica sozinho, script de publicação,
  ação direta no servidor, instalação local, painel de um serviço na nuvem). Olhe o contexto do
  projeto; se não der para saber, pergunte em vez de chutar.

### Cuidado: em projeto local, ☑️ ainda existe
Escrever o arquivo não é o mesmo que fazer valer. Continua ☑️ quando falta o passo de ativação:
instalar, mover para a pasta final, reiniciar o serviço, aplicar a mudança no banco real (mesmo
local), registrar no agendador, recarregar a configuração.

### O que conta como "fazer valer" (publicar)
- **Servidor / site / sistema**: publicação **concluída e conferida no servidor** (a automação
  terminou, a versão nova está rodando lá, a funcionalidade foi vista funcionando lá). Envio que só
  *dispara* a publicação ainda é ☑️.
- **Banco de dados**: mudança aplicada no banco que o sistema realmente usa — remoto ou local.
- **GitHub**: **só** quando o que eu pedi é o próprio registro lá (ex.: "manda para o GitHub",
  "abre o pedido de junção"). Se eu pedi uma mudança no sistema, salvar a versão, enviar para o
  GitHub e juntar o rascunho são etapas do caminho, não a entrega: continuam ☑️. Versão salva e
  não enviada é sempre ☑️.
- **Serviços na nuvem**: painel, domínio, armazenamento de arquivos, agendamentos, senhas e
  configurações do serviço, integrações.
- **Coisas publicadas**: site no ar, documento ou tarefa criada na ferramenta externa (Drive,
  ClickUp, Notion) quando o entregável é o registro lá.
- **Meu computador como destino**: script instalado e funcionando, serviço reiniciado, configuração
  carregada, agendamento ativo.

### Regras de decisão
- **Não existe etapa de ativação** (análise, investigação, resposta, rascunho que eu pedi): ✅ normal.
- **Existe e não foi feita**: ☑️, com uma linha dizendo o que falta.
- **Feito só em parte** (ex.: site no ar, mudança no banco não aplicada): ☑️, dizendo o que ficou de fora.
- **Ambiente intermediário quando o destino era outro** (está no ambiente de testes, o alvo era
  produção): ☑️, dizendo onde está.
- **O ✅ se mede contra o meu pedido original, não contra a etapa da vez.** Quando eu aprovo um passo
  intermediário ("faz o P1" = salvar a versão, publicar no ambiente de testes), concluir esse passo
  não vira ✅: a entrega continua sendo a do pedido original, e o primeiro parágrafo diz em que etapa
  ela está, com ☑️.
- **Checagem obrigatória antes de escrever ✅** — responda as três; qualquer "não" vira ☑️:
  1. O que eu pedi originalmente, e onde isso tem que estar valendo (meu computador, ambiente de
     testes, produção)?
  2. Está valendo **lá** agora (publicado, aplicado, instalado — não só salvo, enviado ou disparado)?
  3. Tem prova colhida **lá** nesta resposta (página aberta, consulta no banco, registro do serviço)?
- Sempre deixe claro **onde** a entrega está: meu computador, ambiente de testes ou produção.
- Publicar é ação com consequência: só publique com autorização minha (ver "Ações destrutivas").
  Ficar em ☑️ esperando meu ok é o comportamento certo, não uma falha. O meu pedido para publicar
  **é** essa autorização, para o caminho inteiro (ver "Salvar e publicar: um pedido, o caminho inteiro").

## Bloco de pendências — o que entra
- Só os títulos, uma linha cada, sem explicação.
- Repita a cada resposta o que continua em aberto; remova quando resolver.
- Entram:
  - ☑️ feito, mas ainda não valendo no ambiente real
  - ⏳ feito sem prova/verificação
  - 🚫 bloqueado esperando decisão, senha ou autorização minha
  - ⚠️ risco ou aviso ainda válido
  - 📋 escopo adiado conscientemente

## Bloco de próximos passos — numerado e referenciável
- Lista numerada com um código curto no começo de cada item: `P1`, `P2`, `P3`…
- O código existe para eu referenciar sem escrever muito ("faz o P2", "P1 e P3 não").
- Os códigos valem para a **última resposta** e reiniciam em P1 a cada resposta. Se eu citar um código
  que não bate com a última lista, confirme comigo a qual item eu me refiro antes de agir.
- Um item por linha, curto, começando por verbo.
