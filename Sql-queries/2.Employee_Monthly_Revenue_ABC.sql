/*This query calculates the revenue for each employee per month (revenue), average revenue per order (avg_revenue), 
   cumulative revenue (rev) and ABC classification of employees (employees_abc_class) based on their contribution to total monthly revenue.
   It uses window functions SUM() OVER() and DENSE_RANK() to calculate cumulative revenue and top employees per month.
   This query is useful to identify top-performing employees and see the distribution of revenue across employees.*/

/*Данный запрос рассчитывает выручку по сотрудникам за месяц (revenue), среднюю выручку на заказ (avg_revenue), 
   накопительную выручку (rev) и ABC-классификацию сотрудников (employees_abc_class) на основе их вклада в общую месячную выручку.
   Используются оконные функции SUM() OVER() и DENSE_RANK() для расчета накопительной выручки и определения топ-сотрудников месяца.
   Запрос полезен для выявления лучших сотрудников и анализа распределения выручки между ними.*/

/*TABLE Employees:
  SELECT employee_id, last_name, first_name, title, birth_date, hire_date, address, city, region, postal_code, country, home_phone, extension, photo, notes, reports_to, photo_path
	FROM public.employees;

  TABLE Orders:
  SELECT order_id, customer_id, employee_id, order_date, required_date, shipped_date,
        ship_via, freight, ship_name, ship_address, ship_city, ship_region, ship_postal_code, ship_country
	FROM public.orders;

  TABLE Order_details:
  SELECT order_id, product_id, unit_price, quantity, discount
	FROM public.order_details;*/

SELECT year, month, DENSE_RANK()OVER(PARTITION BY year, month ORDER BY avg_revenue DESC) AS top_of_month,
	   employee_id, employee_name, order_count, revenue::int, avg_revenue::int,
	   CASE WHEN rev::numeric/total_month_revenue::numeric<=0.8 THEN 'A'
	   		WHEN rev::numeric/total_month_revenue::numeric<=0.95 THEN 'B'
	   		ELSE 'C' END AS employees_abc_class
FROM
	(
	 SELECT *, SUM(revenue)OVER(PARTITION BY year, month ORDER BY revenue DESC, employee_id) AS rev,
			  SUM(revenue)OVER(PARTITION BY year, month) AS total_month_revenue,
			  revenue/ order_count AS avg_revenue
			  FROM
			  (
		SELECT EXTRACT(year FROM order_date) AS year, 
			   EXTRACT(month FROM order_date) AS month, 
			   e.employee_id, CONCAT(last_name,' ', first_name) AS employee_name, 
			   SUM(unit_price*quantity) AS revenue, 
			   COUNT(DISTINCT od.order_id) AS order_count
		FROM employees e, orders o, order_details od
		WHERE e.employee_id=o.employee_id AND o.order_id=od.order_id
		GROUP BY year, month, e.employee_id) AS a) AS b

--screenshoots on file /Sql-screnshoots
