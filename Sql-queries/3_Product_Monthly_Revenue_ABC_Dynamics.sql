/*This query calculates monthly revenue per product (revenue), cumulative revenue (cumulative_revenue),
   and the percentage of total revenue (stab_percent) for each product.
   Based on cumulative revenue, it performs ABC analysis (abc_class) to classify products into A, B, and C classes by contribution.
   It also calculates growth compared to the previous month (p) and defines product dynamics (product_dinamic) as Anchor, Volatile, One-time hit, or No demand.
   Window functions SUM() OVER(), LAG(), and LEAD() are used for calculations.
   Useful for analyzing which products sell the most and how their sales change over months.*/

/*Данный запрос рассчитывает ежемесячную выручку по продуктам (revenue), накопительную выручку (cumulative_revenue)
   и процент от общей выручки (stab_percent) для каждого продукта.
   На основе накопительной выручки выполняется ABC-анализ (abc_class), который делит продукты на классы A, B и C по вкладу в общую выручку.
   Также вычисляется рост относительно предыдущего месяца (p) и определяется динамика продукта (product_dinamic) как Якорный, Волатильный, Одноразовый хит или Без спроса.
   Используются оконные функции SUM() OVER(), LAG() и LEAD() для вычислений.
   Полезно для анализа, какие продукты продаются лучше всего и как меняются их продажи по месяцам.*/

/*TABLE Products:
  SELECT product_id, product_name, supplier_id, category_id, quantity_per_unit, unit_price, units_in_stock, units_on_order, reorder_level, discontinued
  FROM public.products;

  TABLE Order_details:
  SELECT order_id, product_id, unit_price, quantity, discount
  FROM public.order_details;

  TABLE Orders:
  SELECT order_id, customer_id, employee_id, order_date, required_date, shipped_date,
         ship_via, freight, ship_name, ship_address, ship_city, ship_region, ship_postal_code, ship_country
  FROM public.orders;
*/

WITH cte1 AS (
    SELECT *,
           SUM(revenue) OVER(PARTITION BY year, month) AS total_revenue,
		   SUM(revenue) OVER(PARTITION BY year, month ORDER BY revenue DESC, product_id) AS cumulative_revenue,
		   LAG(revenue) OVER(PARTITION BY product_id ORDER BY year, month) AS lag_revenue
    FROM (
        SELECT p.product_id,
               product_name,
			   EXTRACT(YEAR FROM order_date) AS year,
               EXTRACT(MONTH FROM order_date) AS month,
               SUM(od.unit_price * quantity) AS revenue
        FROM products p
        JOIN order_details od ON p.product_id = od.product_id
        JOIN orders o ON od.order_id = o.order_id
        GROUP BY year, month, p.product_id
        ORDER BY year, month, p.product_id
    ) AS a
)


SELECT year,
	   month,
	   product_id,
       product_name,
       revenue::INT,
       CASE 
           WHEN cumulative_revenue::numeric/ total_revenue::numeric<= 0.8 THEN 'A'
           WHEN cumulative_revenue::numeric/ total_revenue::numeric<= 0.95 THEN 'B'
           ELSE 'C'
       END AS abc_class,
       CASE 
           WHEN p IS NULL THEN 'Нет данных'
           ELSE CONCAT(p::INT, '%')
       END AS stab_percent,
       CASE 
           WHEN (lag_p >= 10 OR p >= 10 OR lead_p >= 10) AND (lag_p >= 0 AND p >= 0 AND lead_p >= 0) THEN 'Якорный товар'
           WHEN (lag_p >= 0 AND p >= 0) OR (p >= 0 AND lead_p >= 0) THEN 'Волатильный товар'
           WHEN (lag_p >= 10 OR p >= 10 OR lead_p >= 10) AND (lag_p < 0 OR p < 0 OR lead_p < 0) THEN 'Одноразовый хит'
           ELSE 'Товар без спроса'
       END AS product_dinamic
FROM (
    SELECT *,
           LAG(p) OVER(PARTITION BY product_id ORDER BY year, month) AS lag_p,
           LEAD(p) OVER(PARTITION BY product_id ORDER BY year, month) AS lead_p
		   FROM
   (
   SELECT *, 
   			CASE WHEN lag_revenue IS NULL THEN 0
			ELSE (revenue - lag_revenue) * 100 / lag_revenue END AS p
    FROM cte1) AS a) 
	AS b

--screenshoots on file /Sql-screnshoots
