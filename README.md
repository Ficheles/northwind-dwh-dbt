# Projeto de Engenharia de Dados: Data Warehouse e Data Marts

Este projeto implementa um pipeline de dados completo para a criação de um **Data Warehouse** (DW) com foco em **Data Marts**. Utilizamos o banco de dados Northwind como fonte de dados transacional (OLTP), dados externos simulados e o dbt para transformar os dados em um modelo dimensional pronto para análise.

## 📂 Estrutura do Projeto

A estrutura do projeto foi organizada para separar as responsabilidades entre **infraestrutura**, **dados de origem** e **transformação**:

```text
.
├── docker-compose.yml      # Orquestração dos containers (MySQL, dbt)
├── README.md               # Documentação do projeto
├── .env.example            # Exemplo de variáveis de ambiente
│
├── sources/                # Scripts e dados para popular os bancos de origem
│   ├── northwind/          # Scripts SQL do banco Northwind (OLTP)
│   │   ├── instnwnd.sql    # Script para criar e popular o banco Northwind
│   └── init/               # Scripts de inicialização do MySQL
│       └── init.sql        # Criação de bancos e permissões
│
├── transform/              # Projeto dbt para transformação de dados
│   ├── dbt_project.yml     # Configuração principal do dbt
│   ├── profiles.yml        # Configuração de conexão do dbt
│   ├── seeds/              # Dados estáticos (ex: países, taxas de câmbio)
│   └── models/             # Modelos SQL (Staging, Marts)
│       ├── staging/        # Camada de limpeza e padronização
│       └── marts/          # Camada final (modelo dimensional)
│
└── data/                   # Diretório para dados locais (opcional)
```

## 🚀 Como Executar o Projeto

### Pré-requisitos

- Docker e Docker Compose instalados
- Opcional: Editor de código como VS Code com extensão para dbt

### Passo a Passo

**1. Clonar o repositório:**

```bash
git clone <url-do-repositorio>
cd <nome-do-repositorio>
```

**2. Configurar variáveis de ambiente:**

Copie o arquivo `.env.example` para `.env` e ajuste as variáveis conforme necessário:

```bash
cp .env.example .env
```

**3. Subir os containers:**

Este comando irá inicializar o MySQL e o ambiente dbt:

```bash
docker-compose up -d --build
```

**4. Criar e popular o banco Northwind:**

O banco Northwind será criado automaticamente pelo script `instnwnd.sql` durante a inicialização do MySQL.

**5. Testar a conexão do dbt:**

Acesse o container do dbt e teste a conexão com o banco:

```bash
docker exec -it northwind_dbt bash
dbt debug
```

**6. Executar as transformações:**

Rode os modelos dbt para criar o Data Warehouse:

```bash
dbt run
```

**7. Visualizar os dados:**

Conecte uma ferramenta de BI (ex: Power BI, Tableau) ao banco MySQL para explorar os dados transformados.

## 🏗️ Arquitetura do Data Warehouse (Foco em Data Marts)

O projeto segue a arquitetura **ELT** (Extract, Load, Transform), com três camadas principais de dados:

### 1. Camada Bronze (Raw / Sources)

- **Onde:** Banco de dados MySQL (`northwind`)
- **O que é:** Dados brutos extraídos do sistema transacional (OLTP) e de fontes externas
- **Exemplo:** Tabelas como `Orders`, `Customers`, `Products`

### 2. Camada Silver (Staging)

- **Onde:** Diretório `models/staging/` no dbt
- **O que é:** Dados limpos e padronizados, prontos para transformação
- **Exemplo:** Arquivo `stg_orders.sql` que renomeia colunas e ajusta tipos de dados

### 3. Camada Gold (Data Marts)

- **Onde:** Diretório `models/marts/` no dbt
- **O que é:** Modelo dimensional (Star Schema) com tabelas de fatos e dimensões
- **Fatos:** Contêm métricas e eventos (ex: `fct_orders`)
- **Dimensões:** Contêm atributos descritivos (ex: `dim_customers`, `dim_products`)

## 🎯 Como Criar um Data Warehouse Focado em Data Marts

### Conceito de Data Marts

Um **Data Mart** é um subconjunto do Data Warehouse focado em uma área específica de negócio (ex: vendas, marketing, finanças). A abordagem de Data Marts oferece:

- **Agilidade:** Desenvolvimento mais rápido e iterativo
- **Especialização:** Modelos otimizados para cada departamento
- **Performance:** Consultas mais rápidas em datasets menores
- **Governança:** Controle de acesso granular por área

### Estratégia de Implementação

**Passo 1: Identificar os Data Marts Necessários**

