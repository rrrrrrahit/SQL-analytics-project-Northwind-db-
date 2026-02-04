/*This function calculates customer revenue analysis by category for a given year.
It computes:
- total revenue and average revenue per order for each customer,
- cumulative revenue and ABC classification (A, B, C) based on contribution to total revenue,
- top employee for each customer,
- monthly revenue growth percentage.
It uses multiple tables: Customers, Orders, Order_details, Products, Categories, Employees.
Window functions (SUM(), LAG(), DENSE_RANK()) are used for cumulative calculations and ranking.

Данная функция рассчитывает выручку по клиентам по категориям за указанный год.
Включает:
- общую выручку и среднюю выручку на заказ для каждого клиента,
- накопительную выручку и ABC-анализ (классы A, B, C) по вкладу в общую выручку,
- определение топ-сотрудника для каждого клиента,
- процентный рост выручки по месяцам.
Используются таблицы: Customers, Orders, Order_details, Products, Categories, Employees.
Для вычислений используются оконные функции SUM(), LAG(), DENSE_RANK().
*/

CREATE OR REPLACE FUNCTION customer_category_analysis(year_input int)
RETURNS table(cus_id varchar, 
               cat_name varchar, total_rev int, avg_order_rev int, 
               abc_cl TEXT, top_empl_id smallint,
               rev_growth text) AS $$
BEGIN
    RETURN query
    SELECT c_id, cat_name, total_revenue::int,
           avg_order_revenue::int, 
           CASE WHEN cumulative_revenue/total_revenue<0.8
                THEN 'A'
                WHEN cumulative_revenue/total_revenue<0.95
                THEN 'B'
                ELSE 'C' END AS abc_cl, top_emp_id AS top_empl_id,
           CONCAT(ROUND((revenue - lag_revenue)/NULLIF(lag_revenue,0)*100,2), '%') AS rev_growth
    FROM(
        SELECT yr::INT, c_id, cat_name, top_emp_id, revenue, revenue/order_cnt AS avg_order_revenue,
               SUM(revenue)OVER(PARTITION BY yr) AS total_revenue,
               SUM(revenue)OVER(PARTITION BY yr ORDER BY revenue ROWS UNBOUNDED PRECEDING) AS cumulative_revenue,
               LAG(revenue)OVER(PARTITION BY c_id ORDER BY revenue) AS lag_revenue,
               DENSE_RANK()OVER(PARTITION BY c_id ORDER BY categ_count DESC) AS top_categ,
               DENSE_RANK()OVER(PARTITION BY c_id ORDER BY emp_count DESC) AS top_employee
        FROM(
            SELECT 
                   EXTRACT(year FROM o.order_date) AS yr, 
                   c.customer_id AS c_id, 
                   cg.category_name, 
                   e.employee_id AS top_emp_id, 
                   SUM(od.quantity*od.unit_price) AS revenue, 
                   COUNT(o.order_id) AS order_cnt,
                   COUNT(DISTINCT cg.category_name) AS categ_count,
                   COUNT(DISTINCT e.employee_id) AS emp_count
            FROM Customers c
            JOIN Orders o ON c.customer_id=o.customer_id
            JOIN Order_details od ON o.order_id=od.order_id
            JOIN Products p ON od.product_id=p.product_id
            JOIN Categories cg ON p.category_id=cg.category_id
            JOIN Employees e ON o.employee_id=e.employee_id
            GROUP BY yr, cg.category_name, c.customer_id, e.employee_id
        ) AS A
    ) AS B
    WHERE yr=year_input
    AND top_categ=1
    AND top_employee=1;
END;
$$ LANGUAGE plpgsql;

--SELECT customer_category_analysis(1998) Вызов функции

