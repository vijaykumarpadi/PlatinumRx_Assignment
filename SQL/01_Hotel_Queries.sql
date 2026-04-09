-- 1. Last booked room per user
SELECT user_id, room_no
FROM (
    SELECT user_id, room_no,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY booking_date DESC) AS rn
    FROM bookings
) t
WHERE rn = 1;


-- 2. Total billing amount for bookings in November 2021
SELECT bc.booking_id,
       SUM(i.item_rate * bc.item_quantity) AS total_bill
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE bc.bill_date >= '2021-11-01'
  AND bc.bill_date < '2021-12-01'
GROUP BY bc.booking_id;


-- 3. Bills > 1000 in October 2021
SELECT bc.bill_id,
       SUM(i.item_rate * bc.item_quantity) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE bc.bill_date >= '2021-10-01'
  AND bc.bill_date < '2021-11-01'
GROUP BY bc.bill_id
HAVING SUM(i.item_rate * bc.item_quantity) > 1000;


-- 4. Most and least ordered item per month (2021)
WITH item_orders AS (
    SELECT 
        DATE_TRUNC('month', bill_date) AS month,
        item_id,
        SUM(item_quantity) AS total_qty
    FROM booking_commercials
    WHERE EXTRACT(YEAR FROM bill_date) = 2021
    GROUP BY month, item_id
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY month ORDER BY total_qty DESC) AS max_rank,
           RANK() OVER (PARTITION BY month ORDER BY total_qty ASC) AS min_rank
    FROM item_orders
)
SELECT *
FROM ranked
WHERE max_rank = 1 OR min_rank = 1;


-- 5. Second highest bill per month (2021)
WITH monthly_bills AS (
    SELECT 
        DATE_TRUNC('month', bc.bill_date) AS month,
        bc.bill_id,
        SUM(i.item_rate * bc.item_quantity) AS total_amount
    FROM booking_commercials bc
    JOIN items i ON bc.item_id = i.item_id
    WHERE EXTRACT(YEAR FROM bc.bill_date) = 2021
    GROUP BY month, bc.bill_id
),
ranked AS (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY month ORDER BY total_amount DESC) AS rnk
    FROM monthly_bills
)
SELECT *
FROM ranked
WHERE rnk = 2;
