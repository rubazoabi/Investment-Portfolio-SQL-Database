create database InvestmentPortfolio
use InvestmentPortfolio
----Users
--Assets_sector
--Assets
--Portfolio
--Portfolio_Allocation
--Transactions
--Fees
--Dividends
--Assets_History
--Market_Index
--Market_Index_Prices
--Asset_Risk_Metrics

--The project focuses on assets and analyzing the investment performance( profit/ loss)
--The users table has the essencial information about investors.
go 

CREATE TABLE Users
(
    user_id INT IDENTITY(1,1) NOT NULL,
    Last_Name NVARCHAR(50) NOT NULL,
    First_Name NVARCHAR(50) NOT NULL,
    Birth_Date DATE NOT NULL,
    City NVARCHAR(50) NULL,
    Country NVARCHAR(50) NULL,
	Region NVARCHAR(50) NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    CONSTRAINT PK_Users PRIMARY KEY CLUSTERED (user_id),
    CONSTRAINT CK_Birth_date 
        CHECK (Birth_Date < GETDATE())
)
--This table categorizes assets by economic sector
--which helps analyzing and comparing asset risk characteristics and investment behavior.
--For example: assets in the Technology Sector are associated with higher volatility compared to defensive sectors.
--Therefore they carry higher risk.
go

CREATE TABLE Assets_sector 
(
sector_id int IDENTITY (1, 1) NOT NULL ,
sector_name nvarchar(50) NOT NULL,
CONSTRAINT PK_sector PRIMARY KEY  CLUSTERED 
	(
		sector_id ),
CONSTRAINT UQ_sector_name 
        UNIQUE (sector_name)

)

--This table represents financial Assets types.
--(Efts, stocks, crypto..)

go 
CREATE TABLE Asset_Type
(
asset_type_ID INT IDENTITY(1,1) PRIMARY KEY,
asset_type NVARCHAR(50) NOT NULL UNIQUE
)

--This table represents financial Assets categoried by their types.
--(Efts, stocks, crypto..)
--The Assets table serves as a central reference for portfolios, transactions,
--and historical price data, enabling consistent tracking and analysis of investments.
go 

Create TABLE Assets
(
asset_Id int identity(1,1) NOT NULL,
symbol nvarchar (20) NOT NULL ,
asset_type_ID int not null,
sector_Id int not null,
asset_name nvarchar(100),
CONSTRAINT PK_Assets PRIMARY KEY  CLUSTERED 
	(
		asset_Id ),
CONSTRAINT FK_asset_type_id FOREIGN KEY (sector_id ) REFERENCES dbo.Asset_Type (
		asset_type_ID),
        
CONSTRAINT FK_asset_sector_id FOREIGN KEY (sector_id ) REFERENCES dbo.Assets_sector (
		sector_Id),
        
CONSTRAINT UQ_Assets_symbol UNIQUE (symbol)
)

go

	-- Every investor can create and manage multiple portfolio
	-- Every portfolio represents distinct investment strategy or goal, 
	-- strategies like: long-term , short_term, growth, retiring savings...-
	-- Each portfolio has different risk level based on its investment strategy

create table Portfolio
(
User_Id int not NULL ,
Portfolio_ID int IDENTITY (1, 1) NOT NULL ,
portfolio_name nvarchar (50) NOT NULL ,
created_at date not NULL,
Risk_level nvarchar(50) NOT NULL,
CONSTRAINT PK_Portfolio PRIMARY KEY  CLUSTERED 
        (Portfolio_ID ), 
CONSTRAINT FK_User_ID_portfolio FOREIGN KEY (User_Id ) REFERENCES dbo.Users (
		User_Id
	),
CONSTRAINT CK_created_at CHECK (created_at <= GETDATE()),
CONSTRAINT CK_Risk_level CHECK (Risk_level IN ('Low','Medium','High'))
)


go 

--This table represents the different assets included in each portfolios and their allocation weight
--according to the portfolio’s goal and risk profile.
--Including Market_index which reflects the portfolio’s overall investment strategy. 
--for example: S&P 500 is mostly used for long term assets


