/*
This is the code I used to back up my database
newusers-MBP:assns456 EngerThen$ pg_dump -U postgres -d stocksdb > stocksdb_backup.sql
newusers-MBP:assns456 EngerThen$ psql -U postgres -d stocksdb
psql (10.4)
Type "help" for help.

stocksdb=# drop table Prices
stocksdb-# ;
DROP TABLE
stocksdb=# drop table Fundamentals;
DROP TABLE
stocksdb=# drop table Securities;
DROP TABLE
stocksdb=# drop table Top_performers;
DROP TABLE
stocksdb=# drop table potential_candidates_10;
DROP TABLE
stocksdb=# \q
newusers-MBP:assns456 EngerThen$ psql -U postgres -d stocksdb -f stocksdb_backup.sql
SET
SET
SET
SET
SET
 set_config 
------------
 
(1 row)

SET
SET
SET
CREATE EXTENSION
COMMENT
SET
SET
CREATE TABLE
ALTER TABLE
CREATE TABLE
ALTER TABLE
CREATE TABLE
ALTER TABLE
CREATE TABLE
ALTER TABLE
CREATE TABLE
ALTER TABLE
COPY 1608
COPY 10
COPY 851264
COPY 505
COPY 40
ALTER TABLE
ALTER TABLE
ALTER TABLE
newusers-MBP:assns456 EngerThen$ 
*/

--Question #2
CREATE TEMP TABLE portfolio_returns AS (
	SELECT ROW_NUMBER() OVER W AS num, a.tdate AS trading_date, a.symbol, b.total_assets, b.total_liability, b.net_worth, a.close AS current_price, LEAD(a.close) OVER W AS previous_price, (a.close / LEAD(a.close) OVER W)::NUMERIC(10,2) AS percent_returned 
	FROM Prices a 
	INNER JOIN potential_candidates_10 b USING(symbol)
	WINDOW W AS (PARTITION BY a.symbol ORDER BY a.tdate DESC)
);

CREATE VIEW portfolio_report AS (
	SELECT trading_date, symbol, total_assets,total_liability,net_worth, current_price, previous_price, percent_returned
	FROM portfolio_returns
	WHERE num = 1
	ORDER BY percent_returned DESC
);
SELECT * FROM portfolio_report;

--Question #3
/*
newusers-MBP:assns456 EngerThen$ psql -U postgres -tAF, -f Enger_Then_HW6.sql > myportfolio.csv
psql:Enger_Then_HW6.sql:12: NOTICE:  view "portfolio_report" will be a temporary view
newusers-MBP:assns456 EngerThen$
*/

 --Question #4
 DROP TABLE IF EXISTS Prices2017;
CREATE TABLE Prices2017 (
	tdate DATE NOT NULL,
	symbol TEXT NOT NULL,
	open NUMERIC(10,2),
	high NUMERIC(10,2),
	low NUMERIC(10,2),
	close NUMERIC(10,2),
	PRIMARY KEY(tdate, symbol)	
);

INSERT INTO Prices2017 (tdate, symbol, open, high, low, close) VALUES
('12/29/17','AAPL',170.52,170.59,169.22,169.23),
('12/29/17','BDX',216.37,218.25,213.95,214.06),
('12/29/17','DE',157.95,57.99,156.47,156.51),
('12/29/17','EMR',70.04,70.21,69.69,69.69),
('12/29/17','MCK',158.28,158.35,155.85,155.95),
('12/29/17','MSFT',85.63,86.05,85.5,85.54),
('12/29/17','NWSA',16.34,16.38,16.21,16.21),
('12/29/17','SJM',124.74,125.68,124.23,124.24),
('12/29/17','TGT',65.21,65.74,64.89,65.25),
('12/29/17','WMT',99.4,99.69,98.75,98.75);

CREATE TEMP TABLE returns2017 AS (
	SELECT a.tdate, a.symbol, a.close AS this_year_close, b.current_price AS last_year_close, (a.close / b.current_price)::NUMERIC(10,2) AS pct_returned
	FROM Prices2017 a
	INNER JOIN portfolio_returns b USING(symbol)
	WHERE num = 1
	ORDER BY pct_returned DESC
);
SELECT * FROM returns2017;

SELECT SUM(pct_returned) AS pct_returned_sum FROM returns2017;







