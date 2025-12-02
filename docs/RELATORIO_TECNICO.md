# Relatório Técnico: Processo ETL e Data Warehouse

## 1. Visão Geral do Processo ETL

### 1.1 Extração (Extract)
- **Fonte Principal:** Banco de dados Northwind (OLTP)
- **Fontes Externas:** Tabelas de países ISO e taxas de câmbio
- **Método:** Leitura direta via dbt (ELT pattern)

### 1.2 Transformação (Transform)
O processo de transformação foi implementado em **três camadas**:

| Camada | Objetivo | Materialização |
|--------|----------|----------------|
| Staging | Limpeza e padronização | View |
| Core (DWH) | Modelo dimensional | Table |
| Marts | Agregações por negócio | Table |

### 1.3 Carga (Load)
- **Destino:** Banco `northwind_dwh` (MySQL)
- **Estratégia:** Full refresh (truncate + insert)
- **Frequência sugerida:** Diária

---

## 2. Justificativa dos Campos Calculados

### 2.1 Staging - stg_orders

| Campo Calculado | Fórmula | Justificativa |
|-----------------|---------|---------------|
| `days_to_ship` | `ShippedDate - OrderDate` | Medir eficiência logística |
| `is_late_shipment` | `ShippedDate > RequiredDate` | KPI de SLA de entrega |
| `order_status` | CASE WHEN | Classificação para dashboards |
| `order_year/month/quarter` | Extraído de OrderDate | Facilitar análises temporais |

### 2.2 Staging - stg_order_details

| Campo Calculado | Fórmula | Justificativa |
|-----------------|---------|---------------|
| `gross_amount` | `UnitPrice * Quantity` | Valor bruto da venda |
| `discount_amount` | `gross_amount * Discount` | Valor do desconto aplicado |
| `net_amount` | `gross_amount - discount_amount` | Receita líquida real |
| `discount_tier` | CASE WHEN | Segmentação para análise de pricing |

### 2.3 Staging - stg_products

| Campo Calculado | Fórmula | Justificativa |
|-----------------|---------|---------------|
| `needs_reorder` | `UnitsInStock <= ReorderLevel` | Alerta de estoque baixo |
| `price_tier` | CASE WHEN (Budget/Standard/Premium) | Segmentação de portfólio |
| `inventory_value` | `UnitsInStock * UnitPrice` | Valor financeiro em estoque |

### 2.4 Staging - stg_customers

| Campo Calculado | Fórmula | Justificativa |
|-----------------|---------|---------------|
| `region_clean` | COALESCE(Region, 'N/A') | Tratar valores nulos |
| `has_fax` | CASE WHEN Fax IS NOT NULL | Flag booleana para análise |
| `continent` | JOIN com ext_iso_countries | Enriquecimento geográfico |

---

## 3. Desnormalizações Realizadas

### 3.1 Dimensão de Clientes (dim_customers)
- **Métricas agregadas:** `total_orders`, `total_revenue`, `first_order_date`, `last_order_date`
- **Justificativa:** Evitar joins custosos em queries analíticas. O cliente pode consultar diretamente o valor total de um cliente sem precisar agregar a tabela de fatos.

### 3.2 Dimensão de Produtos (dim_products)
- **Categoria desnormalizada:** `category_name`, `category_description`
- **Fornecedor desnormalizado:** `supplier_name`, `supplier_country`
- **Justificativa:** No modelo OLTP, seria necessário fazer 2 joins (Products → Categories, Products → Suppliers). No DW, tudo está em uma única dimensão.

### 3.3 Dimensão de Funcionários (dim_employees)
- **Hierarquia desnormalizada:** `manager_name`
- **Justificativa:** O auto-relacionamento (ReportsTo) foi resolvido com um LEFT JOIN, permitindo análise de vendas por equipe.

---

## 4. Modelo Dimensional

### 4.1 Fato Principal: fct_sales
- **Granularidade:** Uma linha por item de pedido
- **Dimensões conectadas:** dim_customers, dim_products, dim_employees, dim_date
- **Métricas aditivas:** quantity, gross_amount, discount_amount, net_amount, freight_amount

### 4.2 Diagrama Star Schema

```
                    ┌──────────────┐
                    │  dim_date    │
                    └──────┬───────┘
                           │
┌──────────────┐    ┌──────┴───────┐    ┌──────────────┐
│dim_customers │────│  fct_sales   │────│ dim_products │
└──────────────┘    └──────┬───────┘    └──────────────┘
                           │
                    ┌──────┴───────┐
                    │dim_employees │
                    └──────────────┘
```

---

## 5. Data Marts Propostos

### 5.1 Mart de Vendas (mart_sales_summary)
- **Objetivo:** Análise de performance comercial
- **Usuários:** Diretoria, Gerentes de Vendas
- **Métricas principais:** Receita, ticket médio, taxa de atraso

### 5.2 Mart de Produtos (mart_product_performance)
- **Objetivo:** Gestão de portfólio e estoque
- **Usuários:** Compradores, Gerentes de Produto
- **Métricas principais:** Vendas por categoria, ranking, rotatividade

### 5.3 Mart de Clientes (mart_customer_analytics)
- **Objetivo:** CRM e segmentação
- **Usuários:** Marketing, Customer Success
- **Métricas principais:** RFM, LTV, segmentação

---

## 6. Dados Externos Integrados

### 6.1 ext_iso_countries
- **Uso:** Enriquecer a dimensão de clientes com código ISO e continente
- **Benefício:** Permite análises geográficas padronizadas (mapa por continente)

### 6.2 ext_exchange_rates
- **Uso futuro:** Converter valores para moeda base (USD)
- **Observação:** Requer implementação de macro para lookup de taxa por data

---

## 7. Próximos Passos Sugeridos

1. Implementar testes de qualidade de dados (`dbt test`)
2. Adicionar documentação inline nos modelos (`dbt docs generate`)
3. Configurar snapshots para dimensões SCD Type 2
4. Criar macros para conversão de moeda usando `ext_exchange_rates`