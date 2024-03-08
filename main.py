from flask import Flask, redirect, render_template, request
from configs.DBconnect import init_db, login_user, SignupUser
from models.user import Users
from models.books import Books

app = Flask(__name__)

# Configure database connection



# Initialize the database connection
init_db(app)

# Define your routes below

@app.route('/users')
def show_users():
    users = Users.query.all()
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
    books = Books.query.all()
    return render_template('BookRent.html', books=books)

@app.route('/user/<email>')
def profile(email):
    return f'{email}\'s profile'


#handle the login form submission, and redirect to the user profile in case of success
# or to 
@app.route('/login', methods=['POST'])
def login():
    email = request.form['logemail']
    password = request.form['logpass']
    login_status, error_message = login_user(email, password)
    if login_status:
        return redirect('/user/' + email)
    else:
        return render_template('auth.html', error=error_message)


#handle the login form submission, and redirect to the user profile in case of success
# or to 
@app.route('/signup', methods=['POST'])
def signup():
    email :str = request.form['signEmail']
    password :str = request.form['signPass']
    repassword :str = request.form['signRePass']
    name :str = request.form['signName']
    print(email, password, repassword, name)
    if len(email) == 0 or len(password) == 0 or len(repassword) == 0 or len(name) == 0:
        return render_template('auth.html', error="All fields are required")
    if password != repassword:
        return render_template('auth.html', error="Password and re-password do not match")
    login_status, error_message = SignupUser(email,name, password)
    if login_status:
        return redirect('/user/' + email)
    else:
        return render_template('auth.html', error=error_message)





# flask --app main run --debug
if __name__ == '__main__':
    app.run(debug=True)