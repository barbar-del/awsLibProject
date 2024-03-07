drop table IF EXISTS loan_log;
drop table IF EXISTS loaned_books;
drop table IF EXISTS users;
drop table IF EXISTS books;
drop table IF EXISTS genre;

-- ===========================  ==================================

-- 2 user types: librarian(admin), regular user
-- TO DO LIST:
-- DONE -- 1. update tables to match mysql
-- 2. update procedures to match mysql:
-- DONE 83 -- all users:	a. log in: check if email and password exists and match - return true/false
-- DONE 121 -- regular:    	b. sign up: check if email exists - if true - user exists, if false user not exist and create user.
-- DONE 183 -- all users:	c. show all available books: return all books with stock > 0
-- DONE 313 -- admin:		d. show all loaned books.
-- DONE 268 -- all users:	e. show user loaned books (per email).
-- DONE 197 -- regular:    	f. loan book: procudre to update stock amount and add value to loaned_books table (user mail and book id)
-- 								note: don't let user loan more than 1 copy
-- DONE 237-- regular:		g. return book: procudre to update stock amount and remove value from loaned_books table (user mail and book id)
-- 								note: check what we need to do if user has more than 1 copy of the same book.
-- DONE 288 -- admin:		h. add book: check if book exists (name, author genre) if true add to stock_amount if false add new.
-- DONE 329 -- admin:		i. remove user: check if user has no loaned books and remove.
-- DONE 153 -- all users:	j. reset password (per user)

-- ===========================  ==================================

CREATE TABLE users (
  user_email VARCHAR(255) PRIMARY KEY,
  user_full_name varchar(255) NOT NULL,
  user_password VARCHAR(255) NOT NULL,
  CHECK (user_email LIKE '_%@_%._%')
  );

-- Create table for book genres with name as the primary key
CREATE TABLE genre (
  genre_name VARCHAR(50) PRIMARY KEY
);

-- Create table for books
CREATE TABLE books (
  book_id INT PRIMARY KEY AUTO_INCREMENT,
  book_name VARCHAR(255) NOT NULL,
  book_author_name VARCHAR(255) NOT NULL,
  book_genre_name VARCHAR(50),
  book_stock_amount INT,
  FOREIGN KEY (book_genre_name) REFERENCES genre(genre_name)
);

-- Create table for currently loaned books
create table loaned_books(
	loan_user_mail varchar(255),
	loaned_book_id int,
	FOREIGN KEY (loaned_book_id) REFERENCES books(book_id),
	FOREIGN KEY (loan_user_mail) REFERENCES users(user_email)
);

-- Create table for loan logs
CREATE TABLE loan_log (
  id INT PRIMARY KEY AUTO_INCREMENT,
  book_id INT,
  email VARCHAR(255),
  loan_date DATETIME,
  loan_return_date DATETIME,
  is_returned BIT NOT NULL DEFAULT 0,
  FOREIGN KEY (book_id) REFERENCES books(book_id),
  FOREIGN KEY (email) REFERENCES users(email) ON DELETE CASCADE ON UPDATE CASCADE
);

-- =========================== end create tables ==================================

-- =========================== insert genres ======================================

INSERT INTO genre (genre_name) VALUES ('Fiction');
INSERT INTO genre (genre_name) VALUES ('Non-Fiction');
INSERT INTO genre (genre_name) VALUES ('Mystery');
INSERT INTO genre (genre_name) VALUES ('Sci-Fi');
INSERT INTO genre (genre_name) VALUES ('Fantasy');

select * from genre;
-- =========================== insert users ======================================
insert into users (user_email, user_full_name, user_password) values
('barbar11@rty.com', 'bar yadgar1', '111'),
('barbar12@rty.com', 'bar yadgar2', '222'),
('barbar13@rty.com', 'bar yadgar3', '333'),
('barbar14@rty.com', 'bar yadgar4', '444');

select * from users;

-- =========================== insert books ======================================

insert into books (book_name, book_author_name, book_genre_name, book_stock_amount) values
('alibaba','barbur','Mystery',5),
('minime','barbur2','Fantasy',2),
('alibaba','barbur2','Fantasy',6),
('sodastream','barbur','Fantasy',1);

select * from books;

-- -- =========================== end inserts ===================================

-- =========================== User Management ==================================

-- PROCDURE TO LOG IN USER

DELIMITER //

CREATE PROCEDURE LoginUser (
    IN login_email VARCHAR(255),
    IN login_password VARCHAR(255),
    OUT login_status BOOLEAN,
    OUT login_status_message VARCHAR(255)
)
BEGIN
    DECLARE user_count INT;
    DECLARE password_matched BOOLEAN;
    -- Check if the email exists
    SELECT COUNT(*) INTO user_count FROM users WHERE user_email = login_email;
    
    -- If the email exists
    IF user_count > 0 THEN
        -- Check if the password matches
        SELECT IF(user_password = login_password, TRUE, FALSE) INTO password_matched FROM users WHERE user_email = login_email;
        IF password_matched THEN
            SET login_status = TRUE; -- Password matched, set login status to true
            SET login_status_message = 'Logged in successfuly!';
        ELSE
            SET login_status = FALSE; -- Password doesn't match, set login status to false
            SET login_status_message = 'Incorrect password'; -- Set error message
        END IF;
    ELSE
        SET login_status = FALSE; -- Email doesn't exist, set login status to false
        SET login_status_message = 'Email does not exist'; -- Set error message
    END IF;
