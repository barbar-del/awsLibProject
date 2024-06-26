drop table IF EXISTS loaned_books;
drop table IF EXISTS users;
drop table IF EXISTS books;
drop table IF EXISTS genre;

drop procedure if exists AddBook;
drop procedure if exists LoanBook;
drop procedure if exists LoginUser;
drop procedure if exists RemoveUser;
drop procedure if exists ResetPassword;
drop procedure if exists ReturnBook;
drop procedure if exists ShowAvailableBooks;
drop procedure if exists ShowLoanedBooks;
drop procedure if exists ShowUserLoanedBooks;
drop procedure if exists SearchBook;
drop procedure if exists SignupUser;

-- =============================================================

CREATE TABLE users (
  user_email VARCHAR(255) PRIMARY KEY,
  user_full_name varchar(255) NOT NULL,
  user_password VARCHAR(255) NOT NULL,
  is_admin boolean default FALSE,
  CHECK (user_email LIKE '_%@_%._%')
  );
-- ------------ create 2 admins ------------------------
insert into users values
('ran_admin@library.com', 'ran ran', '111', TRUE),
('bar_admin@library.com', 'bar bar', '111', TRUE);
-- ------------ END create 2 admins ------------------------

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

-- =========================== end create tables ==================================

-- =========================== insert genres ======================================

INSERT INTO genre (genre_name) VALUES ('Fiction');
INSERT INTO genre (genre_name) VALUES ('Non-Fiction');
INSERT INTO genre (genre_name) VALUES ('Mystery');
INSERT INTO genre (genre_name) VALUES ('Sci-Fi');
INSERT INTO genre (genre_name) VALUES ('Fantasy');

-- =========================== insert users ======================================
insert into users (user_email, user_full_name, user_password) values
('barbar11@rty.com', 'bar yadgar1', '111'),
('barbar12@rty.com', 'bar yadgar2', '222'),
('barbar13@rty.com', 'bar yadgar3', '333'),
('barbar14@rty.com', 'bar yadgar4', '444');

-- =========================== insert books ======================================

insert into books (book_name, book_author_name, book_genre_name, book_stock_amount) values
('alibaba','barbur','Mystery',5),
('minime','barbur2','Fantasy',2),
('alibaba','barbur2','Fantasy',6),
('sodastream','barbur','Fantasy',1);

-- =========================== end inserts ===================================

-- =========================== User Management ==================================

-- PROCDURE TO LOG IN USER

DELIMITER //

