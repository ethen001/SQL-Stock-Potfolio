\echo 'Calculate all annual returns for each symbol for each year and sort them by performance.'

CREATE TEMP TABLE partitioned_dates AS (
	SELECT tdate,
		ROW_NUMBER() OVER (PARTITION BY DATE_TRUNC('year', tdate) ORDER BY tdate DESC) AS num 
	FROM Prices
);
SELECT * FROM partitioned_dates LIMIT 20;

\echo 'Select last day of each year as ending date'
CREATE TEMP TABLE end_dates AS (
	SELECT tdate AS end_dates
	FROM partitioned_dates
	WHERE num = 1
	ORDER BY tdate DESC
);
SELECT * FROM end_dates;

\echo 'Select all rows whose trading date matches one of the dates in end_dates'
CREATE TEMP TABLE year_end_prices AS (
	SELECT tdate, symbol, close
	FROM Prices
	WHERE tdate IN (SELECT * FROM end_dates)
	ORDER BY symbol, close DESC
);

SELECT * FROM year_end_prices LIMIT 20;

\echo 'Select all companies with close, prior close and the annual return'
CREATE TEMP TABLE annual_returns AS (
	SELECT tdate, symbol, close AS year_price,
		LAG(close) OVER (PARTITION BY symbol ORDER BY tdate) AS prior_year_price,(close / (LAG(close) OVER (PARTITION BY symbol ORDER BY tdate)))::NUMERIC(10,2) AS pct_returned
	FROM year_end_prices
	
);
SELECT * FROM annual_returns LIMIT 50; 

CREATE TABLE Top_performers AS (
	SELECT DISTINCT * 
	FROM annual_returns 
	WHERE pct_returned IS NOT NULL
	ORDER BY pct_returned DESC
	LIMIT 40 OFFSET 3
);
SELECT * FROM Top_performers;

select a.end_dates, b.symbol, b.gross_margin from end_dates a left join fundamentals b ON a.end_dates = b.year_ending right JOIN top_performers c ON b.symbol = c.symbol WHERE b.gross_margin IS NOT NULL ORDER BY c.symbol ASC LIMIT 50;


