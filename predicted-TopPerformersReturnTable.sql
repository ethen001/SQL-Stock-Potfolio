--check data
SELECT * FROM Top_performers;

\echo '\nGet the fundamentals of top performing companies from all available years\n'
CREATE TEMP TABLE top_performers_fundamentals AS (
	SELECT DISTINCT a.*
	FROM Fundamentals a
	INNER JOIN Top_performers b USING(symbol)
	ORDER BY symbol, a.year_ending DESC
);
SELECT * FROM top_performers_fundamentals LIMIT 50;

\echo '\nnet worth of top companies\n'
SELECT symbol, year_ending, (total_assets - total_liability) AS net_worth
FROM top_performers_fundamentals
ORDER BY symbol, year_ending DESC
;

\echo '\nnet income growth rate year over year\n'
SELECT symbol, year_ending, net_income, LEAD(net_income) OVER W AS past_ni, ((net_income - LEAD(net_income) OVER W)::NUMERIC / ABS(LEAD(net_income) OVER W)::NUMERIC)::NUMERIC(10,3) * 100 AS ni_growth_rate
FROM top_performers_fundamentals
WINDOW W AS (PARTITION BY symbol ORDER BY year_ending DESC)
;

\echo '\nrevenue growth rate year over year\n'
SELECT symbol, year_ending, total_revenue, LEAD(total_revenue) OVER W AS past_trev, ((total_revenue - LEAD(total_revenue) OVER W)::NUMERIC / ABS(LEAD(total_revenue) OVER W)::NUMERIC)::NUMERIC(10,3) * 100 AS trev_growth_rate
FROM top_performers_fundamentals
WINDOW W AS (PARTITION BY symbol ORDER BY year_ending DESC)
;

\echo '\nearning per share growth\n'
SELECT symbol, year_ending, earnings_per_share, LAG(earnings_per_share) OVER W as last_eps, ((earnings_per_share - LAG(earnings_per_share) OVER W)::NUMERIC / ABS(LAG(earnings_per_share) OVER W)::NUMERIC)::NUMERIC(10,3) * 100 AS eps_growth_rate
FROM top_performers_fundamentals
WINDOW W AS (PARTITION BY symbol ORDER BY year_ending)
;

CREATE TEMP TABLE share_prices AS (
	SELECT DISTINCT a.tdate, a.symbol, a.close AS stock_price
	FROM Prices a
	INNER JOIN Fundamentals b ON a.tdate = b.year_ending AND a.symbol = b.symbol
	ORDER BY a.symbol
);
\echo '\nPrice-to-earning ratio\n'
SELECT a.symbol, a.year_ending, b.stock_price, a.earnings_per_share, (b.stock_price / a.earnings_per_share)::NUMERIC(10,2) AS price_earnings_ratio
FROM top_performers_fundamentals a
INNER JOIN share_prices b ON a.year_ending = b.tdate AND a.symbol = b.symbol
ORDER BY symbol, a.year_ending DESC
;

\echo 'earnings before interest & taxes vs total_liability'
SELECT symbol, year_ending, earning_bf_interest_and_tax, total_liability, (earning_bf_interest_and_tax - total_liability) AS cash_vs_liabilities
FROM top_performers_fundamentals
;

-- Part two of the assignment
-- I will look at net worth and PE ratio to determine potential stocks to invest

CREATE TEMP TABLE narrowed_fundamentals AS (
SELECT symbol, year_ending, total_assets, total_liability, (total_assets - total_liability) AS net_worth
FROM Fundamentals 
WINDOW W AS (PARTITION BY symbol ORDER BY year_ending DESC)
);

CREATE TEMP TABLE potential_candidates AS (
	SELECT *
	FROM narrowed_fundamentals
	WHERE EXTRACT(YEAR FROM year_ending) = 2016
	ORDER BY net_worth DESC
	LIMIT 30
);
SELECT * FROM potential_candidates;
 
-- Part three of assignment
CREATE temp TABLE pot_candidates_sector AS (
	SELECT ROW_NUMBER() OVER (PARTITION BY b.sector) as num, a.*, b.sector
	FROM potential_candidates a
	INNER JOIN Securities b USING(symbol)
);

CREATE TABLE potential_candidates_10 AS (
	SELECT *
	FROM pot_candidates_sector
	WHERE num IN (1,2)
	LIMIT 10
);

\echo '\nI chose the following list of companies becasue their net worth display good financial health and therefore financial stability. Their net worth, total assets and total liabilities are similar to data from companies with good anual returns. This companies belong to different sector which will keep my money safe in case of a specific market falling.\n'
SELECT * FROM potential_candidates_10;







	





