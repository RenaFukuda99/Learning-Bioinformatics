# Introduction to Databases with SQL
Official notes: https://cs50.harvard.edu/sql/notes/0/

## Querying
Why use databases?

- Good way to organize data
- Advantages over spreadsheets: Scale, update capacity (many updates a second), speed

Which DBMS (database management system) should we choose

- Consider cost, amount of support, weight
- This class uses SQLite and MySQL and PostgreSQL

General syntax of a query:
```
SELECT * FROM tablename WHERE (condition)
```
For the ```WHERE``` function, we can use a variety of operators:

- ```!=``` 
- ```IS NULL```/```IS NOT NULL```
- ```BETWEEN my_min AND my_max```
- ```LIKE "%pattern%"``` for unfixed lengths or ```LIKE "pattern___"``` for fixed lengths

We can also use:

- ```LIMIT```
- ```ORDER BY var ASC``` or ```ORDER BY var DESC```
- Aggregating functions:	```AVG```, ```MAX```, ```MIN```, ```SUM```, ```COUNT```

We also have useful commands to run in the terminal:

- ```Sqlite3 database_name.db``` – open database
-	```.tables``` – show all tables
- ```.schema``` – show tables/triggers/views/indices in database

## Relating
A	relational database is a database containing tables with relationships. Entity 
relationship diagrams are a useful way to visualize these relations.
 
### Keys
Primary keys are a unique identifier for a table
```
CREATE TABLE table (
  id INT,
  PRIMARY KEY(id)
)
```
Foreign keys reference the primary key of another table and are useful for relations.
```
CREATE TABLE table (
  id INT,
  book_id INT,
  PRIMARY KEY(id),
  FOREIGN KEY(book_id) REFERENCES books(id)
)
```

### Subqueries 
We can stack queries inside queries using parentheses.

```
SELECT * 
FROM mytable
WHERE id IN (SELECT book_id FROM books)
```

### Joins
We can join related tables using the syntax below:
```
SELECT *
FROM table1 t1
JOIN table2 t2
ON  t1.id = t2.id2
```
There is also ```LEFT JOIN```, ```RIGHT JOIN```, and ```FULL JOIN```

We can also use ```GROUP BY``` – useful for finding counts, averages, etc.

### Sets 
We can use ```INTERSECT```, ```UNION```, and ```EXCEPT``` from multiple queries (selects)
```
SELECT name FROM table WHERE id > 5
INTERESECT 
SELECT name FROM table2 WHERE id > 8
```

## Designing
Normalizing is the process of reducing redundancies in the database by separating entities into their own tables

### Creating tables
SQLite types include: Null, Integer, Real, Text, Blob (large picture/video/audio). SQLite has type affinity – will try to convert ‘wrong’ type to column preference.
```
CREATE TABLE table_name (var1 TYPE, …)
```

### Table constraints
```
PRIMARY KEY(var),
FOREIGN KEY(var) REFERENCES table2(var2)
```

### Column constraints
We can use the following to constrain columns:
```
CREATE TABLE (
  id INT,
  name TEXT NOT NULL,
  SSN INT UNIQUE,
  check_in_time NUMERIC DEFAULT CURRENT_TIMESTAMP,
  age INT CHECK(age > 21)
);
```

### Altering tables
We can alter tables by renaming, adding columns, renaming columns, or deleting columns:
```
ALTER TABLE table RENAME TO table2;
ALTER TABLE table2 ADD COLUMN var1 TEXT;
ALTER TABLE table2 RENAME COLUMN var1 TO var2
ALTER TAVLE table2 DROP COLUMN var2
```

## Writing
### Inserting data
We can insert data into existing tables
```
INSERT INTO table (var1, var2, var3) VALUES (‘1’,’2’,’3’)
```
We can also insert multiple rows at a time
```
INSERT INTO table (var1, var2, var3) 
VALUES 
    (‘1’,’2’,’3’),
    (1’,’2’,’3’);
``` 
### Working with CSVs
We can import a CSV into a table (skip 1 removes the header). 
It may be useful to store into a temporary table first.
```
.import --csv --skip 1 filename.csv table_name
```

### Deleting data
We can delete conditionally:
```
DELETE FROM table WHERE …
```
If you are deleting a foreign key, you can run into errors. 
To get around this, we can specify what the code should do upon deletion of columns:
```
FOREIGN KEY() REFERENCES table() ON DELETE RESTRICT 
FOREIGN KEY() REFERENCES table() ON DELETE NO ACTION
FOREIGN KEY() REFERENCES table() ON DELETE SET NULL
FOREIGN KEY() REFERENCES table() ON DELETE DEFAULT
FOREIGN KEY() REFERENCES table() ON DELETE CASCADE
```
Most are self-explanatory, but cascade will delete the referenced id in the relevant table.

