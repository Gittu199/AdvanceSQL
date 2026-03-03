-- ============================================================
--         ASSIGNMENT 17 : ADVANCED SQL
-- ============================================================

-- ============================================================
-- TABLE CREATION & DATA INSERTION (Dataset for Q6–Q10)
-- ============================================================

CREATE TABLE Products (
    ProductID   INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category    VARCHAR(50),
    Price       DECIMAL(10,2)
);

INSERT INTO Products VALUES
(1, 'Keyboard', 'Electronics', 1200),
(2, 'Mouse',    'Electronics',  800),
(3, 'Chair',    'Furniture',   2500),
(4, 'Desk',     'Furniture',   5500);

CREATE TABLE Sales (
    SaleID    INT PRIMARY KEY,
    ProductID INT,
    Quantity  INT,
    SaleDate  DATE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

INSERT INTO Sales VALUES
(1, 1, 4,  '2024-01-05'),
(2, 2, 10, '2024-01-06'),
(3, 3, 2,  '2024-01-10'),
(4, 4, 1,  '2024-01-11');


-- ============================================================
-- Q1. What is a Common Table Expression (CTE), and how does
--     it improve SQL query readability?
-- ============================================================

/*
ANSWER:
A Common Table Expression (CTE) is a temporary, named result set
defined within a WITH clause that exists only for the duration of
a single SQL query. It is not stored in the database — it is
evaluated fresh each time the query runs.

Syntax:
    WITH cte_name AS (
        SELECT ...
    )
    SELECT * FROM cte_name;

How CTEs improve readability:
1. MODULARITY   – Break complex queries into smaller, named blocks
                  that are easy to understand individually.
2. REUSABILITY  – Reference the same CTE multiple times within the
                  same query instead of repeating subqueries.
3. READABILITY  – Read like a step-by-step story: "first compute X,
                  then use X to compute Y."
4. DEBUGGING    – Easier to isolate and test individual logical steps.
5. RECURSION    – CTEs support recursive queries (e.g., hierarchy
                  traversal) which subqueries cannot do.

Example comparison:

-- Without CTE (hard to read):
SELECT ProductID, Revenue
FROM (
    SELECT p.ProductID, p.Price * s.Quantity AS Revenue
    FROM Products p JOIN Sales s ON p.ProductID = s.ProductID
) sub
WHERE Revenue > 3000;

-- With CTE (clean and readable):
WITH RevenueCalc AS (
    SELECT p.ProductID, p.Price * s.Quantity AS Revenue
    FROM Products p JOIN Sales s ON p.ProductID = s.ProductID
)
SELECT ProductID, Revenue FROM RevenueCalc WHERE Revenue > 3000;
*/


-- ============================================================
-- Q2. Why are some views updatable while others are read-only?
--     Explain with an example.
-- ============================================================

/*
ANSWER:
A VIEW is a virtual table based on a SELECT query. Whether a view
is updatable depends on the complexity of its underlying query.

A view is UPDATABLE when:
  - It is based on a single table (no JOINs).
  - It does NOT use aggregate functions (SUM, COUNT, AVG, etc.).
  - It does NOT use DISTINCT, GROUP BY, HAVING, or UNION.
  - It does NOT use subqueries in the SELECT list.
  - Every row in the view maps directly to exactly one row in the
    base table.

A view is READ-ONLY when:
  - It uses JOINs across multiple tables.
  - It uses GROUP BY / aggregate functions (rows don't map 1-to-1).
  - It uses DISTINCT or set operations (UNION, INTERSECT).

EXAMPLE:

-- Updatable view (single table, no aggregates):
CREATE VIEW vw_ProductPrices AS
SELECT ProductID, ProductName, Price
FROM Products;

-- This UPDATE works because the view maps directly to Products:
UPDATE vw_ProductPrices SET Price = 1500 WHERE ProductID = 1;

-- Read-only view (uses GROUP BY + aggregate):
CREATE VIEW vw_CategoryAvg AS
SELECT Category, AVG(Price) AS AvgPrice
FROM Products
GROUP BY Category;

-- This UPDATE would FAIL — MySQL cannot determine which base row
-- to update when rows are grouped/aggregated:
-- UPDATE vw_CategoryAvg SET AvgPrice = 1000 WHERE Category = 'Electronics';
-- ERROR: The target table vw_CategoryAvg of the UPDATE is not updatable.
*/


-- ============================================================
-- Q3. What advantages do stored procedures offer compared to
--     writing raw SQL queries repeatedly?
-- ============================================================

/*
ANSWER:
A Stored Procedure is a pre-compiled, named block of SQL code
stored in the database that can be called with CALL procedure_name().

Advantages over raw SQL:

1. REUSABILITY
   Write the logic once, call it from anywhere — applications,
   scripts, or other procedures — without rewriting the SQL.

2. PERFORMANCE
   Stored procedures are pre-compiled and cached by the database
   engine. Repeated raw SQL is parsed and compiled every time,
   making procedures significantly faster for frequent operations.

3. REDUCED NETWORK TRAFFIC
   Instead of sending a large SQL block from the application to the
   database server each time, only a short CALL statement is sent.

4. SECURITY
   Users can be granted EXECUTE permission on a procedure without
   giving them direct SELECT/INSERT/UPDATE/DELETE access to tables.
   This prevents accidental or malicious direct table manipulation.

5. MAINTAINABILITY
   Business logic lives in one place. Changing a procedure updates
   behavior everywhere it is used, without touching application code.

6. PARAMETERIZATION
   Procedures accept IN/OUT parameters, making them flexible and
   preventing SQL injection when used correctly.

7. TRANSACTION CONTROL
   Stored procedures can encapsulate BEGIN / COMMIT / ROLLBACK logic
   to ensure data integrity across multiple statements.

Example:
   CALL GetProductsByCategory('Electronics');
   -- vs writing the full SELECT query each time in every app layer.
*/


-- ============================================================
-- Q4. What is the purpose of triggers in a database?
--     Mention one use case where a trigger is essential.
-- ============================================================

/*
ANSWER:
A TRIGGER is a database object that automatically executes a
predefined block of SQL code in response to a specific event
(INSERT, UPDATE, or DELETE) on a table.

Triggers fire automatically — no CALL or manual invocation needed.

Types:
  - BEFORE INSERT / UPDATE / DELETE  (fires before the DML operation)
  - AFTER  INSERT / UPDATE / DELETE  (fires after the DML operation)

Purpose:
  1. AUDIT LOGGING     – Automatically record who changed what and when.
  2. DATA INTEGRITY    – Enforce complex business rules that constraints
                         alone cannot handle.
  3. ARCHIVING         – Move deleted records to a history/archive table.
  4. DERIVED DATA      – Auto-update calculated or summary columns.
  5. CASCADING ACTIONS – Perform related updates across multiple tables.

ESSENTIAL USE CASE — Audit Trail:
In a banking system, whenever an account balance is updated, a trigger
automatically logs the old balance, new balance, timestamp, and user
into an AuditLog table. This is essential for regulatory compliance
(e.g., RBI, SOX) and fraud detection. You cannot rely on application
code alone because direct database access (via scripts or admin tools)
would bypass the application entirely — only a trigger guarantees the
log is always written.
*/


-- ============================================================
-- Q5. Explain the need for data modelling and normalization
--     when designing a database.
-- ============================================================

/*
ANSWER:

DATA MODELLING:
Data modelling is the process of defining the structure, relationships,
and constraints of data before building a database. It produces
blueprints (ER diagrams) that guide physical implementation.

Need for data modelling:
  - Ensures all stakeholders share a common understanding of the data.
  - Identifies entities, attributes, and relationships early.
  - Reduces costly redesigns after implementation.
  - Helps choose the right data types and indexes.
  - Produces a scalable, maintainable database structure.

NORMALIZATION:
Normalization is the process of organizing tables to reduce data
redundancy and improve data integrity by applying a series of
Normal Forms (1NF → 2NF → 3NF → BCNF).

Normal Forms:
  1NF – Eliminate repeating groups; each column holds atomic values.
  2NF – Remove partial dependencies (every non-key column depends
        on the WHOLE primary key).
  3NF – Remove transitive dependencies (non-key columns depend only
        on the primary key, not on other non-key columns).

Problems solved by normalization:
  1. UPDATE ANOMALY  – Changing a value in one place but not others.
     Example: Student table stores mentor's phone. Mentor changes
     number → must update every student row → one miss = inconsistency.

  2. INSERT ANOMALY  – Cannot add data without unrelated data.
     Example: Cannot add a new course unless at least one student
     enrolls in it.

  3. DELETE ANOMALY  – Deleting a row unintentionally removes other info.
     Example: Deleting the last student in a course also deletes the
     course information.

By normalizing:
  - Each fact is stored in exactly ONE place.
  - Updates, inserts, and deletes are safe and consistent.
  - Storage is used efficiently.
  - Query logic becomes cleaner and more predictable.
*/


-- ============================================================
-- Q6. Write a CTE to calculate the total revenue for each
--     product (Revenue = Price × Quantity), and return only
--     products where revenue > 3000.
-- ============================================================

WITH ProductRevenue AS (
    SELECT
        p.ProductID,
        p.ProductName,
        p.Price,
        s.Quantity,
        (p.Price * s.Quantity) AS TotalRevenue
    FROM Products p
    JOIN Sales s ON p.ProductID = s.ProductID
)
SELECT
    ProductID,
    ProductName,
    Price,
    Quantity,
    TotalRevenue
FROM ProductRevenue
WHERE TotalRevenue > 3000;


-- ============================================================
-- Q7. Create a view named vw_CategorySummary that shows:
--     Category, TotalProducts, AveragePrice.
-- ============================================================

CREATE VIEW vw_CategorySummary AS
SELECT
    Category,
    COUNT(ProductID)  AS TotalProducts,
    AVG(Price)        AS AveragePrice
FROM Products
GROUP BY Category;

-- Verify the view:
SELECT * FROM vw_CategorySummary;


-- ============================================================
-- Q8. Create an updatable view containing ProductID,
--     ProductName, and Price. Then update the price of
--     ProductID = 1 using the view.
-- ============================================================

-- Create updatable view (single table, no aggregates):
CREATE VIEW vw_ProductDetails AS
SELECT ProductID, ProductName, Price
FROM Products;

-- Update price of ProductID = 1 through the view:
UPDATE vw_ProductDetails
SET Price = 1500
WHERE ProductID = 1;

-- Verify the update:
SELECT * FROM vw_ProductDetails;
SELECT * FROM Products WHERE ProductID = 1;


-- ============================================================
-- Q9. Create a stored procedure that accepts a category name
--     and returns all products belonging to that category.
-- ============================================================

DELIMITER $$

CREATE PROCEDURE GetProductsByCategory (
    IN p_Category VARCHAR(50)
)
BEGIN
    SELECT
        ProductID,
        ProductName,
        Category,
        Price
    FROM Products
    WHERE Category = p_Category;
END$$

DELIMITER ;

-- Test the stored procedure:
CALL GetProductsByCategory('Electronics');
CALL GetProductsByCategory('Furniture');


-- ============================================================
-- Q10. Create an AFTER DELETE trigger on the Products table
--      that archives deleted rows into a ProductArchive table.
--      Archive stores: ProductID, ProductName, Category,
--      Price, and DeletedAt timestamp.
-- ============================================================

-- Step 1: Create the ProductArchive table
CREATE TABLE ProductArchive (
    ArchiveID   INT PRIMARY KEY AUTO_INCREMENT,
    ProductID   INT,
    ProductName VARCHAR(100),
    Category    VARCHAR(50),
    Price       DECIMAL(10,2),
    DeletedAt   DATETIME
);

-- Step 2: Create the AFTER DELETE trigger
DELIMITER $$

CREATE TRIGGER trg_ArchiveDeletedProduct
AFTER DELETE ON Products
FOR EACH ROW
BEGIN
    INSERT INTO ProductArchive
        (ProductID, ProductName, Category, Price, DeletedAt)
    VALUES
        (OLD.ProductID, OLD.ProductName, OLD.Category, OLD.Price, NOW());
END$$

DELIMITER ;

-- Test the trigger (delete a product and check archive):
DELETE FROM Products WHERE ProductID = 2;

-- Verify archived row:
SELECT * FROM ProductArchive;

-- ============================================================
--                 END OF ASSIGNMENT 17
-- ============================================================