END //

DELIMITER ;

CALL LoginUser('ran_test@test.com', '111', @login_status, @login_status_message);
select @login_status, @login_status_message;
CALL LoginUser('ran_test222@test.com', '224142', @login_status, @login_status_message);
select @login_status, @login_status_message;

select * from users

-- ------------------------------------------------------------

-- PROCDURE TO SIGN UP USER

DELIMITER //

CREATE PROCEDURE SignupUser (
    IN signup_email VARCHAR(255),
    IN new_user_name VARCHAR(255),
    IN signup_password VARCHAR(255),
    OUT signup_status BOOLEAN,
    OUT signup_status_message VARCHAR(255)
)
BEGIN
    DECLARE user_count INT;
    
    -- Check if the email exists
    SELECT COUNT(*) INTO user_count FROM users WHERE user_email = signup_email;
    
    -- If the email exists
    IF user_count > 0 THEN
        SET signup_status = FALSE; -- Set signup status to false
        SET signup_status_message = 'Email already exists'; -- Set error message
    ELSE
        -- Insert the new user
        INSERT INTO users (user_email, user_full_name, user_password) VALUES (signup_email, new_user_name, signup_password);
        SET signup_status = TRUE; -- Set signup status to true
        SET signup_status_message = 'Signed up successfuly!';
    END IF;
END //

DELIMITER ;

CALL SignupUser('ran_test444@test.com', 'ran444 test444', '444', @signup_status, @signup_status_message);
select @signup_status, @signup_status_message;

select * from users
------------------------------------------------------------

-- PROCEDURE TO RESET USER PASSWORD

DELIMITER //

CREATE PROCEDURE ResetPassword (
    IN reset_user_email VARCHAR(255),
    IN new_password VARCHAR(255)
)
BEGIN
    DECLARE user_exists INT;
    
    -- Check if the user exists
    SELECT COUNT(*) INTO user_exists FROM users WHERE user_email = reset_user_email;
    
    IF user_exists > 0 THEN
        -- Update user's password
        UPDATE users SET user_password = new_password WHERE user_email = reset_user_email;
        SELECT 'Password reset successfully.' AS message;
    ELSE
        SELECT 'User does not exist.' AS message;
    END IF;
END //

DELIMITER ;

CALL ResetPassword('ran_test444@test.com', '999');
select* from users;
-- =========================================================================== 

-- ============================= BOOKS MANAGEMENT =============================

-- SHOW ALL AVAILABLE BOOKS

DELIMITER //

CREATE PROCEDURE ShowAvailableBooks ()
BEGIN
    -- Select all available books
    SELECT * FROM books WHERE book_stock_amount > 0;
END //

DELIMITER ;

CALL ShowAvailableBooks();

-- ------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE LoanBook (
    IN current_user_email VARCHAR(255),
    IN current_book_id INT
)
BEGIN
    DECLARE current_stock INT;
    DECLARE user_has_book INT;
    
    -- Check if user already has a copy of the book
    SELECT COUNT(*) INTO user_has_book FROM loaned_books WHERE loan_user_mail = current_user_email AND loaned_book_id = current_book_id;
    
    IF user_has_book > 0 THEN
        SELECT 'User already has a copy of this book.' AS message;
    ELSE
        -- Check current stock amount
        SELECT book_stock_amount INTO current_stock FROM books WHERE book_id = current_book_id;
        
        -- Check if stock is available
        IF current_stock > 0 THEN
            -- Decrease stock amount by 1
            UPDATE books SET book_stock_amount = book_stock_amount - 1 WHERE book_id = current_book_id;
            -- Add entry to loaned_books table
            INSERT INTO loaned_books (loan_user_mail, loaned_book_id) VALUES (current_user_email, current_book_id);
            
            SELECT 'Book loaned successfully.' AS message;
        ELSE
            SELECT 'Book not available for loan.' AS message;
        END IF;
    END IF;
END //

DELIMITER ;

select * from users;
select * from books;
select * from loaned_books;
-- LOAN A BOOK
CALL LoanBook('ran_test@test.com',4);
CALL LoanBook('ran_test@test.com',2);
CALL LoanBook('ran_test@test.com',2);
CALL LoanBook('barbar11@rty.com@test.com',4);

-- ------------------------------------------------------------

-- RETURN A BOOK

DELIMITER //

