/*Q8. Products with sales above their category average
Using a CTE, calculate total sales per product and then show products whose
sales are above the average product sales within their category.
Output:
•	category 
•	product_name 
•	total_sales */ 

 with product_sales as(
 select p.category, p.product_id, p.product_name, sum(o.amount)as total_sales
 from products p inner join orders o 
 on p.product_id=o.product_id
 group by p.category, p.product_id, p.product_name
 ),
category_avg as(
 select category, avg(total_sales) as avg_sales
 from product_sales
 group by category)
 
 select 
    ps.category,
    ps.product_name,
    ps.total_sales
from product_sales ps
inner join category_avg ca
    on ps.category = ca.category
where ps.total_sales > ca.avg_sales;

/* Q9 — Customer risk classification using a CTE
Using a CTE, calculate for each customer:
total_orders
cancelled_orders
cancellation_rate
total_spending
Then return only customers satisfying both:
cancellation_rate >= 30%
total_spending > average customer spending
Output all four metrics plus customer_name.*/

with customer_metrics as(
	select c.customer_id, c.customer_name, count(o.customer_id) as total_orders,
		sum(case when o.status='Cancelled' then 1 else 0 end) as cancelled_orders,
		sum(case when o.status='Cancelled' then 1 else 0 end)/ count(o.order_id)*100 as cancellation_rate,
		sum(o.amount) as total_spending
    from customers c inner join orders o 
    on c.customer_id=o.customer_id
    group by c.customer_id, c.customer_name
),
	avg_spending as(
    select avg(total_spending)as avg_spend
    from customer_metrics
)
select cm.customer_id, cm.customer_name, cm.cancelled_orders, cm.cancellation_rate,
cm.total_spending,cm.total_orders
from customer_metrics cm
cross join avg_spending a
where cm.cancellation_rate >= 30
and 
cm.total_spending> a.avg_spend;

/*Q10. ⭐ Integrated Subquery + CTE Checkpoint
Using a CTE, calculate each customer's:
•	total orders 
•	completed orders 
•	cancelled orders 
•	cancellation rate 
•	total spending 
Then identify customers who satisfy both:
completed_orders > average completed orders
AND
cancellation_rate > average customer cancellation rate
Output:
•	customer_name 
•	total_orders 
•	completed_orders 
•	cancelled_orders 
•	cancellation_rate 
•	total_spending */

with customer_metrics as(
	select 
    c.customer_id, c.customer_name,
    count(o.customer_id) as total_orders,
    sum(case when o.status='Completed' then 1 else 0 end) as completed_orders,
    sum(case when o.status='Cancelled' then 1 else 0 end) as cancelled_orders,
    sum(case when o.status='Cancelled' then 1 else 0 end)/count(o.customer_id)*100 as cancel_rate,
    sum(o.amount) as total_spend
    from customers c inner join orders o 
    on c.customer_id=o.customer_id
    group by c.customer_id, c.customer_name
),
avg_cancellation_rate as(
	select avg(cancel_rate) as avg_cancel_rate
    from customer_metrics
),
average_completed_orders as(
	 select avg(completed_orders) as avg_complete
     from customer_metrics    
)     
     
select * 
FROM customer_metrics cm
CROSS JOIN average_completed_orders co
CROSS JOIN avg_cancellation_rate cr

WHERE cm.cancel_rate > cr.avg_cancel_rate
  AND cm.completed_orders > co.avg_complete;