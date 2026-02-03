Project: SQL Analytics – Northwind Database
Database: PostgreSQL (pgAdmin)
Repository structure:
SQL-analytics-project-Northwind-db/
│
├─ Sql-queries/
│   ├─ 1_order_revenue_analysis.sql
│   ├─ 2_Employee_Monthly_Revenue_ABC.sql
│   ├─ 3_Product_Monthly_Revenue_ABC_Dynamics.sql
│   └─ 4_category_revenue_analysis.sql
│
├─ Northwind_db_metadata/
│   └─ (Metadata file for Northwind tables)
│
├─ Sql_Query_Screenshots_PowerBI/
│   ├─ 1_order_revenue_analysis_PowerBI.png
│   ├─ 2_Employee_Monthly_Revenue_ABC_PowerBI.png
│   ├─ 3_Product_Monthly_Revenue_ABC_Dynamics_PowerBI.png
│   └─ 4_category_revenue_analysis_PowerBI.png
│
├─ data_exports/
│   ├─ 1_order_revenue_analysis.csv
│   ├─ 2_Employee_Monthly_Revenue_ABC.csv
│   ├─ 3_Product_Monthly_Revenue_ABC_Dynamics.csv
│   └─ 4_category_revenue_analysis.csv
│
├─ csv_data_exports/
│   └─ (Other CSV files if needed)
│
└─ README.md

 SQL Queries Description

1.1_order_revenue_analysis.sql
  This query calculates the revenue for each order (order_revenue), cumulative revenue (cumulative_revenue)
   and the percentage of total revenue (cumulative_percent) for each order.
   Based on cumulative revenue, it performs ABC analysis (abc_class) to divide orders into classes A, B, and C by their contribution to total revenue.
   It uses window functions SUM() OVER() to calculate cumulative and total revenue.
   This query is useful to see which orders bring the most profit and how revenue is distributed among customers.

 2. 2_Employee_Monthly_Revenue_ABC.sql
   This query calculates the revenue for each employee per month (revenue), average revenue per order (avg_revenue), 
   cumulative revenue (rev) and ABC classification of employees (employees_abc_class) based on their contribution to total monthly revenue.
   It uses window functions SUM() OVER() and DENSE_RANK() to calculate cumulative revenue and top employees per month.
   This query is useful to identify top-performing employees and see the distribution of revenue across employees.

  3. 3_Product_Monthly_Revenue_ABC_Dynamics.sql
   This query calculates monthly revenue per product (revenue), cumulative revenue (cumulative_revenue),
   and the percentage of total revenue (stab_percent) for each product.
   Based on cumulative revenue, it performs ABC analysis (abc_class) to classify products into A, B, and C classes by contribution.
   It also calculates growth compared to the previous month (p) and defines product dynamics (product_dinamic) as Anchor, Volatile, One-time 
   hit, or No demand.
   Window functions SUM() OVER(), LAG(), and LEAD() are used for calculations.
   Useful for analyzing which products sell the most and how their sales change over months.

 4. 4_category_revenue_analysis.sql
   This query calculates the revenue for each product category per quarter (category_revenue), 
   the share of each category in total quarterly revenue (revenue_share_percent), 
   and the growth rate compared to the previous quarter (revenue_growth_percent).
   Based on growth rates, it identifies the trend of each category (category_trend) as Stable Growth, 
   Unstable Growth, Decline, or No Clear Trend.
   It uses window functions SUM() OVER() for total and cumulative revenue, 
   and LAG() / LEAD() to compare growth rates between quarters.
   This query is useful for analyzing which product categories are driving revenue growth and detecting trends over time.

Проект: SQL Аналитика – база данных Northwind
Database: PostgreSQL (pgAdmin)
Структура репозитория:
SQL-analytics-project-Northwind-db/
│
├─ Sql-queries/
│   ├─ 1_order_revenue_analysis.sql
│   ├─ 2_Employee_Monthly_Revenue_ABC.sql
│   ├─ 3_Product_Monthly_Revenue_ABC_Dynamics.sql
│   └─ 4_category_revenue_analysis.sql
│
├─ Northwind_db_metadata/
│   └─ (Файл с метаданными таблиц Northwind)
│
├─ Sql_Query_Screenshots_PowerBI/
│   ├─ 1_order_revenue_analysis_PowerBI.png
│   ├─ 2_Employee_Monthly_Revenue_ABC_PowerBI.png
│   ├─ 3_Product_Monthly_Revenue_ABC_Dynamics_PowerBI.png
│   └─ 4_category_revenue_analysis_PowerBI.png
│
├─ data_exports/
│   ├─ 1_order_revenue_analysis.csv
│   ├─ 2_Employee_Monthly_Revenue_ABC.csv
│   ├─ 3_Product_Monthly_Revenue_ABC_Dynamics.csv
│   └─ 4_category_revenue_analysis.csv
│
├─ csv_data_exports/
│   └─ (Другие CSV файлы, если нужны)
│
└─ README.md

Описание SQL запросов

1. 1_order_revenue_analysis.sql
Данный запрос рассчитывает выручку по заказам (order_revenue), накопительную выручку (cumulative_revenue) и процент от общей выручки (cumulative_percent) для каждого заказа.
 На основе накопительной выручки выполняется ABC-анализ (abc_class), который делит заказы на классы A, B и C по вкладу в общую выручку.
Используются оконные функции SUM() OVER() для расчета нарастающего итога и общей суммы.
Запрос полезен для анализа, какие заказы приносят наибольшую прибыль и как распределяется доход по клиентам.

2. 2_Employee_Monthly_Revenue_ABC.sql
Данный запрос рассчитывает выручку по сотрудникам за месяц (revenue), среднюю выручку на заказ (avg_revenue), 
   накопительную выручку (rev) и ABC-классификацию сотрудников (employees_abc_class) на основе их вклада в общую месячную выручку.
   Используются оконные функции SUM() OVER() и DENSE_RANK() для расчета накопительной выручки и определения топ-сотрудников месяца.
   Запрос полезен для выявления лучших сотрудников и анализа распределения выручки между ними.
   
3. 3_Product_Monthly_Revenue_ABC_Dynamics.sql
  Данный запрос рассчитывает ежемесячную выручку по продуктам (revenue), накопительную выручку (cumulative_revenue)
   и процент от общей выручки (stab_percent) для каждого продукта.
   На основе накопительной выручки выполняется ABC-анализ (abc_class), который делит продукты на классы A, B и C по вкладу в общую выручку.
   Также вычисляется рост относительно предыдущего месяца (p) и определяется динамика продукта (product_dinamic) как Якорный, Волатильный, 
   Одноразовый хит или Без спроса.
   Используются оконные функции SUM() OVER(), LAG() и LEAD() для вычислений.
   Полезно для анализа, какие продукты продаются лучше всего и как меняются их продажи по месяцам.

4. 4_category_revenue_analysis.sql
  Данный запрос рассчитывает выручку по каждой категории продуктов за квартал (category_revenue),
   долю каждой категории в общей квартальной выручке (revenue_share_percent) 
   и рост выручки по сравнению с предыдущим кварталом (revenue_growth_percent).
   На основе показателей роста определяется тренд каждой категории (category_trend) 
   как Стабильный рост, Нестабильный рост, Падение или Без выраженного тренда.
   Используются оконные функции SUM() OVER() для расчета общей и накопительной выручки, 
   а LAG() / LEAD() для сравнения роста между кварталами.
   Запрос полезен для анализа, какие категории продуктов приносят рост дохода и выявления трендов со временем.
