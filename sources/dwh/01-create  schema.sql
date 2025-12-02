-- Dimensão Tempo (Time Dimension)
CREATE TABLE Dim_Tempo (
    SK_Tempo INT PRIMARY KEY, -- Surrogate Key
    Data DATE NOT NULL UNIQUE,
    Ano INT NOT NULL,
    Trimestre INT NOT NULL,
    Mes INT NOT NULL,
    Nome_Mes VARCHAR(10) NOT NULL,
    Dia INT NOT NULL,
    Dia_Semana INT NOT NULL,
    Nome_Dia_Semana VARCHAR(10) NOT NULL,
    Semana_Do_Ano INT NOT NULL,
    Tipo_Dia VARCHAR(20) NOT NULL -- Ex: 'Dia Útil', 'Fim de Semana', 'Feriado'
) ENGINE=InnoDB;


-- Dimensão Cliente (Customer Dimension)
CREATE TABLE Dim_Cliente (
    SK_Cliente INT AUTO_INCREMENT PRIMARY KEY, -- Surrogate Key
    CustomerID_NK VARCHAR(5) NOT NULL UNIQUE, -- Natural Key (Chave do Sistema Fonte)
    Nome_Empresa VARCHAR(40) NOT NULL,
    Nome_Contato VARCHAR(30),
    Titulo_Contato VARCHAR(30),
    Endereco VARCHAR(60),
    Cidade VARCHAR(15),
    Regiao_Cliente VARCHAR(15),
    Pais VARCHAR(15),
    Telefone VARCHAR(24)
) ENGINE=InnoDB;


-- Dimensão Produto (Product Dimension)
CREATE TABLE Dim_Produto (
    SK_Produto INT AUTO_INCREMENT PRIMARY KEY, -- Surrogate Key
    ProductID_NK INT NOT NULL UNIQUE, -- Natural Key
    Nome_Produto VARCHAR(40) NOT NULL,
    Quantidade_Por_Unidade VARCHAR(20),
    Nivel_Reordenar SMALLINT,
    Descontinuado TINYINT(1),

    -- Atributos de Categoria (Desnormalizados)
    CategoryID_NK INT NOT NULL,
    Nome_Categoria VARCHAR(15) NOT NULL,
    Descricao_Categoria TEXT,

    -- Atributos de Fornecedor (Desnormalizados)
    SupplierID_NK INT NOT NULL,
    Nome_Fornecedor VARCHAR(40) NOT NULL,
    Pais_Fornecedor VARCHAR(15)
) ENGINE=InnoDB;


-- Dimensão Vendedor (Employee/Salesperson Dimension)
CREATE TABLE Dim_Vendedor (
    SK_Vendedor INT AUTO_INCREMENT PRIMARY KEY, -- Surrogate Key
    EmployeeID_NK INT NOT NULL UNIQUE, -- Natural Key
    Nome_Completo VARCHAR(50) NOT NULL, -- (FirstName + LastName)
    Titulo VARCHAR(30),
    Data_Contratacao DATE,
    Cidade_Vendedor VARCHAR(15),
    Pais_Vendedor VARCHAR(15)
    -- Opcional: Adicionar um campo para o nome do Gerente (ReportsTo)
) ENGINE=InnoDB;


-- Dimensão Frete/Envio (Shipping Dimension)
CREATE TABLE Dim_Frete (
    SK_Frete INT AUTO_INCREMENT PRIMARY KEY, -- Surrogate Key
    ShipperID_NK INT NOT NULL UNIQUE, -- Natural Key (para a empresa de envio)
    Nome_Transportadora VARCHAR(40) NOT NULL,
    Telefone_Transportadora VARCHAR(24),

    -- Detalhes do Envio
    Destinatario_Nome VARCHAR(40),
    Destinatario_Endereco VARCHAR(60),
    Destinatario_Cidade VARCHAR(15),
    Destinatario_Pais VARCHAR(15)
) ENGINE=InnoDB;


-- Tabela Fato de Vendas (Sales Fact Table)
CREATE TABLE Fato_Vendas (
    -- Chaves Substitutas (Foreign Keys para as Dimensões)
    SK_Venda BIGINT AUTO_INCREMENT PRIMARY KEY, -- Chave Primária do Fato
    SK_Tempo_Pedido INT NOT NULL,
    SK_Tempo_Requerido INT,
    SK_Tempo_Enviado INT,
    SK_Cliente INT NOT NULL,
    SK_Vendedor INT NOT NULL,
    SK_Produto INT NOT NULL,
    SK_Frete INT NOT NULL,

    -- Chaves Naturais de Transação (Opcional, mas útil para rastreamento)
    OrderID_NK INT NOT NULL,
    
    -- Fatos/Métricas (Measures)
    Preco_Unitario_Transacao DECIMAL(10,2) NOT NULL, -- Preço no momento da venda
    Quantidade SMALLINT NOT NULL,
    Desconto DECIMAL(4,2) NOT NULL,
    Frete_Total DECIMAL(10,2), -- Frete do pedido inteiro (pode ser repetido por linha)
    
    -- Campos Calculados (Métricas Chave do DWH)
    Valor_Venda_Liquido DECIMAL(18,2) NOT NULL, -- (Preco_Unitario * Quantidade) * (1 - Desconto)
    Valor_Frete_Rateado DECIMAL(18,2), -- Frete rateado pela linha (simplificando, pode ser o Frete_Total)
    
    -- Chaves Estrangeiras (Foreign Keys)
    CONSTRAINT FK_FatoVendas_TempoPedido FOREIGN KEY (SK_Tempo_Pedido) 
        REFERENCES Dim_Tempo(SK_Tempo),
    CONSTRAINT FK_FatoVendas_TempoRequerido FOREIGN KEY (SK_Tempo_Requerido) 
        REFERENCES Dim_Tempo(SK_Tempo),
    CONSTRAINT FK_FatoVendas_TempoEnviado FOREIGN KEY (SK_Tempo_Enviado) 
        REFERENCES Dim_Tempo(SK_Tempo),
    CONSTRAINT FK_FatoVendas_Cliente FOREIGN KEY (SK_Cliente) 
        REFERENCES Dim_Cliente(SK_Cliente),
    CONSTRAINT FK_FatoVendas_Vendedor FOREIGN KEY (SK_Vendedor) 
        REFERENCES Dim_Vendedor(SK_Vendedor),
    CONSTRAINT FK_FatoVendas_Produto FOREIGN KEY (SK_Produto) 
        REFERENCES Dim_Produto(SK_Produto),
    CONSTRAINT FK_FatoVendas_Frete FOREIGN KEY (SK_Frete) 
        REFERENCES Dim_Frete(SK_Frete)
) ENGINE=InnoDB;