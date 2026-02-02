/*This query calculates the revenue for each order (order_revenue), cumulative revenue (cumulative_revenue)
   and the percentage of total revenue (cumulative_percent) for each order.
   Based on cumulative revenue, it performs ABC analysis (abc_class) to divide orders into classes A, B, and C by their contribution to total revenue.
   It uses window functions SUM() OVER() to calculate cumulative and total revenue.
   This query is useful to see which orders bring the most profit and how revenue is distributed among customers.*/

/*Данный запрос рассчитывает выручку по заказам (order_revenue), накопительную выручку (cumulative_revenue) и процент от общей выручки (cumulative_percent) для каждого заказа.
   На основе накопительной выручки выполняется ABC-анализ (abc_class), который делит заказы на классы A, B и C по вкладу в общую выручку.
   Используются оконные функции SUM() OVER() для расчета нарастающего итога и общей суммы.
   Запрос полезен для анализа, какие заказы приносят наибольшую прибыль и как распределяется доход по клиентам.*/

/*TABLE Orders:
  SELECT order_id, customer_id, employee_id, order_date, required_date, shipped_date,
        ship_via, freight, ship_name, ship_address, ship_city, ship_region, ship_postal_code, ship_country
	FROM public.orders;

  TABLE Order_details:
  SELECT order_id, product_id, unit_price, quantity, discount
	FROM public.order_details;*/

SELECT order_id, order_year, order_month, order_revenue::int, 
	   cumulative_revenue::int, 
	   CONCAT(((cumulative_revenue::numeric*100/total_revenue::numeric))::int, '%') AS cumulative_percent,
 	   CASE WHEN cumulative_revenue::numeric/total_revenue::numeric<=0.8 THEN 'A'
	   WHEN cumulative_revenue::numeric/total_revenue::numeric<=0.95 THEN 'B'
	   ELSE 'C' END AS abc_class
FROM (	   
	   SELECT *, 
	   SUM(order_revenue)OVER(ORDER BY order_revenue DESC) AS cumulative_revenue,
	   SUM(order_revenue)OVER() AS total_revenue
   
	   FROM(
   			 	SELECT o.order_id, EXTRACT('year' FROM order_date) AS order_year,
	        		       EXTRACT('month' FROM order_date) AS order_month,
				       SUM(unit_price*quantity) AS order_revenue
		   	        FROM orders o JOIN order_details od 
  			        ON o.order_id=od.order_id
   			        GROUP BY o.order_id, order_year, order_month) AS a) AS b
ORDER BY order_revenue DESC

--screenshoots on file /Sql-screnshoots
     		
