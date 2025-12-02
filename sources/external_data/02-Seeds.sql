-- Exemplo de população de países
INSERT INTO `ext_iso_countries` (`iso_alpha2`, `iso_alpha3`, `country_name_en`, `continent_name`) VALUES
('DE', 'DEU', 'Germany', 'Europe'),
('US', 'USA', 'United States', 'Americas'),
('BR', 'BRA', 'Brazil', 'Americas'),
('UK', 'GBR', 'United Kingdom', 'Europe'),
('FR', 'FRA', 'France', 'Europe');

-- Exemplo de população de taxas de câmbio (Setembro de 1996 - época do Northwind)
-- Significa: Em 04/09/1996, 1 USD comprava 1.505 Marcos Alemães (DEM - moeda pré-Euro)
INSERT INTO `ext_exchange_rates` (`rate_date`, `base_currency_code`, `target_currency_code`, `exchange_rate`) VALUES
('1996-09-04', 'USD', 'DEM', 1.505000), -- Germany (pre-Euro)
('1996-09-04', 'USD', 'BRL', 1.015000), -- Brazil (Real tinha paridade próxima ao dólar no início)
('1996-09-04', 'USD', 'GBP', 0.643000), -- UK Pound
('1996-09-05', 'USD', 'DEM', 1.512000),
('1996-09-05', 'USD', 'BRL', 1.016000);