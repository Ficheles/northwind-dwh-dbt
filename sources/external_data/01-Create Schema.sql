-- ==============================================================
-- Criação do Banco de Dados para Dados Externos
-- ==============================================================
CREATE DATABASE IF NOT EXISTS `ExternalData`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `ExternalData`;
-- ==============================================================
-- Tabela 1: Códigos de País ISO 3166 (Dados Estáticos)
-- ==============================================================
-- Esta tabela servirá como referência mestre para padronizar
-- os campos de país (Country) do Northwind.
-- ==============================================================
CREATE TABLE IF NOT EXISTS `ext_iso_countries` (
    `iso_alpha2` CHAR(2) NOT NULL COMMENT 'Código ISO de 2 letras (ex: BR, DE, US). Chave Primária ideal para joins.',
    `iso_alpha3` CHAR(3) NOT NULL COMMENT 'Código ISO de 3 letras (ex: BRA, DEU, USA). Útil para algumas ferramentas de BI.',
    `iso_numeric` CHAR(3) NULL COMMENT 'Código numérico ISO.',
    `country_name_en` VARCHAR(100) NOT NULL COMMENT 'Nome padrão do país em Inglês.',
    `continent_name` VARCHAR(50) NULL COMMENT 'Continente para agrupamentos maiores (ex: Europe, Americas).',
    `region_subdivision` VARCHAR(100) NULL COMMENT 'Sub-região (ex: Western Europe, South America).',
    PRIMARY KEY (`iso_alpha2`),
    UNIQUE INDEX `idx_iso_alpha3` (`iso_alpha3`),
    INDEX `idx_country_name` (`country_name_en`) -- Índice para facilitar o lookup pelo nome que vem do Northwind
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Tabela de referência estática para códigos de país ISO 3166';


-- ==============================================================
-- Tabela 2: Taxas de Câmbio Históricas (Dados Temporais)
-- ==============================================================
-- Armazena a taxa de conversão diária.
-- Assumimos que a moeda base da contabilidade do Northwind é USD.
-- ==============================================================
CREATE TABLE IF NOT EXISTS `ext_exchange_rates` (
    `rate_date` DATE NOT NULL COMMENT 'A data de referência da taxa de câmbio.',
    `base_currency_code` CHAR(3) NOT NULL DEFAULT 'USD' COMMENT 'A moeda de origem (fixa em USD para este cenário).',
    `target_currency_code` CHAR(3) NOT NULL COMMENT 'A moeda de destino (ex: EUR, BRL, GBP).',
    `exchange_rate` DECIMAL(18, 6) NOT NULL COMMENT 'Quantas unidades da moeda destino compram 1 unidade da moeda base.',
    PRIMARY KEY (`rate_date`, `target_currency_code`), -- A chave é composta pela data E a moeda
    INDEX `idx_rate_date` (`rate_date`) -- Índice crucial para performance nos joins com OrderDate
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Taxas de câmbio diárias históricas em relação ao USD';

