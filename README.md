# Nepal-Election-Analysis_2022
# Data Cleaning Process

The raw election dataset required several transformation steps before analysis.

Key cleaning steps included:

- Standardizing column names
- Removing translated columns
- Converting vote counts to numeric format
- Handling missing values
- Removing duplicate rows
- Creating a unique constituency identifier
- Exporting a cleaned dataset for analysis

The final cleaned dataset is stored as:

---

# Feature Engineering

Several analytical fields were created to support deeper insights.

### Constituency Reconstruction
The dataset originally stored constituency numbers separately.  
A new identifier was created combining district and constituency number.

### Winner Dataset
A winners table was created containing one row per constituency.

### Victory Margin
Victory margin was calculated as:

This metric helps identify competitive vs dominant races.

---

# Exploratory Data Analysis

The analysis explored multiple election insights:

### Electoral Scale
- Total votes cast
- Number of candidates
- Number of constituencies

### Party Performance
- Vote share by political party
- Seat share by political party
- Vote share vs seat share comparison

### Electoral Competitiveness
- Closest races in the country
- Largest victory margins

### Regional Analysis
- Seat distribution by province
- Party dominance by province

### Candidate Demographics
- Gender distribution of candidates
- Female winner statistics

### Candidate Competition
- Average number of candidates per constituency

---

# Visualization

Python visualizations were created using **Matplotlib** to explore:

- Party vote share
- Province seat distribution
- Closest electoral races
- Gender participation

These visualizations help interpret electoral trends and political competition.

---

# SQL Analysis (PostgreSQL)

The cleaned dataset is designed to be loaded into **PostgreSQL** for advanced querying.

Example SQL analyses include:

- Vote share calculations
- Seat share analysis
- Party dominance by province
- Closest constituency races
- Candidate ranking using window functions

These SQL queries simulate typical **data analyst interview scenarios**.

---

# Tools Used

Python  
Pandas  
NumPy  
Matplotlib  
PostgreSQL  
Power BI

---

# Key Skills Demonstrated

Data Cleaning  
Data Transformation  
Exploratory Data Analysis  
Feature Engineering  
SQL Querying  
Data Visualization  
Analytical Thinking  

---

# Project Purpose

This project was created to strengthen practical data analysis skills and build a portfolio demonstrating the ability to:

- work with real-world datasets
- clean and transform raw data
- generate meaningful insights
- prepare data for SQL and BI tools

---

# Next Steps

Future improvements for the project include:

- Power BI interactive dashboard
- Predictive modeling for election outcomes
- Geographic visualization of election results


# Author

This project is part of my **Data Analyst portfolio** as I work toward building professional-level analytics skills.
