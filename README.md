# Global Layoffs Data Analysis (SQL Project)
Data cleaning and exploratory data analysis of global layoffs dataset using MySQL


## About this project

I worked on this project to practice real-world SQL skills by cleaning and analyzing a global layoffs dataset. The data had inconsistencies and missing values, so I first focused on cleaning it properly and then performed exploratory analysis to understand trends.

---

## What I did

### Data Cleaning

* Removed duplicate records using ROW_NUMBER()
* Cleaned text fields like company names and countries
* Fixed inconsistent values in the industry column
* Converted the date column into proper DATE format
* Handled missing values and filled them using self-joins

### Exploratory Data Analysis

* Analyzed total layoffs by country and year
* Identified companies with highest layoffs
* Studied layoffs across different funding stages
* Calculated rolling totals to observe trends over time
* Ranked top 5 companies by layoffs for each year using window functions

---

## Key observations

* Layoffs were highest among Post-IPO companies
* There was a noticeable spike in layoffs during certain years
* Some countries were significantly more affected than others
* Late-stage companies experienced higher layoffs compared to early-stage startups

---

## What I learned

This project helped me get comfortable with:

* Writing complex SQL queries
* Using window functions and CTEs
* Cleaning messy real-world data
* Thinking about data from a business perspective instead of just writing queries

---

## Tools used

* MySQL
* MySQL Workbench