### Updating data
Sometimes we make a mistake or need to change a row. To do so, we use ```UPDATE```
```
UPDATE table SET var = ‘value’ WHERE ...
```

## Viewing 
Views allow for easier visualization of separated data as a ‘virtual table’

### Creating views
```
CREATE VIEW view_name AS SELECT … FROM …
```
### Temporary views
Temporary views only last for the duration of the connection.
```
CREATE TEMPORARY VIEW view_name AS …
```
### Common Table Expression (CTE)
CTEs last just for one query.
```
WITH cte_name AS (
  SELECT * FROM table WHERE ...
) 
SELECT * FROM table WHERE...;
```
### Uses for views
- Simplifying: Use joins to simplify separated data
- Aggregating: Compute statistics (ex. Average) to look at overall data
- Partitioning: look at subsets of data using ‘where’
- Securing: limit access to certain data by limiting what others can see (ex. Analysts) 

### Soft deletions
Instead of permanently deleting data, we can add a ‘deleted’ column to a table. 
```
ALTER TABLE table_name ADD COLUMN deleted INTEGER DEFAULT 0
```
Now we can performa soft delete:
```
UPDATE table_name 
SET deleted = 1 WHERE…
```
Now, create view for current items only
```
CREATE VIEW view_name 
AS SELECT (vars) 
FROM table 
WHERE deleted = 0;
```
Finally, create a trigger that auto-“deletes” when you try to delete on the view
```
CREATE TRIGGER delete 
INSTEAD OF DELETE ON view
FOR EACH ROW
BEGIN
    UPDATE table SET deleted = 1
    WHERE id = OLD.id
END
```
We can also create a trigger to insert data into a view (when id already exists)
```
CREATE TRIGGER insert_when_exists
INSTEAD OF INSERT ON view
FOR EACH ROW
WHEN NEW.id_num IN (SELECT id_num FROM table)
BEGIN
    UPDATE table
    SET deleted = 0
    WHERE id_num = NEW.id_num
END
```
And create trigger to insert data into a view (when is is new)
```
CREATE TRIGGER insert_when_new
INSTEAD OF INSERT ON view
FOR EACH ROW
WHEN NEW.id_num NOT IN (SELECT id_num FROM table)
BEGIN
    INSERT INTO  table (var1, var2, var3)
    VALYES (NEW.var1, NEW.var2, NEW.var3)
END
```

## Optimizing
We are often interested in optimizing runtime and space. We can use ```.timer on```
to look at the runtime of a query, and use ```EXPLAIN QUERY PLAN``` to look at how the query operates.

### If you run a query very often, you can use an index to speed it up 
```
CREATE INDEX index_name ON table (var);
CREATE INDEX index_name_2 ON (var1, var2);
```
A covering index includes all info for a particular query.

### Indexes occupy space as a balance tree (or B-Tree)
B-Trees have many nodes, and are structured as a root with children (branches, leaves). 
We effectively creates a table copy that you can order/sort and search more efficiently. 
Since the copy is large, we often break up the copy into sections.

### Partial index
We can create a partial index with subset of the table (hopefully the most queried data, 
ex. Most recent) to save space.

### Vaccum
Run ```VACUUM``` to free up unused space (check with ```du -b database_name.db```)

### Concurrency
We often need to handle multiple queries at the same time. Some transactions/changes are 
multi-part and you do not want them broken up by another user

### Transactions
Guiding principles of transactions include:

- Atomicity (can’t be broken down)
- Consistency (cannot break database constraints)
- Isolation (multiple user transactions cannot interfere with one another)
-	Durability (if databaase fails, all data changes by transactions will remain)

```
BEGIN TRANSACTION;
UPDATE table SET balance = balance + 10 WHERE…;
UPDATE table Set balance = balance – 10 WHERE…;
COMMIT;
```
If there is an issue, you can ```ROLLBACK``` a transaction

### Race conditions
Race conditions occur when multiple entities try to simultaneously access and change database, 
causing inconsistencies. Therefore, we need to process each transaction in isolation. During
a transaction, you can lock your database.
```UNLOCKED``` is the default state (no one is making changes). ```SHARED``` allows multiple 
users to read, while ```EXCLUSIVE``` allows only one action (even reading) at a time.

```
BEGIN EXCLUSIVE TRANSACTION
...
COMMIT;
```

## Scaling
MySQL and PostgreSQl are database servers – run on dedicated hardware – 
resulting in faster queries.

### Connecting to MySQL

```
mysql -u root -h 127.0.0.1 -P 3306 -p
```

We specify the user ```-u```, and we want to connect to ```root``` (admin connection). 
```127.0.0.1``` is the address of own computer and ```3306``` is the port you want to connect to (default). 
```-p``` indicates you want to be prompted for a password.

