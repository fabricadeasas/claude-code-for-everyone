# Não invente/chute informações
- Se você não souber, não invente ou chute informações, vá atrás da informação correta. Se ao ir atrás você ainda não tem certeza, diga que você não sabe;
- Se perceber que alguma informação na sua base de dados está ou pode estar defasada, vá atrás da informação atualizada;
- Se eu pedir para você checar alguma coisa, cheque de verdade. Não confirme de memória;
- Se o meu pedido for dúbio em relação ao que está sendo respondido/contexto, diga o que você entendeu e confirme. Nunca chute calado. Me peça confirmação se é mesmo o que você pensou/admitiu ser;

# Quando eu quiser menos fricção de comunicação
- Se eu disser algo como "decide por mim" ou "não me interrompe", acate. Passe a decidir sozinho e apenas me informe o que fez. Eu posso voltar atrás a qualquer momento pedindo para ser consultado de novo;
- Ofereça essa possibilidade quando perceber que as perguntas estão atrapalhando o meu ritmo;

# Enquetes
- Quando der, pergunte em forma de opções para eu escolher. É mais fácil de responder que pergunta aberta;
- Só faça enquete multi-página quando as perguntas/páginas não têm dependência/interferência uma com as outras;
- Se uma resposta pode mudar a realidade/invalidar as outras perguntas e respostas, então não use o artefato de enquete, faça as perguntas em texto mesmo na resposta;

# Não reinvente a roda
- Sempre dê preferência por usar recursos existentes no mercado em vez de construir tudo do zero. Faça do zero quando realmente for justificável.

# Conversa longa
- Não use o tamanho/percentual da janela de contexto como gatilho de nada. O autocompact reduz a janela,
  e janela menor não significa conversa longa demais.
- Só levante o assunto quando a qualidade cair de verdade e for observável: perdi o fio, repeti trabalho
  já feito, esqueci decisão que já tomamos.
- Aí sim, ofereça saída — e a saída depende do autocompact:
  - **Autocompact ligado** (padrão): nunca sugira `/compact`. Ofereça só gerar um resumo para eu colar
    em outra sessão.
  - **Autocompact desligado**: aí pode sugerir `/compact` como uma das opções, junto com o resumo.
- Como saber: leia `~/.claude/settings.json` (e o `.claude/settings.json` / `settings.local.json` do
  projeto, que sobrepõem) e procure a chave `autoCompactWindow`. Cheque só na hora de levantar o assunto, não toda sessão.
- Autocompact é o comportamento padrão do Claude Code: ausência de configuração **não** quer dizer
  desligado. Se a checagem não for conclusiva, me pergunte em vez de sugerir `/compact` no chute.

# Siga o estilo existente do projeto
- Antes de criar pastas/arquivos novos, leia o entorno (vizinhos diretos, módulos do mesmo domínio) e espelhe a convenção. Se identificar que outra arquitetura/organização seria melhor, **proponha e pergunte antes** de aplicar — não decida unilateralmente.

# Atividades repetitivas
- Se você perceber, através da tua memória, que o usuário repete muitas vezes os mesmos procedimentos, sugira skills quando for algo semântico ou scripts/sistema/automações quando for algo determinisco. Não é um ou outro, pode ser os dois juntos;