CREATE TABLE Portfolio_Allocation
(
Asset_Id int not NULL,
portfolio_id int not NULL,
target_weight decimal(5,4) NOT NULL,
rebalance_frequency nvarchar(50) not NULL,
Market_index_name nvarchar(50)  NULL,
CONSTRAINT PK_Portfolio_Allocation 
        PRIMARY KEY (portfolio_id, asset_id),
CONSTRAINT FK_Portfolio_Allocation_asset_id FOREIGN KEY (Asset_id ) REFERENCES dbo.Assets (
		Asset_id
) ,
CONSTRAINT FK_Portfolio_Allocation_portfolio_id FOREIGN KEY (portfolio_id ) REFERENCES dbo.Portfolio (
		portfolio_id
),
CONSTRAINT CK_rebalance_frequency CHECK (rebalance_frequency IN ('Monthly','Quarterly','Yearly')),
CONSTRAINT CK_target_weight 
        CHECK (target_weight BETWEEN 0 AND 1)
)


----This table records the transiction history for each user's portfolios 
-- each transiction is defined by the asset, transaction type (BUY or SELL), quantity, and transaction date.
-- This table enables traking and analysis of investments activity by allowing 
-- calculation loss/profit both for portfolio and user 
-- The results reflects investments performances and help evaluate the success 
--or failure of different investment strategies and portfolio objectives.

create TABLE Transactions
(
Transaction_ID int identity(1,1) NOT NULL,
Portfolio_Id int NOT NULL,
Asset_Id int NOT NULL,
Transaction_type nvarchar (10) NOT NULL ,
Quantity decimal(18,6) NOT NULL,
Transaction_date date NOT NULL,
CONSTRAINT PK_Transaction_id PRIMARY KEY  CLUSTERED (Transaction_ID),
CONSTRAINT FK_portfolio_ID_transiction FOREIGN KEY (Portfolio_Id ) REFERENCES dbo.portfolio (
		Portfolio_Id
	),
CONSTRAINT FK_asset_ID_Transaction FOREIGN KEY (Asset_Id ) REFERENCES dbo.assets (
		Asset_Id
	),
CONSTRAINT CK_Transaction_type CHECK (Transaction_type IN ('BUY', 'SELL')),
CONSTRAINT CK_Quantity CHECK ( Quantity>0),
CONSTRAINT CK_Transaction_date CHECK ( Transaction_date<=getdate())
)

go 

--This table represents the fees/taxes charged by each company or broker 
-- for executing buy and sell transactions.
--Enables accurate calculation of total transaction costs, profit or loss for each investment.

CREATE TABLE FEES
(
Asset_id int NOT NULL,
Fee_type nvarchar (20) NOT NULL,
Fee_amount decimal(18,6) NOT NULL,
Unit_Type nvarchar (20) NOT NULL,
Notes nvarchar (30),
CONSTRAINT PK_Fees 
        PRIMARY KEY (Asset_id, Fee_type),
CONSTRAINT FK_asset_ID_fees FOREIGN KEY (Asset_id ) REFERENCES dbo.Assets (
		Asset_id
) ,
CONSTRAINT CK_Fee_amount CHECK (Fee_amount >= 0),
CONSTRAINT CK_Unit_Type CHECK (Unit_Type IN ('Percent', 'USD', 'USD_Per_Share','USD_Per_Trade_Value'))
)




--This tables represnts dividend information for assets that distribute dividends.
--Dividends represent a passive income returned to investors in addition to price appreciation.
--types of Dividends:
--3M: Quarterly dividend (every 3 months)                                             
--O:One-time dividend (special dividend)                                             
--I: Interim dividend (partial / mid-year, sometimes used by UK / European companies) 
--It helps calucating total profit or loss from an investment, including both price changes and dividend income.
--calculation:
--Dividend Yield = how much income you earn from dividends relative to the stock price
--Dividend Yield (%) = (Annual Dividend per Share ÷ Current Share Price) × 100
-- P/L_Div = profit/loss from dividend vs. cost 
--This information enables analysis of strategies and dividend-based investment performance.
go

CREATE TABLE dividends
(
dividend_id int IDENTITY (1, 1) NOT NULL ,
Asset_Id int not NULL,
dividend_amount DECIMAL(18,6) NOT NULL, 
type nvarchar(10) NOT NULL,
ex_date date NOT NULL,
payment_date date NOT NULL,
CONSTRAINT PK_divendens PRIMARY KEY  CLUSTERED 
	(
		dividend_id),
CONSTRAINT FK_divendens_asset_id FOREIGN KEY (Asset_id ) REFERENCES dbo.Assets (
		Asset_id
) ,
CONSTRAINT CK_dividends_dates CHECK (ex_date < payment_date),
CONSTRAINT CK_dividend_amount CHECK (dividend_amount>=0),
CONSTRAINT CK_type CHECK (type IN ('3M', 'I', 'O'))
)


go 

