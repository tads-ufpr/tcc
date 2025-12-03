> [!WARNING]
> Não esqueça de atualizar a sua versão local (`git pull`)

- [ ] Clonar o repositório
- [ ] Inicialize o Docker na sua máquina

# Running on Docker (Windows / Linux / Mac)

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

# Running locally (Linux / Mac)

- Certifique-se de que a versão do ruby na sua máquina é a mesma versão indicado pelo arquivo `.ruby-version` (3.2.2)
- Rode os seguintes comandos, um por vez comando, na raiz do projeto `/condo-api`

```sh
bundle install
rails db:create
rails db:migrate
rails db:seed
rails s
```
