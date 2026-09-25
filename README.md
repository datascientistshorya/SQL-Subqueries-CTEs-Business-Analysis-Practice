# SQL Subqueries & CTEs — Business Analysis Practice

## Project Overview

This project is a practical SQL exercise designed to strengthen my ability to solve **multi-step business problems using Subqueries, CTEs, Aggregations, JOINs, CASE statements, and analytical filtering**.

Rather than focusing only on writing syntactically correct SQL queries, the exercises are designed around a common real-world analytical workflow:

> **Start with raw transactional data → build customer/product metrics → calculate benchmarks → compare entities against those benchmarks → identify meaningful business segments.**

The project contains **10 progressively challenging SQL problems (Q1–Q10)** using a simple e-commerce dataset.

The objective is to move from basic query writing toward **analytical SQL thinking**—understanding not only *what query to write*, but also *why the query needs multiple levels of aggregation or filtering*.

---

# Motivation

In real-world analytics, business questions rarely have a direct one-table answer.

For example:

* Which customers have an unusually high average order value?
* Which customers have never completed an order?
* Which products have never been purchased?
* Which customers spend more than a benchmark?
* Which customers place more orders than the average customer?
* Which products outperform the average product within their category?
* Which customers have both high cancellation rates and high spending?
* Which customers perform above average on one metric while also showing risk on another?

These questions require an analyst to **combine multiple levels of analysis**.

This exercise was created to develop that skill.

The main motive is therefore:

> **To learn how to translate business questions into structured SQL logic and connect multiple levels of aggregation into a single analytical answer.**

---

# Database Schema

The exercise uses three relational tables representing a simplified e-commerce business.

## 1. `customers`

Stores customer-level information.

| Column          | Description                         |
| --------------- | ----------------------------------- |
| `customer_id`   | Unique identifier for each customer |
| `customer_name` | Customer name                       |
| `city`          | Customer's city                     |

```text
customers
-----------
customer_id  PK
customer_name
city
```

---

## 2. `orders`

Stores transactional order information.

| Column        | Description                                 |
| ------------- | ------------------------------------------- |
| `order_id`    | Unique identifier for each order            |
| `customer_id` | Customer who placed the order               |
| `product_id`  | Product purchased                           |
| `amount`      | Order value                                 |
| `status`      | Order status such as Completed or Cancelled |
| `order_date`  | Date of the order                           |

```text
orders
-----------
order_id     PK
customer_id  FK
product_id   FK
amount
status
order_date
```

---

## 3. `products`

Stores product information.

| Column         | Description               |
| -------------- | ------------------------- |
| `product_id`   | Unique product identifier |
| `product_name` | Product name              |
| `category`     | Product category          |
| `price`        | Product price             |

```text
products
-----------
product_id    PK
product_name
category
price
```

---

# Table Relationships

The database follows these relationships:

```text
customers
    │
    │ 1
    │
    │
    │ many
    ▼
  orders
    ▲
    │ many
    │
    │ 1
    │
products
```

More specifically:

```text
customers.customer_id
        │
        └────────── orders.customer_id


products.product_id
        │
        └────────── orders.product_id
```

The `orders` table acts as the central transactional table connecting customers and products.

---

# SQL Techniques Used

The 10 exercises focus on the following SQL techniques.

## 1. Aggregate Functions

Used to convert transactional records into business-level metrics.

Examples:

```sql
COUNT()
SUM()
AVG()
MAX()
```

Examples of metrics calculated:

* Total orders
* Completed orders
* Cancelled orders
* Total spending
* Average order value
* Average customer spending
* Average cancellation rate

---

## 2. `GROUP BY`

Used to move from individual transactions to entity-level analysis.

For example:

```sql
GROUP BY customer_id, customer_name
```

allows us to calculate metrics for each customer.

---

## 3. `HAVING`

Used when filtering needs to happen **after aggregation**.

Example:

```sql
HAVING AVG(o.amount) > (...)
```

This is particularly useful when comparing aggregated customer metrics against a benchmark.

---

## 4. Subqueries

Subqueries are one of the major focuses of this exercise.

They allow one query to provide a value or dataset that another query can use.

Example:

```sql
WHERE amount > (
    SELECT AVG(amount)
    FROM orders
)
```

This compares each individual order against the overall average order amount.

---

## 5. Nested Aggregation

Several questions require a more advanced pattern:

