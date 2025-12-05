# Data Warehouse com Data Marts - Projeto Northwind

## 📋 Visão Geral

Este projeto demonstra a construção de um **Data Warehouse moderno** utilizando a arquitetura de **Data Marts**, partindo do clássico banco de dados Northwind como fonte transacional (OLTP). O objetivo é transformar dados operacionais em um modelo analítico dimensional, permitindo análises de negócio eficientes.

### 🔗 Links Úteis

| Recurso | Link |
|---------|------|
| 📊 Apresentação | [Ver Apresentação](docs/Data_Warehouse_com_Data_Marts.pdf) |
| 📄 Relatório Técnico | [RELATORIO_TECNICO.md](docs/RELATORIO_TECNICO.md) |
| 🐙 Repositório | [GitHub](https://github.com/Ficheles/northwind-dwh-dbt) |


### Propósito do Projeto

O projeto serve como guia prático para:
- Implementar um pipeline **ELT** (Extract, Load, Transform) completo
- Criar múltiplos **Data Marts** especializados por área de negócio
- Aplicar **modelagem dimensional** (Star Schema) usando dbt
- Estabelecer camadas de dados (Bronze, Silver, Gold) seguindo boas práticas modernas
- Preparar dados para consumo por ferramentas de BI e análise
- Demonstrar o uso de contêineres Docker para orquestração do ambiente
- Foi utilizado para a construção das Analises o **Metabase** como ferramenta de BI.

## 🏛️ Arquitetura do Projeto

### Camadas de Dados

```
┌─────────────────────────────────────────────────────┐
│  CAMADA BRONZE (Raw)                                │
│  Banco: northwind (OLTP)                            │
│  Tabelas: Orders, Customers, Products, etc.         │
└─────────────────────────────────────────────────────┘
                      ↓ dbt (Staging)
┌─────────────────────────────────────────────────────┐
│  CAMADA SILVER (Staging)                            │
│  Local: models/staging/                             │
│  Função: Limpeza, padronização, tipagem             │
└─────────────────────────────────────────────────────┘
                      ↓ dbt (Marts)
┌─────────────────────────────────────────────────────┐
│  CAMADA GOLD (Data Marts)                           │
│  Local: models/marts/                               │
│  Modelo: Star Schema (Fatos + Dimensões)            │
│  Marts: Sales, Customers, Products        │
└─────────────────────────────────────────────────────┘
```

### Estrutura de Diretórios

```text
.
├── dbt_project                                           # Projeto dbt 
│   ├── dbt_packages                                      # Pacotes dbt
│   │   └── dbt_utils                                     # dbt-utils package
│   │       ├── CHANGELOG.md                              # Histórico de mudanças  
│   │       ├── CONTRIBUTING.md                           # Guia de contribuição
│   │       ├── dbt_project.yml                           # Configuração do pacote
│   │       ├── dev-requirements.txt                      # Dependências para desenvolvimento 
│   │       ├── docker-compose.yml                        # Configuração Docker estrutura
│   │       ├── docs                                      # Documentação do pacote
│   │       │   └── decisions                             # Decisões de design
│   │       ├── etc                                       # Arquivos diversos
│   │       │   └── dbt-logo.png                          # Logo do dbt
│   │       ├── integration_tests                         # Testes de integração
│   │       │   ├── ci                                    # Configuração CI
│   │       │   ├── data                                  # Dados de teste
│   │       │   ├── dbt_project.yml                       # Configuração do projeto de teste
│   │       │   ├── macros                                # Macros do projeto de teste
│   │       │   ├── models                                # Modelos do projeto de teste
│   │       │   ├── packages.yml                          # Pacotes do projeto de teste
│   │       │   ├── README.md                             # Documentação do projeto de teste
│   │       │   └── tests                                 # Testes do projeto de teste
│   │       ├── LICENSE                                   # Licença do pacote
│   │       ├── macros                                    # Macros do pacote
│   │       │   ├── generic_tests                         # Testes genéricos
│   │       │   ├── jinja_helpers                         # Helpers Jinja
│   │       │   ├── sql                                   # SQL Macros
│   │       │   └── web                                   # Macros web
│   │       ├── Makefile                                  # Makefile para tarefas comuns
│   │       ├── pytest.ini                                # Configuração do pytest
│   │       ├── README.md                                 # Documentação do pacote
│   │       ├── RELEASE.md                                # Guia de lançamento
│   │       ├── run_functional_test.sh                    # Script para testes funcionais
│   │       ├── run_test.sh                               # Script para testes
│   │       └── tests                                     # Testes do pacote
│   │           ├── conftest.py                           # Configuração de testes
│   │           └── __init__.py                           # Inicialização do pacote de testes
│   ├── dbt_project.yml                                   # Configuração do projeto dbt
│   ├── logs                                              # Logs do dbt
│   │   └── dbt.log                                       # Log principal
│   ├── macros                                            # Macros personalizados
│   │   └── generate_schema_name.sql                      # Macro para geração de nomes de esquema
│   ├── models                                            # Modelos dbt
│   │   ├── marts                                         # Data Marts (Gold)
│   │   │   ├── core                                      # Dimensões e fatos compartilhados
│   │   │   │   ├── dim_customers.sql                     # Dimensão de Clientes
│   │   │   │   ├── dim_date.sql                          # Dimensão de Datas
│   │   │   │   ├── dim_employees.sql                     # Dimensão de Funcionários
│   │   │   │   ├── dim_products.sql                      # Dimensão de Produtos
│   │   │   │   └── fct_sales.sql                         # Fato de Vendas
│   │   │   ├── customers                                 # Mart de Clientes
│   │   │   │   └── mart_customer_analytics.sql           # Análises de Clientes
│   │   │   ├── products                                  # Mart de Produtos
│   │   │   │   └── mart_product_performance.sql          # Desempenho de Produtos
│   │   │   └── sales                                     # Mart de Vendas
│   │   │       └── mart_sales_summary.sql                # Resumo de Vendas
│   │   ├── sources.yml                                   # Definições de fontes de dados
│   │   └── staging                                       # Camada de preparação (Staging)
│   │       ├── stg_customers.sql                         # Staging de Clientes
│   │       ├── stg_employees.sql                         # Staging de Funcionários
│   │       ├── stg_order_details.sql                     # Staging de Detalhes de Pedidos
│   │       ├── stg_orders.sql                            # Staging de Pedidos
│   │       └── stg_products.sql                          # Staging de Produtos
│   ├── package-lock.yml                                  # Lockfile de pacotes
│   ├── packages.yml                                      # Definição de pacotes
│   ├── profiles.yml                                      # Perfis de conexão
│   ├── README.md                                         # Documentação do projeto dbt
│   ├── seeds                                             # Dados estáticos (CSV)
│   ├── snapshots                                         # Snapshots de dados
│   │   └── snp_customers.sql.bak                         # Snapshot de Clientes
│   └── target                                            # Artefatos gerados pelo dbt
│       ├── compiled                                      # SQL compilado
│       │   └── northwind_dwh                             # Esquema do Data Warehouse
│       │       └── models                                # Modelos compilados
│       ├── graph.gpickle                                 # Grafo do projeto
│       ├── graph_summary.json                            # Resumo do grafo
│       ├── manifest.json                                 # Manifesto do projeto
│       ├── partial_parse.msgpack                         # Parse parcial
│       ├── run                                           # Resultados de execução
│       │   └── northwind_dwh                             # Esquema do Data Warehouse
│       │       └── models                                # Resultados dos modelos
│       ├── run_results.json                              # Resultados da execução
│       └── semantic_manifest.json                        # Manifesto semântico
├── docker-compose.yaml                                   # Orquestração dos containers
├── docs                                                  # Documentação do projeto
│   ├── prints                                            # Imagens ilustrativas
│   │   ├── A look at Dim Customers.png                   # Dimensão de Clientes 
│   │   ├── A look at Dim Date.png                        # Dimensão de Datas
│   │   ├── A look at Dim Employees.png                   # Dimensão de Funcionários
│   │   ├── A look at Dim Products.png                    # Dimensão de Produtos
│   │   ├── A look at Fct Sales.png                       # Fato de Vendas
│   │   ├── A look at Mart Customer Analytics.png         # Mart de Clientes
│   │   ├── A look at Mart Product Performance.png        # Mart de Produtos
│   │   └── A look at Mart Sales Summary.png              # Mart de Vendas 
│   └── RELATORIO_TECNICO.md                              # Relatório técnico do projeto
├── infra                                                 # Infraestrutura como código
│   └── dbt                                               # Configuração do ambiente dbt
│       └── Dockerfile                                    # Dockerfile para o ambiente dbt
├── instnwnd.sql                                          # Script de criação do banco Northwind
├── README.md                                             # Documentação principal
└── sources                                               # Dados de origem
    ├── dwh                                               # Data Warehouse
    │   └── 01-create  schema.sql                         # Script de criação do esquema DWH
    ├── external_data                                     # Dados externos
    │   ├── 01-Create Schema.sql                          # Script de criação do esquema de dados externos
    │   └── 02-Seeds.sql                                  # Scripts de sementes de dados externos
    ├── init
    │   └── 00-init.sql                                   # Inicialização e permissões MySQL
    └── northwind     
        ├── 01-create_tables.sql                          # Script de criação das tabelas Northwind
        ├── 02-populate.sql                               # Script de população das tabelas Northwind
        ├── 03-procedures.sql                             # Script de criação de procedimentos armazenados Northwind
        └── 04-constraints.sql                            # Script de criação de restrições Northwind

45 directories, 67 files
``` 

## 🚀 Como Executar

### Pré-requisitos

- **Docker** e **Docker Compose** instalados ([Guia de instalação](https://docs.docker.com/get-docker/))
- Mínimo 4GB de RAM disponível
- (Opcional) VS Code com extensão dbt Power User

### Passo a Passo

#### 1. Clone o Repositório

```bash
git clone https://github.com/Ficheles/northwind-dwh-dbt.git
cd northwind-dwh-dbt
```

#### 2. Configure as Variáveis de Ambiente

```bash
cp .env.example .env
```

Edite o arquivo `.env` conforme necessário. Exemplo de conteúdo:

```env
MYSQL_ROOT_PASSWORD=root_password
MYSQL_DATABASE=northwind
MYSQL_USER=dbt_user
MYSQL_PASSWORD=dbt_password
```

#### 3. Inicie os Containers

```bash
docker-compose up -d --build
```

Aguarde alguns segundos para que o MySQL inicialize completamente.

#### 4. Verifique os Containers

```bash
docker-compose ps
```

Você deve ver os containers `northwind_mysql_db` e `northwind_dbt` em execução.

#### 5. Valide a Conexão do dbt

Entre no container do dbt:

```bash
docker exec -it northwind_dbt bash
```

Teste a conexão:

```bash
dbt debug
```

Se tudo estiver correto, você verá `All checks passed!`.

#### 6. Execute as Transformações

Instale as dependências do dbt:

```bash
dbt deps
```

Execute os modelos de staging:

```bash
dbt run --models staging
```

Execute os Data Marts:

```bash
dbt run --models marts
```

Ou execute tudo de uma vez:

```bash
dbt run
```

#### 7. Execute os Testes de Qualidade

```bash
dbt test
```

#### 8. Gere a Documentação

```bash
dbt docs generate
dbt docs serve --port 8080
```

Acesse `http://localhost:8080` para visualizar a documentação interativa.

#### 9. Conecte uma Ferramenta de BI

Use as seguintes credenciais para conectar no Metabase:

- **Host:** `localhost`
- **Porta:** `3306`
- **Database:** `northwind`
- **Usuário:** `dbt_user` (conforme `.env`)
- **Senha:** `dbt_password` (conforme `.env`)

## 🎯 Conceito de Data Marts

### O que são Data Marts?

**Data Marts** são subconjuntos especializados do Data Warehouse, focados em áreas específicas de negócio. Cada Data Mart contém apenas os dados relevantes para seu domínio.

### Vantagens da Abordagem por Data Marts

| Vantagem | Descrição |
|----------|-----------|
| **Agilidade** | Desenvolvimento iterativo e entregas incrementais |
| **Performance** | Consultas mais rápidas em datasets menores e focados |
| **Governança** | Controle de acesso granular por departamento |
| **Manutenção** | Mudanças isoladas não afetam outros Data Marts |
| **Especialização** | Modelos otimizados para necessidades específicas |

### Data Marts Implementados

#### 🛒 Sales (Vendas)
- **Foco:** Análise de vendas, produtos e clientes
- **Fatos:** `fct_sales`
- **Dimensões:** `dim_customers`, `dim_products`, `dim_dates`, `dim_employees`
- **Métricas:** Receita, quantidade, desconto, ticket médio

#### 🚚 Logistics (Logística)
- **Foco:** Análise de entregas e desempenho de fornecedores
- **Fatos:** `fct_shipments`
- **Dimensões:** `dim_shippers`, `dim_suppliers`, `dim_dates`
- **Métricas:** Tempo de entrega, custo de frete, taxa de atraso

#### 💰 Finance (Financeiro)
- **Foco:** Análise de receitas, custos e lucratividade
- **Fatos:** `fct_revenue`
- **Dimensões:** `dim_customers`, `dim_products`, `dim_dates`
- **Métricas:** Receita bruta, margem de lucro, custos operacionais

#### 📊 Marketing (Marketing)
- **Foco:** Segmentação de clientes e análise de campanhas
- **Fatos:** `fct_customer_behavior`
- **Dimensões:** `dim_customer_segments`, `dim_regions`
- **Métricas:** Lifetime value, taxa de retenção, churn

## 🔧 Modelagem Dimensional (Star Schema)

### Exemplo: Data Mart de Vendas

```sql
-- Tabela Fato
fct_sales
├── sales_key (PK)
├── customer_key (FK) → dim_customers
├── product_key (FK) → dim_products
├── date_key (FK) → dim_dates
├── employee_key (FK) → dim_employees
├── quantity
├── unit_price
├── discount
└── total_amount

-- Dimensões
dim_customers (customer_key, customer_id, company_name, country, ...)
dim_products (product_key, product_id, product_name, category, ...)
dim_dates (date_key, date_value, year, quarter, month, ...)
dim_employees (employee_key, employee_id, full_name, title, ...)
```

### Implementação no dbt

**Staging (Limpeza):**

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

**Dimensão:**

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

**Fato:**

```sql
-- models/marts/sales/fct_sales.sql
select
    {{ dbt_utils.generate_surrogate_key(['o.order_id', 'od.product_id']) }} as sales_key,
    o.order_id,
    c.customer_key,
    p.product_key,
    d.date_key,
    e.employee_key,
    od.quantity,
    od.unit_price,
    od.discount,
    (od.quantity * od.unit_price * (1 - od.discount)) as total_amount
from {{ ref('stg_orders') }} o
join {{ ref('stg_order_details') }} od on o.order_id = od.order_id
join {{ ref('dim_customers') }} c on o.customer_id = c.customer_id
join {{ ref('dim_products') }} p on od.product_id = p.product_id
join {{ ref('dim_dates') }} d on o.order_date = d.date_value
join {{ ref('dim_employees') }} e on o.employee_id = e.employee_id
```

## 🛠️ Melhores Práticas para Data Marts

### 1. Convenções de Nomenclatura

```yaml
Padrão de nomes:
  Staging:   stg_<nome_tabela>       # ex: stg_orders
  Dimensões: dim_<nome_dimensao>     # ex: dim_customers
  Fatos:     fct_<nome_metrica>      # ex: fct_sales
```

### 2. Chaves Substitutas (Surrogate Keys)

Use sempre chaves substitutas geradas automaticamente:

```sql
{{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_key
```

**Vantagens:**
- Independência da fonte de dados
- Performance em joins
- Suporte a SCD (Slowly Changing Dimensions)

### 3. Documentação Completa

```yaml
# models/marts/sales/schema.yml
version: 2

models:
  - name: fct_sales
    description: "Fato contendo todas as transações de vendas"
    columns:
      - name: sales_key
        description: "Chave primária da tabela fato"
        tests:
          - unique
          - not_null
      - name: customer_key
        description: "Chave estrangeira para dim_customers"
        tests:
          - relationships:
              to: ref('dim_customers')
              field: customer_key
```

### 4. Testes de Qualidade

Implemente testes em todas as tabelas:

```yaml
tests:
  - unique                    # Chaves primárias
  - not_null                  # Campos obrigatórios
  - relationships             # Integridade referencial
  - accepted_values           # Valores permitidos
  - dbt_utils.expression_is_true  # Regras de negócio
```

### 5. Materialização Adequada

```yaml
# dbt_project.yml
models:
  staging:
    +materialized: view       # Views para staging
  marts:
    dimensions:
      +materialized: table    # Tabelas para dimensões
    facts:
      +materialized: incremental  # Incremental para fatos grandes
```

### 6. Modelos Incrementais

Para tabelas fato com grandes volumes:

```sql
{{
  config(
    materialized='incremental',
    unique_key='sales_key',
    on_schema_change='fail'
  )
}}

select * from {{ ref('stg_orders') }}

{% if is_incremental() %}
  where order_date > (select max(order_date) from {{ this }})
{% endif %}
```

### 7. Organização por Domínio

```text
models/marts/
├── customers/         # Tudo relacionado a customers
├── products/          # Tudo relacionado a produtos
├── sales/             # Tudo relacionado a sales
└── _shared/           # Dimensões compartilhadas (dim_dates)
```

## 📊 Ferramentas Utilizadas

| Ferramenta | Função | Link |
|------------|--------|------|
| **Docker** | Containerização do ambiente | [docker.com](https://www.docker.com/) |
| **MySQL** | Banco de dados (OLTP e OLAP) | [mysql.com](https://www.mysql.com/) |
| **dbt** | Transformação e modelagem de dados | [getdbt.com](https://www.getdbt.com/) |
| **Python** | Scripts auxiliares de ingestão | [python.org](https://www.python.org/) |

## 🐛 Solução de Problemas

### Container MySQL não inicia

```bash
# Verifique os logs
docker-compose logs mysql

# Remova volumes e recrie
docker-compose down -v
docker-compose up -d
```

### dbt não conecta ao MySQL

```bash
# Verifique se o MySQL está pronto
docker exec -it northwind_mysql mysql -u root -p

# Valide o profiles.yml
cat transform/profiles.yml
```

### Modelos dbt com erro

```bash
# Execute com logs detalhados
dbt run --debug

# Compile o modelo para ver o SQL gerado
dbt compile --models <nome_modelo>
```

## 📚 Referências

- [Documentação oficial do dbt](https://docs.getdbt.com/)
- [Northwind Database - Microsoft](https://github.com/microsoft/sql-server-samples/tree/master/samples/databases/northwind-pubs)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [The Data Warehouse Toolkit - Ralph Kimball](https://www.kimballgroup.com/)
- [dbt Best Practices](https://docs.getdbt.com/guides/best-practices)
- [Star Schema: The Complete Reference - Christopher Adamson](https://www.kimballgroup.com/)
- [Dimensional Modeling Techniques](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/)


## 👥 Contribuidores

- **Rafael Fideles** - [@ficheles](https://github.com/ficheles)
- **Ronen R. S. Filho** - [@ronenfilho](https://github.com/ronenfilho/)

---

## 📄 Licença

Este projeto foi desenvolvido para fins acadêmicos.

