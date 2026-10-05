CREATE DATABASE IF NOT EXISTS smart_library;
USE smart_library;

-- Table 2: Authors (Created first to avoid foreign key errors in Books)[span_4](start_span)[span_4](end_span)[span_5](start_span)[span_5](end_span)
CREATE TABLE Authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(150)
);

-- Table 1: Books[span_6](start_span)[span_6](end_span)[span_7](start_span)[span_7](end_span)[span_8](start_span)[span_8](end_span)
CREATE TABLE Books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    author_id INT,
    category VARCHAR(100),
    isbn VARCHAR(20) UNIQUE,
    published_date DATE,
    price DECIMAL(10, 2),
    available_copies INT DEFAULT 1,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id) ON DELETE SET NULL
);

-- Table 3: Members[span_9](start_span)[span_9](end_span)[span_10](start_span)[span_10](end_span)
CREATE TABLE Members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE,
    phone_number VARCHAR(20),
    membership_date DATE DEFAULT (CURRENT_DATE)
);

-- Table 4: Transactions[span_11](start_span)[span_11](end_span)[span_12](start_span)[span_12](end_span)
CREATE TABLE Transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT,
    book_id INT,
    borrow_date DATE DEFAULT (CURRENT_DATE),
    return_date DATE NULL,
    fine_amount DECIMAL(10, 2) DEFAULT 0.00,
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE
);
-- 1. Insert new books, authors, and members into the database[span_14](start_span)[span_14](end_span)
INSERT INTO Authors (name, email) VALUES
('Stephen Hawking', 'hawking@science.org'),
('Robert C. Martin', 'unclebob@cleancode.com'),
('J.K. Rowling', 'jkrowling@hogwarts.com');

INSERT INTO Books (title, author_id, category, isbn, published_date, price, available_copies) VALUES
('A Brief History of Time', 1, 'Science', '9780553380163', '1988-04-01', 450.00, 5),
('Clean Code', 2, 'Technology', '9780132350884', '2008-08-01', 650.00, 2),
('Harry Potter', 3, 'Fiction', '9780747532699', '1997-06-26', 350.00, 0);

INSERT INTO Members (name, email, phone_number, membership_date) VALUES
('Alice Johnson', 'alice@gmail.com', '9876543210', '2021-05-15'),
('Bob Smith', 'bob@gmail.com', '9876543211', '2023-01-10'),
('Charlie Brown', 'charlie@gmail.com', '9876543212', '2020-03-22');

-- 2. Update book availability after a book is borrowed or returned[span_15](start_span)[span_15](end_span)
UPDATE Books 
SET available_copies = available_copies - 1 
WHERE book_id = 1 AND available_copies > 0;

-- 3. Delete members who haven't borrowed any books in the last year[span_16](start_span)[span_16](end_span)
DELETE FROM Members 
WHERE member_id NOT IN (
    SELECT DISTINCT member_id 
    FROM Transactions 
    WHERE borrow_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR)
);

-- 4. Retrieve all books with available copies[span_17](start_span)[span_17](end_span)
SELECT * FROM Books WHERE available_copies > 0;
-- 1. Get books published after the year 2015[span_19](start_span)[span_19](end_span)
SELECT * FROM Books WHERE YEAR(published_date) > 2015;

-- 2. Retrieve the top 5 most expensive books[span_20](start_span)[span_20](end_span)
SELECT * FROM Books ORDER BY price DESC LIMIT 5;

-- 3. Find members who joined before 2022[span_21](start_span)[span_21](end_span)
SELECT * FROM Members WHERE membership_date < '2022-01-01';
-- 1. Get books where category = 'Science' AND price < 500[span_24](start_span)[span_24](end_span)
SELECT * FROM Books WHERE category = 'Science' AND price < 500;

-- 2. Find all books that are NOT available for borrowing[span_25](start_span)[span_25](end_span)
SELECT * FROM Books WHERE NOT (available_copies > 0);

-- 3. List all members who joined after 2020 OR have borrowed more than 3 books[span_26](start_span)[span_26](end_span)
SELECT m.* 
FROM Members m
LEFT JOIN Transactions t ON m.member_id = t.member_id
WHERE YEAR(m.membership_date) > 2020
GROUP BY m.member_id
HAVING COUNT(t.transaction_id) > 3 OR YEAR(m.membership_date) > 2020;
-- 1. List all books sorted by title in alphabetical order[span_28](start_span)[span_28](end_span)
SELECT * FROM Books ORDER BY title ASC;

-- 2. Display the number of books borrowed by each member[span_29](start_span)[span_29](end_span)
SELECT member_id, COUNT(*) AS total_borrowed_books 
FROM Transactions 
GROUP BY member_id;

-- 3. Group books by category and show the total count[span_30](start_span)[span_30](end_span)
SELECT category, COUNT(*) AS total_books 
FROM Books 
GROUP BY category;
-- 1. Find the total number of books in each category[span_32](start_span)[span_32](end_span)
SELECT category, COUNT(*) AS total_books FROM Books GROUP BY category;

-- 2. Calculate the average price of books in the library[span_33](start_span)[span_33](end_span)
SELECT AVG(price) AS average_book_price FROM Books;

-- 3. Identify the most borrowed book[span_34](start_span)[span_34](end_span)
SELECT b.title, COUNT(t.transaction_id) AS borrow_count
FROM Transactions t
JOIN Books b ON t.book_id = b.book_id
GROUP BY b.book_id, b.title
ORDER BY borrow_count DESC
LIMIT 1;