```text
Raw transactions
       ↓
Customer-level aggregation
       ↓
Average of customer-level metrics
       ↓
Compare customers against that average
```

For example:

```sql
SELECT AVG(total_orders)
FROM (
    SELECT customer_id,
           COUNT(*) AS total_orders
    FROM orders
    GROUP BY customer_id
) AS customer_orders;
```

This is an important analytical SQL pattern because the required average is not the average of individual orders—it is the **average number of orders per customer**.

---

## 6. Common Table Expressions — CTEs

CTEs are used to break complicated analytical logic into understandable stages.

Example:

```sql
WITH customer_metrics AS (
    ...
)
SELECT ...
FROM customer_metrics;
```

Instead of writing one large nested query, the analysis can be divided into logical steps.

This improves:

* Readability
* Debugging
* Maintainability
* Logical thinking
* Query explanation

---

## 7. Multiple CTEs

The later exercises use multiple CTEs to create different analytical layers.

For example:

```text
customer_metrics
       ↓
average cancellation rate

customer_metrics
       ↓
average completed orders

       ↓
compare each customer
       ↓
final result
```

This demonstrates how multiple analytical benchmarks can be created from the same intermediate dataset.

---

## 8. `CASE WHEN`

Conditional aggregation is used extensively.

Example:

```sql
SUM(
    CASE
        WHEN status = 'Cancelled' THEN 1
        ELSE 0
    END
)
```

This allows transactional data to be converted into business metrics such as:

* Completed orders
* Cancelled orders
* Cancellation rate
* Risk classification

---

## 9. Conditional Business Classification

The exercises also use SQL to translate numerical metrics into business categories.

Example:

```sql
CASE
    WHEN cancel_rate >= 50 THEN 'High'
    WHEN cancel_rate >= 25 THEN 'Medium'
    ELSE 'Low'
END
```

This demonstrates how SQL can move beyond data retrieval into **business interpretation**.

---

## 10. `CROSS JOIN` for Benchmark Comparison

The final exercise uses `CROSS JOIN` to make calculated benchmark values available to every customer row.

For example:

```text
Customer Metrics
       ×
Average Completed Orders
       ×
Average Cancellation Rate
       ↓
Customer-level comparison
```

This allows conditions such as:

```sql
completed_orders > average_completed_orders
```

and

```sql
cancellation_rate > average_cancellation_rate
```

to be evaluated for every customer.

---

# Exercise Breakdown

## Q1 — Customers Above Average Order Value

Identify customers whose average order value is greater than the overall average order value.

### Concepts

* `AVG()`
* `GROUP BY`
* `HAVING`
* Subquery
* Customer-level vs overall-level aggregation

---

## Q2 — Customers With No Completed Orders

Identify customers who have never placed a completed order.

### Concepts

* `LEFT JOIN`
* Conditional aggregation
* `CASE WHEN`
* `COUNT()`
* Identifying missing business activity

---

## Q3 — Products Never Ordered

Identify products that have never appeared in the orders table.

### Concepts

* `LEFT JOIN`
* `COUNT()`
* `HAVING`
* Understanding which table must be preserved in an outer join

---

## Q4 — Customers Spending More Than Customer 1

Calculate total spending for each customer and compare it against the total spending of a specific customer.

### Concepts

* `SUM()`
* `GROUP BY`
* `HAVING`
* Scalar subquery
* Benchmark comparison

---

## Q5 — Orders Above Average Order Amount

Identify individual orders whose amount is greater than the overall average order amount.

### Concepts

* `AVG()`
* Scalar subquery
* Row-level vs aggregate-level comparison

---

## Q6 — Customers Who Purchased the Most Expensive Product

Identify customers who purchased the product with the highest price.

### Concepts

* `MAX()`
* Subquery
* `JOIN`
* Product-level analysis
* Transaction-to-dimension relationship

---

## Q7 — Customers With More Orders Than Average

Identify customers whose total number of orders is greater than the average number of orders per customer.

### Concepts

* `COUNT()`
* `GROUP BY`
* Derived table
* Nested aggregation
* Comparing entity-level metrics against entity-level averages

This exercise is particularly important because it requires understanding **two levels of aggregation**.

---

## Q8 — Products Above Category Average Sales

Calculate total sales for each product and identify products whose sales are above the average product sales within their category.

### Concepts

* CTE
* `SUM()`
* `AVG()`
* Multiple aggregation levels
* Category-level benchmarking
* CTE-to-CTE comparison

