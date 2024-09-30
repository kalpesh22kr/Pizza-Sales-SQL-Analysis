-- Basic
-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id)
FROM
    orders;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    SUM(price * quantity) AS totalRevenue
FROM
    pizzas,
    orders_details
WHERE
    pizzas.pizza_id = orders_details.pizza_id;


-- Identify the highest-priced pizza.
SELECT 
    name, price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
WHERE
    pizzas.price = (SELECT 
            MAX(price)
        FROM
            pizzas);

-- Identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(orders_details.order_det_id) AS order_count
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name, SUM(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category ,
    SUM(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;


-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time), COUNT(order_id)
FROM
    orders
GROUP BY HOUR(order_time)
ORDER BY COUNT(order_id) DESC;


-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;


-- Group the orders by date number of pizzas ordered per day
SELECT 
    orders.order_date, SUM(orders_details.quantity)
FROM
    orders
        JOIN
    orders_details ON orders.order_id = orders_details.order_id
GROUP BY orders.order_date;


-- Calculate the average number of pizzas ordered per day.
SELECT 
    AVG(quantity)
FROM
    (SELECT 
        orders.order_date, SUM(orders_details.quantity) AS quantity
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS order_quantity;
    
    
-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    SUM(orders_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;


-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    ROUND(SUM(orders_details.quantity * pizzas.price) / (SELECT 
                    SUM(price * quantity)
                FROM
                    orders_details,
                    pizzas
                WHERE
                    orders_details.pizza_id = pizzas.pizza_id) * 100) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;


-- Analyze the cumulative revenue generated over time.
SELECT 
order_date, sum(revenue) OVER(ORDER BY order_date) 
FROM 
	(SELECT 
		orders.order_date, sum(orders_details.quantity * pizzas.price) as revenue 
    FROM orders 
    JOIN orders_details 
    ON orders.order_id = orders_details.order_id 
    JOIN pizzas 
    ON orders_details.pizza_id = pizzas.pizza_id 
    GROUP BY orders.order_date) 
AS dailyRevenue;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT 
category, NAME, revenue from 
	(SELECT 
		category, NAME, revenue, RANK() OVER(PARTITION BY category ORDER BY revenue DESC ) AS rn 
	FROM 
		(SELECT pizza_types.category, pizza_types.NAME, sum(orders_details.quantity * pizzas.price) AS revenue 
		FROM orders_details 
        JOIN pizzas 
        ON pizzas.pizza_id = orders_details.pizza_id 
        JOIN pizza_types 
        ON pizza_types.pizza_type_id = pizzas.pizza_type_id 
        GROUP BY pizza_types.category, pizza_types.NAME) 
	AS cat)
AS dog WHERE rn<=3;
