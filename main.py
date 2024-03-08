from flask import Flask, redirect, render_template, request
from configs.DBconnect import ShowUserLoanedBooks, init_db, login_user, SignupUser, show_available_books
from models.user import Users
from models.books import Books

app = Flask(__name__)

# Configure database connection



# Initialize the database connection
init_db(app)

# Define your routes below

#for debughing, remove later
@app.route('/users')
def show_users():
    users = Users.query.all()
    return render_template('users.html', users=users)


#for debughing, remove later
@app.route('/')
def home():
    return render_template('home.html')

#registration from, latter will be change to  a path of '/' so it will be the default page
@app.route('/auth')
def auth():
    return render_template('auth.html')


@app.route('/lib')
def lib():
    return render_template('lib.html')


@app.route('/rent/<mail>')
def book_rent(mail):
    available_books = show_available_books()
    print(mail)
    return render_template('BookRent.html', books=available_books)


@app.route('/return/<mail>')
def returnbook(mail):
    rentedBooks = ShowUserLoanedBooks(mail)
    print(mail)
    return render_template('returnBook.html', books=rentedBooks)



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