### Navigating MySQL
Using databases:
```
SHOW DATABASES;
CREATE DATABASES `my_db`;
USE `my_db`;
```
Using tables:
```
CREATE TABLE `table` (
    `id` INT AUTO_INCREMENT 
    PRIMARY KEY(`id`)
);
SHOW TABLES;
DESCRIBE `table`;
```

### MySQL Data types

- Integers: TINYINT, SMALLINT, MEDIUMINT, INT, BIGINT
-	Text: CHAR(2) of set length, and VARCHAR(32) of variable length (with max) 
  - TEXT is for longer chunks of text : TINYTEXT, TEXT, MEDIUMTEXT, LONGTEXT, BLOB (binary)
- ENUM – predefined options ex. ```ENUM(‘red’, ‘green’, ‘orange’) NOT NULL```
- SET – like enum, but can have multiple values per row
- Date: DATE, YEAR, TIME, DATETIME, TIMESTAMP
-	Real: FLOAT, DOUBLE PRECISION, DECIMAL(5,2)
  - Decimal is of defined precision: first number is number of positions, second number is numbers after the decimal


#### Altering tables
```
ALTER TABLE `table` MODIFY `var` ENUM(…) NOT NULL;
ALTER TABLE `table` ADD COLUMN  …;
```
#### Stored procedures
Stored procedures are	ways to automate SQL statements. It is useful to change delimiter so we can use ; inside our procedure: 
```delimiter //```
Now, create our procedure:
```
CREATE PROCEDURE `my_procedure`
BEGIN
    SELECT … FROM … WHERE … 
END//
```
After, change delimiter back: ```delimiter ;```
Now, call the procedure: 
```
CALL my_procedure();
```
#### Stored procedures with parameters
We can have a procedure with an input (parameter), like a function.	We can also have multiple actions within a procedure.
```
delimiter //
CREATE PROCEDURE `sell` (IN `soldIid` INT)
BEGIN
    UPDATE `collections` SET `deleted` = 1
    WHERE `id` = `sold_id`;
    INSERT INTO `transactions` (`title`,`action`)
    VALUES (
        (SELECT `title` FROM `collections` WHERE `id`=`sold_id`), 
    ‘sold)
END //
delimiter ;
```
We can now call: ```CALL `sell`(2);```
Stored procedures are compatible with if statements, loops (for/while), etc.

### PostgreSQL
Connecting with PostgreSQL
```
psql postgresql://postgres@127.0.0.1:5432/postgres
```
View databases:
```
\l
```
Creating databases
```
CREATE DATABASE “my_db”;
```
Connecting to database
```
\c “my_db”
```
Look at tables
```
\dt
\d “table_name”
```
Creating tables (serial means auto-increment integer)
```
CREATE TABLE “my_table” (“id” SERIAL, PRIMARY KEY(“id));
```
Exiting
```
\q
```

#### PostgreSQL datatypes

- Integers: SMALLINT, INT, BIGINT, SERIAL
- Text: VARCHAR(32)
- ENUM
```CREATE TYPE “swipe_type” AS ENUM (‘enter’, ‘exit’)```
- Time: TIMESTAMP, DATE, TIME, INTERVAL (Get current timestamp using now())
- MONEY
- NUMERIC(precision, scale)  - instead of MySQL’s decimal

### Scaling techniques
We can optimize queries so much. Eventually we need to scale up:

- Vertical scaling – increasing a server’s computing power
- Horizontal scaling – distributing load across more servers

We can use these new servers for replication: keeping copies of a database on multiple servers. These
servers can have several different set-ups:

- Single-leader: single server handles incoming writes and copies to other servers
- Multi-leader: multiple servers receive updates (higher complexity)
- Leaderless

Here we will focus on single-leader systems. 
A read replica is a copy of a database from which data may only be read (follower).
A single-leader scheme can be synchronous or asynchronous:

- Synchronous – lead will wait for follower to get/process data before another action (slower)
- Asynchronous – leader sends data to follower, resumes next action (less redundancy)

#### Sharding
- Splitting up data across multiple servers in an organized manner (ex. Alphabetical)
- Want to have about equal distribution of action (no hotspot)
- No/less replication – if one system goes down, all do – need to incorporate forms of replication

### Access control with MySQL
Create a new user
```
CREATE USER  ‘myname’ IDENTIFIED BY ‘password’
```
We can log-in as previous using out new password. We can then try to look at the database:
```
SHOW DATABASES;
```
We likely can’t see much, since we not admin. Therefore, we can grant access (from admin login):
```
GRANT SELECT ON database.table To myname;
REVOKE SELECT ON database.table FROM myname;
```
Now, we can access our (virtual) table from our new user login, but only what we are permitted:
```USE database;```


### SQL injection attack
Users may	maliciously insert into SQL database to access data/features that should be inaccessible.
Prepared statements can clean up input to prevent against injection attacks
