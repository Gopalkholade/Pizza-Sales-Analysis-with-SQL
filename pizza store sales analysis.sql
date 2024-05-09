create database Pizza_store;

use pizza_store;
create table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id));

-- Analysis

-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS sum_of_sales
FROM
    order_details
        LEFT JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;

-- Identify the highest-priced pizza.
SELECT 
    name, price
FROM
    pizza_types
        LEFT JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    size, COUNT(order_id) AS cnt
FROM
    pizza_types
        LEFT JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        RIGHT JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY size
ORDER BY cnt DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name,
    SUM(quantity),
    COUNT(order_id) AS cnt
FROM
    order_details
        LEFT JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        LEFT JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY cnt DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    category, SUM(quantity) AS total_quantity
FROM
    order_details
        LEFT JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        LEFT JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category;

-- Determine the distribution of orders by hour of the day
SELECT 
    HOUR(orders.order_time) AS hour,
    COUNT(order_id) AS No_of_orders
FROM
    orders
GROUP BY hour;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(order_id)
FROM
    order_details
        LEFT JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        LEFT JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    order_date, ROUND(AVG(order_id)) AS Average_orders
FROM
    orders
GROUP BY order_date;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    name, SUM(quantity * price) AS rev
FROM
    order_details
        LEFT JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        LEFT JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY rev DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    name,
    (SUM(quantity * price) / (SELECT 
            ROUND(SUM(order_details.quantity * pizzas.price),
                        2)
        FROM
            order_details
                LEFT JOIN
            pizzas ON order_details.pizza_id = pizzas.pizza_id)) * 100 AS perc_rev
FROM
    order_details
        LEFT JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        LEFT JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY perc_rev DESC;

-- Analyze the cumulative revenue generated over time.
select order_time, sum(quantity*price) over(order by order_time) as cum_sum
from order_details left join orders on order_details.order_id=orders.order_id left join pizzas on order_details.pizza_id=pizzas.pizza_id;

-- Analyze the cumulative revenue generated over date.
select order_date, sum(sum_r) over (order by order_date) as cum_rev
from 
(select order_date, sum(quantity*price) as sum_r
from order_details left join orders on order_details.order_id=orders.order_id 
left join pizzas on order_details.pizza_id=pizzas.pizza_id
group by order_date) as sum_rev;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name, rev, ranks
from
(select category, name, rev, rank() over(partition by category order by rev desc) as ranks
from
(select category, name,  sum(quantity*price) as rev
from order_details left join pizzas on order_details.pizza_id=pizzas.pizza_id 
left join pizza_types on pizzas.pizza_type_id=pizza_types.pizza_type_id
group by pizza_types.category, pizza_types.name) as tb) as tr
where ranks <= 3;