--This table has daily historical price data for each asset.
--It includes the opening price ( first traded price of the day)
--closing price, , as well as the daily high and low prices.
--It records total number of shares or units traded for the asset on a given date (volume)
--Enabling us to compare and analyze investment performance and trading strategies over time.
--columns:
--Open The price at which the asset first traded when the market opened on that day.
--High The highest price the asset reached during the trading day.
--Low The lowest price the asset reached during the trading day.
--Close Price The price of the last trade when the market closed that day. 
--Vol. (Volume)	Number of shares/units that were traded during the day. 



CREATE TABLE Assets_History
( 
Asset_Id int NOT NULL,
price_date date NOT NULL,
close_price DECIMAL(18,6) NOT NULL,
open_price DECIMAL(18,6) NOT NULL,
high_P  DECIMAL(18,6) NOT NULL,
low_P  DECIMAL(18,6) NOT NULL,
Volume BIGINT ,
 CONSTRAINT PK_Assets_History 
        PRIMARY KEY (Asset_Id, price_date),
CONSTRAINT FK_asset_ID_History FOREIGN KEY (Asset_Id ) REFERENCES dbo.assets (
		Asset_Id
),
CONSTRAINT CK_price_date CHECK (price_date<=getdate()),
CONSTRAINT CK_Assets_History_Prices CHECK 
           ( close_price >= 0 AND
            open_price >= 0 AND
            high_P >= 0 AND
            low_P >= 0
            ),
CONSTRAINT CK_Assets_History_HighLow CHECK (high_P >= low_P),
CONSTRAINT CK_Assets_History_Volume CHECK (Volume IS NULL OR Volume >= 0)
)
 
go 

--The Market_Indexes table stores the list of market benchmarks
--such as the S&P 500, NASDAQ Composite, and sector-specific.
--These indexes are used as reference points for evaluating portfolio and asset performance.


CREATE TABLE Market_Index
(
index_id int IDENTITY (1, 1) NOT NULL ,
Index_name nvarchar(50) NOT NULL,
Description nvarchar(100)  NULL,
Sector_id int NULL,
CONSTRAINT PK_index_id PRIMARY KEY  CLUSTERED (index_id),
CONSTRAINT FK_sector_id FOREIGN KEY (Sector_id ) REFERENCES dbo.assets_sector (
		Sector_id
),
CONSTRAINT UQ_Market_Index_Name UNIQUE (index_name)
)

 go
--The Market_Index_Prices table stores historical daily data and values (price) by date for each market index, 
--enable comparison between portfolio performance to relevant market
--benchmarks over time


create table Market_Index_Prices
(
index_id int  NOT NULL ,
Market_value decimal(18,6) not null,
Market_price_Date date NOT NULL,
CONSTRAINT PK_Market_Index_Prices PRIMARY KEY (index_id, Market_price_Date),
CONSTRAINT FK_Market_Index_Prices FOREIGN KEY (index_id ) REFERENCES dbo.Market_Index (
		index_id ),
CONSTRAINT CK_Market_price_Date CHECK (Market_price_Date<=getdate()),
CONSTRAINT CK_Market_value CHECK( Market_value >=0)
)

go
--This table represnets the ups and downs and describe the price behavior of each asset over time.
-- helping assess investment risk and volatility.
--allowing better analyzies of profits/loss percentage and supports more informed transaction decisions..
--Volatility = how much an asset’s price fluctuates over time.
--High volatility → big ups and downs → higher risk
--Low volatility → stable movement → lower risk
--Beta	Market dependency - How much the asset moves compared to the market.
--Max Drawdown	Worst historical loss -- Max Drawdown = largest peak-to-trough loss over a period.
--This table should be updated weekly with new risk metrics using
--historical price data to ensure accurate and up-to-date risk analysis.

CREATE TABLE Asset_Risk_Metrics
(
Asset_Id int not NULL,
volatility decimal(18,6) NOT NULL,
beta decimal(18,6) not NULL,
Max_Drawdown decimal(18,6) not NULL,
metric_date date not null,
CONSTRAINT PK_Asset_Risk_Metrics PRIMARY KEY ( Asset_Id, metric_date),
CONSTRAINT FK_Asset_Risk_Metrics_asset_id FOREIGN KEY (Asset_id) REFERENCES dbo.Assets (
		Asset_id),
CONSTRAINT CK_metric_date CHECK ( metric_date<=getdate()),
CONSTRAINT CK_Asset_Risk_Metrics CHECK 
           (volatility>=0 AND max_drawdown BETWEEN 0 AND 100)
		   
)

