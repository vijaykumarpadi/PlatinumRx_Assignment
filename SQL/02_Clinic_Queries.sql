-- 1. Revenue per sales channel (2021)
SELECT sales_channel,
       SUM(amount) AS revenue
FROM clinic_sales
WHERE EXTRACT(YEAR FROM datetime) = 2021
GROUP BY sales_channel;


-- 2. Top 10 most valuable customers (2021)
SELECT uid,
       SUM(amount) AS total_spent
FROM clinic_sales
WHERE EXTRACT(YEAR FROM datetime) = 2021
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;


-- 3. Month-wise revenue, expense, profit, status
WITH revenue AS (
    SELECT DATE_TRUNC('month', datetime) AS month,
           SUM(amount) AS revenue
    FROM clinic_sales
    WHERE EXTRACT(YEAR FROM datetime) = 2021
    GROUP BY month
),
expense AS (
    SELECT DATE_TRUNC('month', datetime) AS month,
           SUM(amount) AS expense
    FROM expenses
    WHERE EXTRACT(YEAR FROM datetime) = 2021
    GROUP BY month
)
SELECT r.month,
       r.revenue,
       e.expense,
       (r.revenue - e.expense) AS profit,
       CASE 
           WHEN (r.revenue - e.expense) > 0 THEN 'profitable'
           ELSE 'not-profitable'
       END AS status
FROM revenue r
JOIN expense e ON r.month = e.month;


-- 4. Most profitable clinic per city (example: Sept 2021)
WITH profit_calc AS (
    SELECT c.city, cs.cid,
           SUM(cs.amount) - COALESCE(SUM(e.amount), 0) AS profit
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
    LEFT JOIN expenses e ON cs.cid = e.cid
    WHERE DATE_TRUNC('month', cs.datetime) = '2021-09-01'
    GROUP BY c.city, cs.cid
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY city ORDER BY profit DESC) AS rnk
    FROM profit_calc
)
SELECT *
FROM ranked
WHERE rnk = 1;


-- 5. Second least profitable clinic per state (example: Sept 2021)
WITH profit_calc AS (
    SELECT c.state, cs.cid,
           SUM(cs.amount) - COALESCE(SUM(e.amount), 0) AS profit
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
    LEFT JOIN expenses e ON cs.cid = e.cid
    WHERE DATE_TRUNC('month', cs.datetime) = '2021-09-01'
    GROUP BY c.state, cs.cid
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY state ORDER BY profit ASC) AS rnk
    FROM profit_calc
)
SELECT *
FROM ranked
WHERE rnk = 2;
