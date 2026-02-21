CREATE OR REPLACE PROCEDURE abc_analisys(p_year int)
LANGUAGE plpgsql
AS $$
BEGIN
  CREATE TEMP TABLE t1 ON COMMIT DROP AS
  WITH
  rev AS (
    SELECT
      EXTRACT(YEAR FROM o.order_date)::int AS year,
      o.customer_id,
      SUM(od.quantity * od.unit_price * (1 - od.discount))::numeric AS revenue,
      COUNT(DISTINCT o.order_id) AS orders_cnt,
      SUM(od.quantity * od.unit_price * (1 - od.discount))::numeric
        / NULLIF(COUNT(DISTINCT o.order_id), 0) AS avg_revenue
    FROM orders o
    JOIN order_details od ON od.order_id = o.order_id
    WHERE EXTRACT(YEAR FROM o.order_date)::int = p_year
    GROUP BY 1, 2
  ),
  totals AS (
    SELECT
      year,
      SUM(revenue) OVER (PARTITION BY year) AS total,
      SUM(revenue) OVER (
        PARTITION BY year
        ORDER BY revenue DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
      ) AS cum
    FROM rev
  ),
  top_emp AS (
    SELECT year, customer_id, employee_id
    FROM (
      SELECT
        EXTRACT(YEAR FROM o.order_date)::int AS year,
        o.customer_id,
        o.employee_id,
        SUM(od.quantity * od.unit_price * (1 - od.discount)) AS emp_rev,
        ROW_NUMBER() OVER (
          PARTITION BY EXTRACT(YEAR FROM o.order_date)::int, o.customer_id
          ORDER BY SUM(od.quantity * od.unit_price * (1 - od.discount)) DESC,
                   COUNT(DISTINCT o.order_id) DESC,
                   o.employee_id ASC
        ) AS rn
      FROM orders o
      JOIN order_details od ON od.order_id = o.order_id
      WHERE EXTRACT(YEAR FROM o.order_date)::int = p_year
      GROUP BY 1, 2, 3
    ) s
    WHERE rn = 1
  )
  SELECT
    r.year,
    r.customer_id,
    r.revenue,
    r.orders_cnt,
    r.avg_revenue,
    te.employee_id AS top_employee_id,
    CASE
      WHEN t.cum / NULLIF(t.total, 0) <= 0.80 THEN 'A'
      WHEN t.cum / NULLIF(t.total, 0) <= 0.95 THEN 'B'
      ELSE 'C'
    END AS abc_analysis
  FROM rev r
  JOIN totals t
    ON t.year = r.year AND t.customer_id = r.customer_id
  LEFT JOIN top_emp te
    ON te.year = r.year AND te.customer_id = r.customer_id;

  INSERT INTO total_table
    (year, customer_id, revenue, count, avg_revenue, top_employee_id, abc_analysis)
  SELECT
    year,
    customer_id,
    revenue::int,
    orders_cnt,
    avg_revenue::int,
    top_employee_id,
    abc_analysis
  FROM t1
  ON CONFLICT (year, customer_id)
  DO UPDATE SET
    revenue = EXCLUDED.revenue,
    count = EXCLUDED.count,
    avg_revenue = EXCLUDED.avg_revenue,
    top_employee_id = EXCLUDED.top_employee_id,
    abc_analysis = EXCLUDED.abc_analysis;

END;
$$;