Logical flow:

```text
Orders
  ↓
Product Sales
  ↓
Category Average Sales
  ↓
Compare Product vs Category Average
```

---

## Q9 — Customer Risk Classification

Build customer-level metrics and classify customers according to cancellation behavior.

Metrics include:

* Total orders
* Cancelled orders
* Cancellation rate
* Total spending
* Risk classification

The exercise then uses these metrics to identify customers with:

* Cancellation rate ≥ 30%
* Spending above average customer spending

### Concepts

* CTE
* Conditional aggregation
* `CASE`
* Business classification
* `AVG()` over CTE results
* Multiple-level analysis
* Risk-based filtering

---

## Q10 — Integrated Subquery + CTE Checkpoint

The final exercise combines the major concepts from the batch.

For every customer, calculate:

* Total orders
* Completed orders
* Cancelled orders
* Cancellation rate
* Total spending

Then identify customers satisfying **both** conditions:

```text
Completed orders > average completed orders
AND
Cancellation rate > average customer cancellation rate
```

### Concepts

* CTE
* Multiple CTEs
* Conditional aggregation
* `COUNT()`
* `SUM()`
* `AVG()`
* `CASE WHEN`
* `CROSS JOIN`
* Benchmark comparison
* Multiple levels of aggregation

This serves as an integrated checkpoint for the entire exercise.

---

# Analytical Thinking Developed

The main learning from these exercises goes beyond individual SQL commands.

The exercises develop the ability to recognize **what level of data the business question is asking for**.

For example:

```text
Order level
    ↓
Customer level
    ↓
Category level
    ↓
Overall benchmark
    ↓
Customer vs benchmark
```

A major part of analytical SQL is knowing when you need to move from one level to another.

---

# What I Am Learning / Mastering

Through these exercises, I am strengthening my ability to:

* Write structured SQL queries for business problems
* Work confidently with relational tables
* Use `JOIN` operations correctly
* Perform customer and product-level aggregation
* Use subqueries for benchmark comparisons
* Build reusable analytical datasets using CTEs
* Perform nested aggregation
* Calculate business metrics using conditional aggregation
* Use `CASE WHEN` for business classification
* Compare individual entities against calculated benchmarks
* Break complex analytical problems into logical SQL stages
* Read and explain multi-step SQL queries
* Translate business questions into SQL logic

Most importantly, I am learning to think in terms of:

> **Business Question → Data Level → Metric → Benchmark → Comparison → Business Insight**

---

# Business Analytics Perspective

Although the dataset is intentionally small, the analytical patterns are applicable to many real-world business problems.

The same approach can be extended to questions involving:

* Customer conversion
* Revenue performance
* Cancellation analysis
* Product performance
* Customer segmentation
* Risk identification
* Average order value
* Customer behavior
* Funnel analysis
* Performance benchmarking

For example, instead of simply asking:

> "How many orders did each customer place?"

an analyst can ask:

> "Which customers are behaving differently from the average customer, and what business metric explains that difference?"

That shift from **data retrieval to analytical reasoning** is one of the main objectives of this project.

---

# Tools

* **MySQL**
* **MySQL Workbench**
* SQL

---

# Learning Focus

**Phase:** SQL Proficiency Rebuild — Phase 5
**Topic:** Subqueries + CTEs
**Batch:** Batch 1
**Exercises:** Q1–Q10

The project is part of a broader SQL proficiency roadmap covering:

1. Muscle-Memory Refresh
2. Aggregation Mastery
3. CASE + Business Metrics
4. JOIN Mastery
5. Subqueries + CTEs
6. Advanced Aggregation
7. Window Functions
8. Dates & MySQL
9. Analytical SQL
10. Query Explanation
11. Real-World SQL Cases

---

# Author

**Shorya Bisht**

Data Science| Data Analysis | Web Analytics | Machine learning |

Focused on **Data Science, SQL, Web Analytics, Machine Learning, Python, Power BI and Business Analytics**.

### LinkedIn

[Connect with me on LinkedIn](https://www.linkedin.com/in/shorya-bisht-a20144349/?utm_source=chatgpt.com)

---

## Project Purpose

This repository documents my journey from **writing SQL queries to thinking like a data analyst**—using SQL not only to retrieve data, but to structure business questions, create meaningful metrics, establish benchmarks, and identify patterns in customer and product behavior.
