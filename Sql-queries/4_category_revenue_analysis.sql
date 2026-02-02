/*This query calculates the revenue for each product category per quarter (category_revenue), 
   the share of each category in total quarterly revenue (revenue_share_percent), 
   and the growth rate compared to the previous quarter (revenue_growth_percent).
   Based on growth rates, it identifies the trend of each category (category_trend) as Stable Growth, 
   Unstable Growth, Decline, or No Clear Trend.
   It uses window functions SUM() OVER() for total and cumulative revenue, 
   and LAG() / LEAD() to compare growth rates between quarters.
   This query is useful for analyzing which product categories are driving revenue growth and detecting trends over time.*/

/*Данный запрос рассчитывает выручку по каждой категории продуктов за квартал (category_revenue),
   долю каждой категории в общей квартальной выручке (revenue_share_percent) 
   и рост выручки по сравнению с предыдущим кварталом (revenue_growth_percent).
   На основе показателей роста определяется тренд каждой категории (category_trend) 
   как Стабильный рост, Нестабильный рост, Падение или Без выраженного тренда.
   Используются оконные функции SUM() OVER() для расчета общей и накопительной выручки, 
   а LAG() / LEAD() для сравнения роста между кварталами.
   Запрос полезен для анализа, какие категории продуктов приносят рост дохода и выявления трендов со временем.*/

/*TABLES:
   Categories: category_id, category_name
   Products: product_id, category_id, product_name, unit_price
   Order_details: order_id, product_id, unit_price, quantity, discount
   Orders: order_id, customer_id, employee_id, order_date, required_date, shipped_date, ship_via, freight, ship_name, ship_address, ship_city, ship_region, ship_postal_code, ship_country
*/

WITH cte1 AS(
    SELECT *, category_revenue/total_quarter_revenue*100 AS revenue_share_percent,
           CASE WHEN lag_revenue IS NULL THEN 0
                ELSE (category_revenue-lag_revenue)*100/lag_revenue 
           END AS revenue_growth_percent
     FROM 
    (
        SELECT *, SUM(category_revenue)OVER(PARTITION BY year, quarter) AS total_quarter_revenue,
               LAG(category_revenue)OVER(PARTITION BY category_id ORDER BY year, quarter) AS lag_revenue
        FROM
        (
            SELECT c.category_id, category_name, EXTRACT('year' FROM order_date) AS year, 
                   EXTRACT('quarter' FROM order_date) AS quarter, 
                   SUM(od.unit_price*quantity) AS category_revenue
            FROM categories c, products p, order_details od, orders o
            WHERE c.category_id=p.category_id
              AND p.product_id=od.product_id 
              AND od.order_id=o.order_id
            GROUP BY c.category_id, year, quarter
            ORDER BY year, quarter, c.category_id
        ) AS a
    ) AS b
)

SELECT category_id, category_name, year, quarter, category_revenue::int, 
       CONCAT(revenue_share_percent::int, '%'), 
       CONCAT(revenue_growth_percent::int, '%'),
       CASE WHEN lag_revenue_growth_percent<revenue_growth_percent 
            AND revenue_growth_percent<lead_revenue_growth_percent
            AND revenue_growth_percent-lag_revenue_growth_percent>=10
       THEN 'Стабильный рост'
       WHEN (lag_revenue_growth_percent<revenue_growth_percent 
             AND revenue_growth_percent>lead_revenue_growth_percent)
             OR (lag_revenue_growth_percent>revenue_growth_percent 
             AND revenue_growth_percent<lead_revenue_growth_percent)
       THEN 'Нестабильный рост'
       WHEN (lag_revenue_growth_percent-revenue_growth_percent>=10) 
            AND (lead_revenue_growth_percent-revenue_growth_percent>=10)
       THEN 'Падение'
       ELSE 'Без выраженного тренда' END AS category_trend
FROM (
    SELECT *, LAG(revenue_growth_percent)OVER(PARTITION BY category_id ORDER BY year, quarter) AS lag_revenue_growth_percent,
              LEAD(revenue_growth_percent)OVER(PARTITION BY category_id ORDER BY year, quarter) AS lead_revenue_growth_percent
    FROM cte1
) AS c

--screenshoots on file /Sql-screnshoots