CREATE PROCEDURE LoginUser (
    IN login_email VARCHAR(255),
    IN login_password VARCHAR(255),
    OUT login_status BOOLEAN,
    OUT login_status_message VARCHAR(255),
    OUT is_admin_login BOOLEAN
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
            -- check if user is admin
			SELECT is_admin into is_admin_login FROM users WHERE user_email = login_email;
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
    
    -- Check if the email matches the desired format
    
    IF signup_email NOT LIKE '_%@_%._%'
    THEN
		SET signup_status = FALSE;
		SET signup_status_message = 'Invalid email format';
    ELSEIF new_user_name = ''
	THEN
		SET signup_status = FALSE;
        SET signup_status_message = 'Name cannot be empty';
	ELSEIF signup_password = ''
	THEN
		SET signup_status = FALSE;
        SET signup_status_message = 'Password cannot be empty';
    ELSE
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
    END IF;
END //

DELIMITER ;

-- ----------------------------------------------------------

-- PROCEDURE TO RESET USER PASSWORD

DELIMITER //

CREATE PROCEDURE ResetPassword (
    IN reset_user_email VARCHAR(255),
    IN new_password VARCHAR(255),
    OUT reset_password_status BOOLEAN,
    OUT reset_password_message VARCHAR(255)
    
)
BEGIN
    DECLARE user_exists INT;
    
    -- Check if the user exists
    SELECT COUNT(*) INTO user_exists FROM users WHERE user_email = reset_user_email;
    
    IF user_exists > 0 THEN
		IF new_password = ''
        THEN
			SET reset_password_status = FALSE;
            SET reset_password_message = 'Password cannot be empty';
        
		ELSE
			-- Update user's password
			UPDATE users SET user_password = new_password WHERE user_email = reset_user_email;
			SET reset_password_status = FALSE;
			SET reset_password_message = 'Password reset successfully.' ;
        END IF;
    ELSE
        SET reset_password_status = FALSE;
        SET reset_password_message = 'User does not exist.' ;
    END IF;
END //
-- ======================================================== 

-- ============================= BOOKS MANAGEMENT =============================

-- SHOW ALL AVAILABLE BOOKS

DELIMITER //

CREATE PROCEDURE ShowAvailableBooks()
BEGIN
    -- Select all available books
    SELECT * FROM books WHERE book_stock_amount > 0;
END //

DELIMITER ;

-- ------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE LoanBook (
    IN current_user_email VARCHAR(255),
    IN current_book_id INT,
	OUT LoanBook_status BOOLEAN,
    OUT LoanBook_message VARCHAR(255)
)
BEGIN
    DECLARE current_stock INT;
    DECLARE user_has_book INT;
    
    -- Check if user already has a copy of the book
    SELECT COUNT(*) INTO user_has_book FROM loaned_books WHERE loan_user_mail = current_user_email AND loaned_book_id = current_book_id;
    
    IF user_has_book > 0 THEN
		SET LoanBook_status = FALSE;
        SET LoanBook_message = 'User already has a copy of this book.' ;
    ELSE
        -- Check current stock amount
        SELECT book_stock_amount INTO current_stock FROM books WHERE book_id = current_book_id;
        
        -- Check if stock is available
        IF current_stock > 0 THEN
            -- Decrease stock amount by 1
            UPDATE books SET book_stock_amount = book_stock_amount - 1 WHERE book_id = current_book_id;
            -- Add entry to loaned_books table
            INSERT INTO loaned_books (loan_user_mail, loaned_book_id) VALUES (current_user_email, current_book_id);
            SET LoanBook_status = TRUE;
			SET LoanBook_message = 'Book loaned successfully.';
        ELSE
            SET LoanBook_status = FALSE;
			SET LoanBook_message = 'Book not available for loan.';
        END IF;
    END IF;
END //

-- ------------------------------------------------------------

-- RETURN A BOOK

DELIMITER //

CREATE PROCEDURE ReturnBook (
    IN return_user_email VARCHAR(255),
    IN return_book_id INT,
	OUT ReturnBook_status BOOLEAN,
    OUT ReturnBook_message VARCHAR(255)
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
		SET ReturnBook_status = TRUE;
		SET ReturnBook_message = 'Book returned successfully';
    ELSE
        SET ReturnBook_status = TRUE;
		SET ReturnBook_message = 'Book is not loaned out by the user.';
    END IF;
END //

DELIMITER ;
-- -----------------------------------

-- PROCDURE TO SHOW BOOKS LOANED BY SPECIFIC USER
DELIMITER //

CREATE PROCEDURE ShowUserLoanedBooks (
    IN show_user_email_loaned VARCHAR(255)
)
BEGIN
    -- Select all books loaned by the specified user
	SELECT lb.loan_user_mail, lb.loaned_book_id, b.book_name
    FROM loaned_books lb
    INNER JOIN books b ON lb.loaned_book_id = b.book_id
    WHERE lb.loan_user_mail = show_user_email_loaned;
END //

DELIMITER ;

-- =============================== ADMIN PROCEDURES ===============================

-- PROCEDURE TO ADD BOOKS

DELIMITER //

CREATE PROCEDURE AddBook (
    IN new_book_name VARCHAR(255),
    IN new_author_name VARCHAR(255),
    IN new_genre_name VARCHAR(50),
    IN new_stock_amount INT,
	OUT AddBook_status BOOLEAN,
    OUT AddBook_message VARCHAR(255)
)
BEGIN
    DECLARE book_exists INT;
    
    IF new_book_name = ''
    THEN
		SET AddBook_status = FALSE;
		SET AddBook_message = 'Book name is empty';
    ELSEIF new_author_name = ''
	THEN
		SET AddBook_status = FALSE;
		SET AddBook_message = 'Book Author is empty';
    ELSEIF new_stock_amount < 1 THEN
		SET AddBook_status = FALSE;
		SET AddBook_message = 'Book amount must be > 0';
    ELSE
		-- Check if the book exists
		SELECT COUNT(*) INTO book_exists FROM books WHERE book_name = new_book_name AND book_author_name = new_author_name;
		-- If the book exists, update the stock amount
		IF book_exists > 0 THEN
			UPDATE books SET book_stock_amount = book_stock_amount + new_stock_amount WHERE book_name = new_book_name AND book_author_name = new_author_name;
			SET AddBook_status = TRUE;
			SET AddBook_message = 'Book stock amount updated.';
		ELSE
			-- If the book doesn't exist, insert the new book
			INSERT INTO books (book_name, book_author_name, book_genre_name, book_stock_amount) VALUES (new_book_name, new_author_name, new_genre_name, new_stock_amount);
			SET AddBook_status = TRUE;
			SET AddBook_message = 'Book added to library.';
		END IF;
	END IF;
END //

DELIMITER ;

-- ------------------------------------

-- PROCEDURE TO SHOW ALL LOAND BOOKS

DELIMITER //

CREATE PROCEDURE ShowLoanedBooks ()
BEGIN
    -- Select all unique loaned books
    SELECT DISTINCT loaned_book_id FROM loaned_books;
END //

DELIMITER ;

-- ----------------------------------------

-- PROCEDURE TO REMOVE USER

DELIMITER //

CREATE PROCEDURE RemoveUser (
    IN remove_user_email VARCHAR(255),
	OUT RemoveUser_status BOOLEAN,
    OUT RemoveUser_message VARCHAR(255)
)
BEGIN
    DECLARE user_exists INT;
    DECLARE loaned_book_count INT;
    
    -- Check if the user exists
    SELECT COUNT(*) INTO user_exists FROM users WHERE user_email = remove_user_email;
    
    IF user_exists > 0 THEN
        -- Check if the user has loaned books
        SELECT COUNT(*) INTO loaned_book_count FROM loaned_books WHERE loan_user_mail = remove_user_email;
        
        IF loaned_book_count = 0 THEN
            -- Remove user
            DELETE FROM users WHERE user_email = remove_user_email;
            SET RemoveUser_status = TRUE;
			SET RemoveUser_message = 'User removed successfully.';
        ELSE
            SET RemoveUser_status = FALSE;
			SET RemoveUser_message = 'User has loaned books. Cannot remove user.';
        END IF;
    ELSE
        SET RemoveUser_status = FALSE;
		SET RemoveUser_message = 'User does not exist.';
    END IF;
END //

DELIMITER ;

-- ----------------------------------------

-- Search Books

DELIMITER //

CREATE PROCEDURE SearchBook (
    IN search_book_name VARCHAR(255),
    IN search_book_author VARCHAR(255),
    IN search_book_genre VARCHAR(255)
)
BEGIN
	SELECT distinct book_id, book_name, book_author_name, book_genre_name
    FROM books
    WHERE ( (book_name LIKE CONCAT('%', search_book_name, '%') OR search_book_name IS NULL)
			AND (book_author_name LIKE CONCAT('%', search_book_author, '%') OR search_book_author IS NULL)
            AND (book_genre_name LIKE CONCAT('%', search_book_genre, '%') OR search_book_genre IS NULL));
END //

DELIMITER ;
