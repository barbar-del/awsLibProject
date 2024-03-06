from flask import Flask, render_template
from configs.DBconnect import init_db
from models.user import User

app = Flask(__name__)

# Configure database connection
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:1234567890@127.0.0.1:3306/awspro'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False


# Initialize the database connection
init_db(app)

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