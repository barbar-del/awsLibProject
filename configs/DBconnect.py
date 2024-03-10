# configs/DBconnect.py
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()
#init the database connection
def init_db(app):
    
    # bar sql
    #app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:1234567890@localhost/awspro'
    
    # ran sql
    app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:T9QF1X@localhost/library_aws'
    
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    db.init_app(app)
    
    
    # Call the SQL function 'LoginUser' with the email and password
def login_user(email, password):
    connection = db.engine.raw_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('LoginUser', [email, password, None, None, None])
        connection.commit()  # Make sure to commit the transaction
        cursor.execute("SELECT @_LoginUser_2, @_LoginUser_3, @_LoginUser_4")  # Fetch the OUT parameters of the 2 and 3 index
        login_status, error_message,admin_status = cursor.fetchone()
        return login_status, error_message, admin_status
    finally:
        cursor.close()
        connection.close()

# call the sql function 'SignupUser' with the email, name, and password
# return the status and error message from the SQL function
def SignupUser(email,name,password):
    connection = db.engine.raw_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('SignupUser', [email,name,password, None, None])
        connection.commit()  # Make sure to commit the transaction
        cursor.execute("SELECT @_SignupUser_3, @_SignupUser_4")  # Fetch the OUT parameters of the 2 and 3 index
        signUpStatus, error_message = cursor.fetchone()
        return signUpStatus, error_message
    finally:
        cursor.close()
        connection.close()
        
# call the sql function 'ShowAvailableBooks' 
# will show all the available books (count if 1 or more in the stock)
def show_available_books():
    from models.books import Books  # Import Books model here

    connection = db.engine.raw_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('ShowAvailableBooks', [])
        result = cursor.fetchall()
        available_books = []
        for book_data in result:
            book = Books.query.filter_by(book_id=book_data[0]).first()
            if book is None:
                # Create a new Books instance if it doesn't exist
                book = Books(book_id=book_data[0], book_name=book_data[1], book_author_name=book_data[2],
                             book_genre_name=book_data[3], book_stock_amount=book_data[4])
            available_books.append(book)
        return available_books
    finally:
        cursor.close()
        connection.close()

# call the sql function 'ShowUserLoanedBooks'. 
# return all the books that the user has loaned.
def ShowUserLoanedBooks(mail):
    from models.books import Books  # Import Books model here

    connection = db.engine.raw_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('ShowUserLoanedBooks', [mail])
        result = cursor.fetchall()
        available_books = []
        for book_data in result:
            book = Books.query.filter_by(book_id=book_data[0]).first()
            if book is None:
                # Create a new Books instance if it doesn't exist
                book = Books(book_id=book_data[0], book_name=book_data[1], book_author_name=book_data[2],
                                book_genre_name=book_data[3], book_stock_amount=book_data[4])
            available_books.append(book)
        return available_books
    finally:
        cursor.close()
        connection.close()


# function to loand a spesific book to a user
def LoanBook(email, book_id):
    connection = db.engine.raw_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('LoginUser', [email, book_id, None, None])
        connection.commit()  # Make sure to commit the transaction
        cursor.execute("SELECT @_LoanBook_2, @_LoanBook_3")  # Fetch the OUT parameters of the 2 and 3 index
        login_status, LoanBook_message = cursor.fetchone()
        return login_status, LoanBook_message
    finally:
        cursor.close()
        connection.close()
        
        
# function to return a spesific book to the library
def ReturnBook(email, book_id):
    connection = db.engine.raw_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('LoginUser', [email, book_id, None, None])
        connection.commit()  # Make sure to commit the transaction
        cursor.execute("SELECT @_LoanBook_2, @_LoanBook_3")  # Fetch the OUT parameters of the 2 and 3 index
        ReturnBook_status, ReturnBook_message = cursor.fetchone()
        return ReturnBook_status, ReturnBook_message
    finally:
        cursor.close()
        connection.close()
        
# function to remove a user from the database
#only the admin can do this    
def RemoveUser(email):
    connection = db.engine.raw_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('LoginUser', [email, None, None])
        connection.commit()  # Make sure to commit the transaction
        cursor.execute("SELECT @_RemoveUser_1, @_RemoveUser_2")  # Fetch the OUT parameters of the 2 and 3 index
        RemoveUser_status, RemoveUser_message = cursor.fetchone()
        return RemoveUser_status, RemoveUser_message
    finally:
        cursor.close()
        connection.close()


def getGenreNames():
  from models.Genre import Genre  # Import Genre model here
  connection = db.engine.raw_connection()
  try:
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM genre")
    result = cursor.fetchall()
    genres = []  # List comprehension to extract genre names
    for genre_name in result:
        gen = Genre.query.filter_by(genre_name=genre_name[0]).first()
        if gen is None:
            gen = Genre(genre_name=genre_name[0])
        genres.append(gen)
    return genres
  finally:
    cursor.close()
    connection.close()

        
        
        
def AddBook(new_book_name,new_author_name,new_genre_name,new_stock_amount):
    connection = db.engine.raw_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('AddBook', [new_book_name,new_author_name,new_genre_name,new_stock_amount, None, None])
        connection.commit()  # Make sure to commit the transaction
        cursor.execute("SELECT @_AddBook_4, @_AddBook_5")  # Fetch the OUT parameters of the 2 and 3 index
        signUpStatus, error_message = cursor.fetchone()
        return signUpStatus, error_message
    finally:
        cursor.close()
        connection.close()
        

def getGenreNames():
  from models.Genre import Genre  # Import Genre model here
  connection = db.engine.raw_connection()
  try:
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM genre")
    result = cursor.fetchall()
    genres = []  # List comprehension to extract genre names
    for genre_name in result:
        gen = Genre.query.filter_by(genre_name=genre_name[0]).first()
        if gen is None:
            gen = Genre(genre_name=genre_name[0])
        genres.append(gen)
    return genres
  finally:
    cursor.close()
    connection.close()