-- 4. Calculate the total fines collected[span_35](start_span)[span_35](end_span)
SELECT SUM(fine_amount) AS total_fines_collected FROM Transactions;
-- 1. Retrieve a list of books along with their respective author names using INNER JOIN[span_37](start_span)[span_37](end_span)
SELECT b.title, a.name AS author_name 
FROM Books b
INNER JOIN Authors a ON b.author_id = a.author_id;

-- 2. Get details of members who have borrowed books using LEFT JOIN[span_38](start_span)[span_38](end_span)
SELECT m.name, b.title, t.borrow_date 
FROM Members m
LEFT JOIN Transactions t ON m.member_id = t.member_id
LEFT JOIN Books b ON t.book_id = b.book_id;

-- 3. Find books that haven't been borrowed using RIGHT JOIN[span_39](start_span)[span_39](end_span)
SELECT b.title 
FROM Transactions t
RIGHT JOIN Books b ON t.book_id = b.book_id
WHERE t.transaction_id IS NULL;

-- 4. Show members who have never borrowed a book using FULL OUTER JOIN[span_40](start_span)[span_40](end_span)
-- (Emulated in MySQL using LEFT JOIN and UNION)
SELECT m.name 
FROM Members m
LEFT JOIN Transactions t ON m.member_id = t.member_id
WHERE t.transaction_id IS NULL;
-- 1. Find books that were borrowed by members who registered after 2022[span_42](start_span)[span_42](end_span)
SELECT title FROM Books 
WHERE book_id IN (
    SELECT book_id FROM Transactions 
    WHERE member_id IN (
        SELECT member_id FROM Members WHERE YEAR(membership_date) > 2022
    )
);

-- 2. Identify the most borrowed book using a subquery[span_43](start_span)[span_43](end_span)
SELECT title FROM Books 
WHERE book_id = (
    SELECT book_id FROM Transactions 
    GROUP BY book_id 
    ORDER BY COUNT(*) DESC 
    LIMIT 1
);

-- 3. Get members who have never borrowed a book[span_44](start_span)[span_44](end_span)
SELECT name FROM Members 
WHERE member_id NOT IN (
    SELECT DISTINCT member_id FROM Transactions WHERE member_id IS NOT NULL
);
-- 1. Extract the year from published_date to count books by publication year[span_46](start_span)[span_46](end_span)
SELECT YEAR(published_date) AS pub_year, COUNT(*) AS total_books 
FROM Books 
GROUP BY YEAR(published_date);

-- 2. Find the difference in days between borrow_date and return_date to calculate late return fines[span_47](start_span)[span_47](end_span)
SELECT transaction_id, DATEDIFF(return_date, borrow_date) AS rental_days 
FROM Transactions 
WHERE return_date IS NOT NULL;

-- 3. Format borrow_date as DD-MM-YYYY[span_48](start_span)[span_48](end_span)
SELECT DATE_FORMAT(borrow_date, '%d-%m-%Y') AS formatted_borrow_date 
FROM Transactions;
-- 1. Convert all book titles to uppercase[span_51](start_span)[span_51](end_span)
SELECT UPPER(title) AS uppercase_title FROM Books;

-- 2. Trim whitespace from author names[span_52](start_span)[span_52](end_span)
SELECT TRIM(name) AS clean_author_name FROM Authors;

-- 3. Replace missing email values with "Not Provided[span_53](start_span)"[span_53](end_span)
SELECT name, COALESCE(email, 'Not Provided') AS contact_email FROM Members;
-- 1. Rank books based on the number of times they have been borrowed[span_55](start_span)[span_55](end_span)
SELECT book_id, COUNT(*) AS times_borrowed,
       DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS book_rank
FROM Transactions
GROUP BY book_id;

-- 2. Show the cumulative number of books borrowed per member[span_56](start_span)[span_56](end_span)
SELECT member_id, borrow_date,
       COUNT(*) OVER (PARTITION BY member_id ORDER BY borrow_date) AS running_total
FROM Transactions;

-- 3. Display the moving average of books borrowed in the last 3 months[span_57](start_span)[span_57](end_span)
SELECT borrow_date, 
       AVG(COUNT(transaction_id)) OVER (
           ORDER BY borrow_date 
           RANGE BETWEEN INTERVAL 2 MONTH PRECEDING AND CURRENT ROW
       ) AS moving_avg_borrowed
FROM Transactions
GROUP BY borrow_date;
-- 1. Assign a Membership_Status column[span_60](start_span)[span_60](end_span)[span_61](start_span)[span_61](end_span)
SELECT m.name,
    CASE 
        WHEN MAX(t.borrow_date) >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH) THEN 'Active'
        ELSE 'Inactive'
    END AS Membership_Status
FROM Members m
LEFT JOIN Transactions t ON m.member_id = t.member_id
GROUP BY m.member_id, m.name;

-- 2. Categorize books by release era[span_62](start_span)[span_62](end_span)[span_63](start_span)[span_63](end_span)
SELECT title, published_date,
    CASE 
        WHEN YEAR(published_date) > 2020 THEN 'New Arrival'
        WHEN YEAR(published_date) < 2000 THEN 'Classic'
        ELSE 'Regular'
    END AS book_category
FROM Books;
SELECT m.name,
    CASE 
        WHEN MAX(t.borrow_date) >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH) THEN 'Active'
        ELSE 'Inactive'
    END AS Membership_Status
FROM Members m
LEFT JOIN Transactions t ON m.member_id = t.member_id
GROUP BY m.member_id, m.name;