# configs/DBconnect.py
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()
#init the database connection
def init_db(app):
    
    # bar sql
    app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:1234567890@localhost/awspro'
    
    # ran sql
    #app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:T9QF1X@localhost/library_aws'
    
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    db.init_app(app)
    
    
    # Call the SQL function 'LoginUser' with the email and password
def login_user(email, password):
    connection = db.engine.raw_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('LoginUser', [email, password, None, None])
        connection.commit()  # Make sure to commit the transaction
        cursor.execute("SELECT @_LoginUser_2, @_LoginUser_3")  # Fetch the OUT parameters of the 2 and 3 index
        login_status, error_message = cursor.fetchone()
        return login_status, error_message
    finally:
        cursor.close()
        connection.close()

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
