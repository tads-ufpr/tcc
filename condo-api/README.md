# Subindo a aplicação

> [!WARNING]
> Não esqueça de atualizar a sua versão local (`git pull`)

- [ ] Criar o arquivo .env.development na raiz do projeto

```sh
touch .env.development
```

`Feito isso, solicite para algum colaborador o conteúdo deste arquivo, a fim de poder decriptografar as variáveis necessárias.
O conteúdo deste arquivo não pode ser comprometido.`

- [ ] Construir a imagem da aplicação
      `Este passo só precisa ser feito uma única vez`

```sh
docker-compose build
```

- [ ] Database migrations
      `Este passo atualizará as configurações das tabelas do banco de dados (SQLite, por enquanto)`

```sh
docker-compose run app rails db:migrate
```

- [ ] Database seed
      `Este passo insere no banco as entidades padrões (dados)`

```sh
docker-compose run app rails db:seed
```

- [ ] Rodar a aplicação

```sh
docker-compose up
```