CREATE PROCEDURE ReturnBook (
    IN return_user_email VARCHAR(255),
    IN return_book_id INT
)
BEGIN
    DECLARE loaned_book_count INT;
    
    -- Check if the book is loaned out by the user
    SELECT COUNT(*) INTO loaned_book_count FROM loaned_books WHERE loan_user_mail = return_user_email AND loaned_book_id = return_book_id;
    
    IF loaned_book_count > 0 THEN
        -- Increase stock amount by 1
        UPDATE books SET book_stock_amount = book_stock_amount + 1 WHERE book_id = return_book_id;
        -- Remove entry from loaned_books table
        DELETE FROM loaned_books WHERE loan_user_mail = return_user_email AND loaned_book_id = return_book_id;
        
        SELECT 'Book returned successfully.' AS message;
    ELSE
        SELECT 'Book is not loaned out by the user.' AS message;
    END IF;
END //

DELIMITER ;

select * from users;
select * from books;
select * from loaned_books;
-- LOAN A BOOK
CALL ReturnBook('ran_test@test.com',4);
CALL ReturnBook('ran_test@test.com',2);
CALL ReturnBook('ran_test@test.com',4);
CALL LoanBook('barbar11@rty.com@test.com',4); -- problem with loaning book: doesn't write to loaned_books table because of a constraint but book_stock_amount decreases.
CALL ReturnBook('barbar11@rty.com@test.com',4);
-- ------------------------------------------------------------

-- PROCDURE TO SHOW BOOKS LOANED BY SPECIFIC USER

DELIMITER //

CREATE PROCEDURE ShowUserLoanedBooks (
    IN user_email VARCHAR(255)
)
BEGIN
    -- Select all books loaned by the specified user
    SELECT * FROM loaned_books WHERE user_mail = user_email;
END //

DELIMITER ;

-- =============================== ADMIN PROCEDURES ===============================

-- PROCEDURE TO ADD BOOKS

DELIMITER //

CREATE PROCEDURE AddBook (
    IN new_book_name VARCHAR(255),
    IN new_author_name VARCHAR(255),
    IN new_genre_name VARCHAR(50),
    IN new_stock_amount INT
)
BEGIN
    DECLARE book_exists INT;
    
    -- Check if the book exists
    SELECT COUNT(*) INTO book_exists FROM books WHERE book_name = new_book_name AND author_name = new_author_name;
    
    -- If the book exists, update the stock amount
    IF book_exists > 0 THEN
        UPDATE books SET stock_amount = stock_amount + new_stock_amount WHERE book_name = new_book_name AND author_name = new_author_name;
        
    ELSE
        -- If the book doesn't exist, insert the new book
        INSERT INTO books (book_name, author_name, genre_name, stock_amount) VALUES (new_book_name, new_author_name, new_genre_name, new_stock_amount);
    END IF;
END //

DELIMITER ;

CALL AddBook('Book1', 'Authour1', 'Mystery', 57);
select * from books
-- ------------------------------------

-- PROCEDURE TO SHOW ALL LOAND BOOKS

DELIMITER //

CREATE PROCEDURE ShowLoanedBooks ()
BEGIN
    -- Select all unique loaned books
    SELECT DISTINCT book_id FROM loaned_books;
END //

DELIMITER ;

-- ----------------------------------------

-- PROCEDURE TO REMOVE USER

DELIMITER //

CREATE PROCEDURE RemoveUser (
    IN remove_user_email VARCHAR(255)
)
BEGIN
    DECLARE loaned_book_count INT;
    
    -- Check if the user has loaned books
    SELECT COUNT(*) INTO loaned_book_count FROM loaned_books WHERE user_mail = remove_user_email;
    
    IF loaned_book_count = 0 THEN
        -- Remove user
        DELETE FROM users WHERE email = remove_user_email;
        
        SELECT 'User removed successfully.' AS message;
    ELSE
        SELECT 'User has loaned books. Cannot remove user.' AS message;
    END IF;
END //

DELIMITER ;

-- ----------------------------------------
-- 
-- -- -------DEPENDS IF WE USE LOAN_LOG TABLE-------------------
-- 
-- -- DEPENDS IF WE USE LOAN_LOG TABLE
-- 
-- -- Trigger for inserting new loan logs
-- CREATE TRIGGER UpdateIsLoanedOnLoanLogInsert
-- ON loan_log
-- AFTER INSERT
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE books
--     SET is_loaned = 1
--     WHERE book_id IN (SELECT book_id FROM inserted);
-- END;
-- 
-- ------------------------------------------
-- 
-- -- DEPENDS IF WE USE LOAN_LOG TABLE
-- 
-- 
-- -- Trigger for updating loan logs
-- CREATE TRIGGER UpdateIsLoanedOnLoanLogUpdate
-- ON loan_log
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE books
--     SET is_loaned = CASE 
--                        WHEN i.is_returned = 1 THEN 0
--                        ELSE 1
--                    END
--     FROM inserted i
--     WHERE books.book_id = i.book_id;
-- END;
-- 
-- -----------------------------------------