--Inserting data using CSV files

--go 

--insert into Users (Last_Name,First_Name, Birth_Date,City,Country,region, Email)
--select
--LTRIM(RTRIM(LastName)),
--LTRIM(RTRIM(FirstName)),
--convert( date, BirthDate, 103),
--LTRIM(RTRIM(City)),
--LTRIM(RTRIM(Country)),
--LTRIM(RTRIM(Region)),
--LTRIM(RTRIM(E_mail))
--from users_data


--go

--insert into Assets_Sector
--select 
--LTRIM(RTRIM(sector_name))
--from Assets_Sector_data


--go 


--INSERT INTO Asset_Type(asset_type)
--VALUES
--('Stock'),
--('Crypto'),
--('ETFs')

--go

--insert into Assets (symbol,asset_type_ID,sector_id,asset_name)
--select LTRIM(RTRIM(AD.symbol)), LTRIM(RTRIM(AD.asset_type_ID)), AD.sector_id, 
--LTRIM(RTRIM(AD.asset_name))
--from assets_data AD



--insert into Assets_History (Asset_Id,price_date,close_price,open_price,high_P,low_P,Volume)
--select  AD.Asset_Id, 
--convert( date, AD.date, 103),
--AD.price,
--AD.open,
--AD.high,
--AD.low,
--AD.Volume
--from Assets_history_data AD
--select* from Assets_History
--go 

--insert into FEES ( Asset_id, Fee_type,Fee_amount,Unit_Type,Notes)
--select  asset_id,
--LTRIM(RTRIM(fee_type)),
--fee_amount,
--unit_type,
--LTRIM(RTRIM(Notes))
--from Fees_data

--go

--insert into dividends 
--select
--Asset_Id,
--dividend_amount,
--LTRIM(RTRIM(Type)),
--CONVERT( date, ex_date, 103),
--CONVERT( date, payment_date, 103)
--from dividends_data

--go 
--select* from Market_Index

--INSERT INTO Market_Index( Index_name, Description, Sector_id)
--VALUES
--('S&P 500','Broad US large-cap index covering 500 major US companies',NULL),
--('NASDAQ Composite','US index, tech-heavy but multi-sector',NULL),
--('Dow Jones Industrial Average (DJIA)','30 large, established US companies',NULL),
--('Russell 2000','US small-cap stocks',NULL),

--('S&P Technology Sector','Tech companies in S&P 500',1),
--('S&P Financial Sector','Financial companies in S&P 500',2),
--('S&P Consumer Discretionary Sector','Consumer cyclical companies',3),
--('S&P Industrials Sector','Industrial companies',6),
--('S&P Materials Sector','Materials companies',9),
--('S&P Utilities Sector','Utility companies',11),

--('Bloomberg Commodity Index','Major commodities benchmark',NULL),

--('Nasdaq-100','100 largest non-financial Nasdaq companies',NULL),

--('MSCI World','Global developed markets',NULL),
--('MSCI Emerging Markets','Emerging market stocks',NULL)


--select* from Market_Index

--go

--insert into Market_Index_Prices (index_id ,Market_value, Market_price_Date)
--select
--index_id,
--Market_value,
--convert( date, Price_date, 103)
--from Market_Index_Price_data



--insert into Portfolio( User_Id, portfolio_name, created_at, Risk_level)
--select User_Id,
--LTRIM(RTRIM(portfolio_name)),
--CONVERT(date, created_at, 103),
--LTRIM(RTRIM(risk_level))
--from Portfolio_data


--go

--insert into Portfolio_Allocation (Asset_Id, portfolio_id,target_weight,rebalance_frequency,Market_index_name)
--select asset_name ,portfolio_id, target_weight,
--LTRIM(RTRIM(rebalance_frequency)),
--LTRIM(RTRIM(Market_index))
--from Portfolio_Allocation_data

--go 



--insert into Transactions(Portfolio_Id, Asset_Id,Transaction_type,Quantity,Transaction_date)
--select Portfolio_ID, Asset,
--LTRIM(RTRIM(Transaction_Type)),	Quantity, 
--CONVERT(date,Transaction_Date, 103)
--from Transactions_data

--go

--insert into Asset_Risk_Metrics(Asset_Id, volatility,beta,Max_Drawdown,metric_date)
--select
--Asset_Id, Volatility, Beta, Max_Drawdown, CONVERT(date, rd.date, 103)
--from Asset_Risk_Metrics_data RD
