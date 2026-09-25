/*Q1. Customers with above-average order value
Find customers whose average order amount is greater than the overall average order amount.
Output:
customer_name
avg_order_value*/

select c.customer_name, avg(o.amount) as AOV
from customers c inner join orders o 
on c.customer_id=o.customer_id
group by c.customer_name
having AOV > (
    select avg(o2.amount)
    from customers c2
    inner join orders o2
        on c2.customer_id = o2.customer_id
);

/* Q2. Customers with no completed orders
Find customers who have never placed a Completed order.
Output:
•	customer_id 
•	customer_name 
*/
select c.customer_id, c.customer_name, count(o.customer_id) as orders_placed from 
customers c left join orders o 
on c.customer_id=o.customer_id
group by c.customer_id, c.customer_name
having 
COUNT(
    CASE
        WHEN o.status = 'Completed' THEN 1
    END
) = 0;

/* Q3. Products never ordered
Find products that have never appeared in the orders table.
Output:
•	product_id 
•	product_name 
•	category */ 

select p.product_name, p.product_id, count(o.product_id) as times_ordered
from products p left join orders o 
on p.product_id=o.product_id
group by p.product_name, p.product_id
having 
count(o.product_id)=0;


/* Q4. Customers spending more than customer 1
Find customers whose total spending is greater than the total spending of the customer 
whose customer_id = 1.
Output:
•	customer_name 
•	total_spending */
select c.customer_name, sum(o.amount) as total_spend
from customers c inner join orders o 
on c.customer_id=o.customer_id
group by c.customer_name
having sum(o.amount)> 
(select sum(o.amount) from orders 
where customer_id=1); 

/* Q5. Orders above the average order amount
Find all orders whose amount is greater than the overall average order amount.
Output:
•	order_id 
•	customer_id 
•	amount */ 

select order_id, customer_id, amount
from orders
where amount > (
    select avg(amount)
    from orders
);

/* Q6. Customers who purchased the most expensive product
Find customers who purchased the product with the highest price.
Output:
•	customer_name 
•	product_name 
•	price */

select o.customer_id,p.product_name, p.price from orders o 
left join products p on
p.product_id=o.product_id
group by o.customer_id,p.product_name, p.price
having p.price=(select max(price)from products);

/*Q7. Customers with more orders than average
Calculate the number of orders per customer and show customers whose order count is
greater than the average number of orders per customer.
Output:
•	customer_name 
•	total_orders */ 
 select customer_id, count(customer_id) as total_orders
 from orders
 group by customer_id
 having count(order_id)>(
 select avg(total_orders) from(

SELECT
            customer_id,
            COUNT(*) AS total_orders
        FROM orders
        GROUP BY customer_id
    ) AS customer_orders
);

