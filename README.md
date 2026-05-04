# Investment Portfolio SQL Database

This project presents the design and implementation of a relational database for managing investment portfolios, including assets, transactions, dividends, and market index data.

The goal of the project is to simulate a real-world financial system and enable analysis of portfolio performance, profitability, and allocation strategies.

---

###  Key Features

- Structured relational database design (SQL Server)  
- Portfolio and user management  
- Asset tracking (stocks, ETFs, crypto)  
- Transaction history (buy/sell activity)  
- Dividend tracking and income analysis  
- Market index integration for benchmark comparison  
- Data integrity using primary keys, foreign keys, and constraints  

###  Database Tables

####  Core Entities
- **Users** – Investor personal information  
- **Portfolio** – Investment portfolios per user, including risk level  

####  Asset & Market Data
- **Assets** – Financial instruments (stocks, ETFs, crypto)  
- **Assets_Sector** – Sector classification of assets  
- **Assets_History** – Historical price data for each asset  
- **Asset_Risk_Metrics** – Risk indicators (e.g., volatility, risk level)  

####  Transactions & Cash Flow
- **Transactions** – Buy and sell operations  
- **Dividends** – Dividend payments per asset  
- **Fees** – Transaction or asset-related fees  

####  Portfolio Management
- **Portfolio_Allocation** – Target asset weights per portfolio  

####  Benchmark Data
- **Market_Index** – Market benchmark definitions  
- **Market_Index_Prices** – Historical index values  
---

###  Analysis Capabilities

This database enables:

- Profit and loss calculation per portfolio  
- Portfolio return analysis  
- Dividend income tracking  
- Asset-level performance evaluation  
- Benchmark comparison (market vs portfolio)  
- Allocation vs target weight analysis  

---

###  Technologies Used

- SQL Server  
- Excel (data preparation and import)  


###  Project Purpose

This project demonstrates:

- Strong understanding of relational database design  
- Ability to model real-world financial systems  
- Experience working with financial data structures  
- Preparation for Data / BI / FinTech roles  
