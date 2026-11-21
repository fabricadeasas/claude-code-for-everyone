# A menos que o usuário peça/escolha/autorize explicitamente para fazer diferente, você fará de forma transparente sem pedir:
- Usar tailwindcss como framework CSS;
- Sempre documente o código-fonte com comentários;
- Documente o projeto. Distribua a documentação em arquivos .md em uma pasta chamada docs. Separe os assuntos por categoria. Essa documentação não se trata especificamente do software/sistema/app, se trata do projeto todo, é como se fosse a base de conhecimento sobre o projeto. Crie e mantenha um README.md na raiz do projeto que serve de sumário para a documentação;
- Sempre preze por reuso de código;
- Em páginas web garanta sempre responsividade para mobile;
- Usar código orientado a objetos como preferência ao invés de código estruturado. Usar código estruturado somente quando for justificável ou não for possível POO;
- Crie/ajuste testes automatizados conforme você cria/ajusta recursos;
- Trabalhe na pasta do projeto. Não saia mexendo em outras pastas do meu computador sem minha autorização. Se você precisar mexer em outros lugares fora da minha pasta, para executar determinada atividade, peça minha autorização primeiro, caso eu ainda não tenha dado;
- Trate os erros. Nada de falha silenciosa;
- Mensagem de erro tem que ser compreensível para a pessoa, não código técnico;
- Mostre estado de carregamento e trate internet ruim;
- Nunca armazenar senhas em texto puro no banco de dados;
- Senha de usuário sempre com hash forte. Nunca reversível;
- Nunca deixe segredos no código. Use variável de ambiente;
- Proteja contra SQL injection;
- Regra/segredo de negócio deve ficar do lado do servidor (back-end), não no front-end;
- Escolha dependências com critério, prefira as bem mantidas, ativas, atualizadas;

# Ações destrutivas ou que possuem consequências
- Nunca execute tarefas destrutivas ou que possuem consequências sem minha autorização;
- O usuário pode não ter noção que certas ações podem ser destrutivas, então o avise/alerte;

# Backups
- Sempre confira a saúde do arquivo de backup, se está integro. Backup que nunca foi restaurado não é backup;
- Os backups do banco de dados em ambiente local devem viver na pasta backups na raiz do projeto;
