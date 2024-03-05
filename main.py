from flask import Flask, render_template
from configs.DBconnect import db
from models.user import User

app = Flask(__name__)

# Configure database connection
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://admin:1234567890@librarydb.cbukmucwgnnr.us-east-1.rds.amazonaws.com:3306/awsLibrary'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False


# Initialize the database connection
db.init_app(app)

# Define your routes below

@app.route('/users')
def show_users():
    users = User.query.all()
    return render_template('users.html', users=users)

@app.route('/1')
def home():
    return render_template('home.html')

@app.route('/auth')
def auth():
    return render_template('auth.html')

@app.route('/lib')
def lib():
    return render_template('lib.html')

@app.route('/rent a book')
def book_rent():
    return render_template('BookRent.html')

# flask --app main run --debug
if __name__ == '__main__':
    app.run(debug=True)