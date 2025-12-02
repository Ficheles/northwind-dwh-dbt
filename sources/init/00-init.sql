-- Criação dos bancos de dados (schemas no MySQL)
CREATE DATABASE IF NOT EXISTS northwind;
CREATE DATABASE IF NOT EXISTS dwh_staging;
CREATE DATABASE IF NOT EXISTS dwh;
CREATE DATABASE IF NOT EXISTS dwh_mart_sales;
CREATE DATABASE IF NOT EXISTS dwh_mart_products;
CREATE DATABASE IF NOT EXISTS dwh_mart_customers;
CREATE DATABASE IF NOT EXISTS snapshots;
CREATE DATABASE IF NOT EXISTS external_data;

-- Permissões para o usuário dbt
GRANT ALL PRIVILEGES ON northwind.* TO 'user'@'%';
GRANT ALL PRIVILEGES ON dwh_staging.* TO 'user'@'%';
GRANT ALL PRIVILEGES ON dwh.* TO 'user'@'%';
GRANT ALL PRIVILEGES ON dwh_mart_sales.* TO 'user'@'%';
GRANT ALL PRIVILEGES ON dwh_mart_products.* TO 'user'@'%';
GRANT ALL PRIVILEGES ON dwh_mart_customers.* TO 'user'@'%';
GRANT ALL PRIVILEGES ON snapshots.* TO 'user'@'%';
GRANT ALL PRIVILEGES ON external_data.* TO 'user'@'%';

FLUSH PRIVILEGES;

-- Tabelas de Dados Externos no banco OLTP
USE external_data;

CREATE TABLE IF NOT EXISTS ext_iso_countries (
    iso_alpha2 CHAR(2) PRIMARY KEY,
    iso_alpha3 CHAR(3) NOT NULL,
    country_name_en VARCHAR(100) NOT NULL,
    continent_name VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS ext_exchange_rates (
    rate_id INT AUTO_INCREMENT PRIMARY KEY,
    rate_date DATE NOT NULL,
    base_currency_code CHAR(3) NOT NULL,
    target_currency_code CHAR(3) NOT NULL,
    exchange_rate DECIMAL(12,6) NOT NULL,
    UNIQUE KEY uk_rate (rate_date, base_currency_code, target_currency_code)
);

-- Dados de países
INSERT INTO ext_iso_countries (iso_alpha2, iso_alpha3, country_name_en, continent_name) VALUES
('DE', 'DEU', 'Germany', 'Europe'),
('US', 'USA', 'United States', 'Americas'),
('BR', 'BRA', 'Brazil', 'Americas'),
('UK', 'GBR', 'United Kingdom', 'Europe'),
('FR', 'FRA', 'France', 'Europe'),
('MX', 'MEX', 'Mexico', 'Americas'),
('CA', 'CAN', 'Canada', 'Americas'),
('AR', 'ARG', 'Argentina', 'Americas'),
('AT', 'AUT', 'Austria', 'Europe'),
('BE', 'BEL', 'Belgium', 'Europe'),
('CH', 'CHE', 'Switzerland', 'Europe'),
('DK', 'DNK', 'Denmark', 'Europe'),
('ES', 'ESP', 'Spain', 'Europe'),
('FI', 'FIN', 'Finland', 'Europe'),
('IE', 'IRL', 'Ireland', 'Europe'),
('IT', 'ITA', 'Italy', 'Europe'),
('NO', 'NOR', 'Norway', 'Europe'),
('PL', 'POL', 'Poland', 'Europe'),
('PT', 'PRT', 'Portugal', 'Europe'),
('SE', 'SWE', 'Sweden', 'Europe'),
('VE', 'VEN', 'Venezuela', 'Americas')
ON DUPLICATE KEY UPDATE country_name_en = VALUES(country_name_en);

-- Dados de taxas de câmbio (época do Northwind ~1996-1998)
INSERT INTO ext_exchange_rates (rate_date, base_currency_code, target_currency_code, exchange_rate) VALUES
('1996-09-04', 'USD', 'DEM', 1.505000),
('1996-09-04', 'USD', 'BRL', 1.015000),
('1996-09-04', 'USD', 'GBP', 0.643000),
('1996-09-04', 'USD', 'FRF', 5.120000),
('1997-01-01', 'USD', 'DEM', 1.540000),
('1997-01-01', 'USD', 'BRL', 1.040000),
('1997-01-01', 'USD', 'GBP', 0.590000),
('1998-01-01', 'USD', 'DEM', 1.790000),
('1998-01-01', 'USD', 'BRL', 1.120000),
('1998-01-01', 'USD', 'GBP', 0.610000);