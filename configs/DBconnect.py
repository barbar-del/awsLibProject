# configs/DBconnect.py
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()
#init the database connection
def init_db(app):
    app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:1234567890@localhost/awspro'
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
