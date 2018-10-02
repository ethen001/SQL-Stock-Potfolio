--Drop database if already created

DROP DATABASE IF EXISTS stocksdb;

--create database

CREATE DATABASE stocksdb;

--drop tables if already in database

DROP TABLE IF EXISTS Prices;
DROP TABLE IF EXISTS Fundamentals;
DROP TABLE IF EXISTS Securities;

--Create Tables

CREATE TABLE Prices (
	tdate DATE NOT NULL,
	symbol TEXT NOT NULL,
	open NUMERIC,
	close NUMERIC,
	low NUMERIC,
	high NUMERIC,
	volume INTEGER,
	PRIMARY KEY(tdate, symbol)
);

CREATE TABLE Fundamentals (
	id INTEGER PRIMARY KEY,
	symbol TEXT NOT NULL,
	year_ending DATE,
	cash_and_cash_equiv BIGINT,
	earning_bf_interest_and_tax BIGINT,
	gross_margin INTEGER,
	net_income BIGINT,
	total_assets NUMERIC,
	total_liability NUMERIC,
	total_revenue NUMERIC,
	year INTEGER,
	earnings_per_share NUMERIC,
	shares_outstanding NUMERIC
);

CREATE TABLE Securities (
	symbol TEXT PRIMARY KEY,
	company TEXT NOT NULL,
	sector TEXT,
	sub_industrial TEXT,
	it_date DATE
);

--add values to tables

\COPY Prices FROM './data/prices.csv/' WITH (FORMAT csv);
\COPY Fundamentals FROM './data/fundamentals.csv/' WITH (FORMAT csv);
\COPY Securities FROM './data/securities.csv/' WITH (FORMAT csv);
\pset footer off

\echo '\nPrices Table.\n'
SELECT * FROM Prices WHERE symbol <> 'WLTW' LIMIT 20 ;

\echo 'Fundamentals Table.\n'
SELECT * FROM Fundamentals LIMIT 20;

\echo 'Securities Table.\n'
SELECT * FROM Securities LIMIT 20;


