Exemplos de Data Marts para o projeto Northwind:
- **Vendas:** Análise de pedidos, produtos e clientes
- **Logística:** Análise de entregas e fornecedores
- **Financeiro:** Análise de receitas e custos
- **Marketing:** Análise de clientes e segmentação

**Passo 2: Definir o Modelo Dimensional (Star Schema)**

Para cada Data Mart, crie:
- **1 Tabela Fato:** Contém métricas e chaves estrangeiras
- **N Tabelas Dimensão:** Contêm atributos descritivos

Exemplo para Data Mart de Vendas:
```
Fato: fct_sales
    - order_id (PK)
    - customer_key (FK)
    - product_key (FK)
    - date_key (FK)
    - quantity
    - unit_price
    - total_amount

Dimensões:
    - dim_customers
    - dim_products
    - dim_dates
    - dim_employees
```

**Passo 3: Implementar no dbt**

Organize os modelos por Data Mart:

```text
models/
├── staging/
│   ├── stg_orders.sql
│   ├── stg_customers.sql
│   └── stg_products.sql
│
└── marts/
        ├── sales/              # Data Mart de Vendas
        │   ├── fct_sales.sql
        │   ├── dim_customers.sql
        │   └── dim_products.sql
        │
        ├── logistics/          # Data Mart de Logística
        │   ├── fct_shipments.sql
        │   └── dim_shippers.sql
        │
        └── finance/            # Data Mart Financeiro
                └── fct_revenue.sql
```

**Passo 4: Criar Modelos de Staging**

Limpe e padronize os dados de origem:

```sql
-- models/staging/stg_orders.sql
select
        order_id,
        customer_id,
        employee_id,
        order_date,
        shipped_date,
        ship_via as shipper_id,
        freight
from {{ source('northwind', 'orders') }}
where order_date is not null
```

**Passo 5: Criar Tabelas Dimensão**

```sql
-- models/marts/sales/dim_customers.sql
select
        {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_key,
        customer_id,
        company_name,
        contact_name,
        city,
        country,
        region
from {{ ref('stg_customers') }}
```

**Passo 6: Criar Tabelas Fato**

```sql
-- models/marts/sales/fct_sales.sql
select
        {{ dbt_utils.generate_surrogate_key(['o.order_id', 'od.product_id']) }} as sales_key,
        o.order_id,
        c.customer_key,
        p.product_key,
        d.date_key,
        od.quantity,
        od.unit_price,
        od.discount,
        (od.quantity * od.unit_price * (1 - od.discount)) as total_amount
from {{ ref('stg_orders') }} o
join {{ ref('stg_order_details') }} od on o.order_id = od.order_id
join {{ ref('dim_customers') }} c on o.customer_id = c.customer_id
join {{ ref('dim_products') }} p on od.product_id = p.product_id
join {{ ref('dim_dates') }} d on o.order_date = d.date_value
```

**Passo 7: Documentar e Testar**

```yaml
# models/marts/sales/schema.yml
version: 2

models:
    - name: fct_sales
        description: "Tabela fato de vendas"
        columns:
            - name: sales_key
                description: "Chave primária"
                tests:
                    - unique
                    - not_null
            - name: total_amount
                description: "Valor total da venda"
                tests:
                    - not_null
```

**Passo 8: Executar e Validar**

```bash
dbt run --models marts.sales
dbt test --models marts.sales
```

## 🛠️ Boas Práticas para Data Marts

1. **Nomeação Consistente:** Use prefixos `fct_` e `dim_` para identificar fatos e dimensões
2. **Chaves Substitutas:** Use chaves surrogate em vez de chaves naturais
3. **Documentação:** Documente todas as tabelas e colunas no arquivo `schema.yml`
4. **Testes:** Implemente testes de qualidade de dados
5. **Incrementalidade:** Use modelos incrementais para tabelas fato grandes
6. **Materialização:** Configure materializações adequadas (table, view, incremental)

## 📊 Ferramentas Utilizadas

- **Docker:** Containerização do ambiente
- **MySQL:** Banco de dados transacional e analítico
- **dbt (data build tool):** Transformação de dados e modelagem
- **Python:** Scripts auxiliares para ingestão de dados
- **Power BI/Tableau:** Visualização dos dados transformados

## 📚 Referências

- [Documentação do dbt](https://docs.getdbt.com/)
- [Northwind Database](https://github.com/microsoft/sql-server-samples/tree/master/samples/databases/northwind-pubs)
- [Docker Compose](https://docs.docker.com/compose/)
- [Kimball's Data Warehouse Toolkit](https://www.kimballgroup.com/)
