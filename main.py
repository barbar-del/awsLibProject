from flask import Flask, redirect, render_template, request, url_for
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



#registration from, latter will be change to  a path of '/' so it will be the default page
@app.route('/')
def auth():
    return render_template('auth.html')




@app.route('/rent/<email>')
def rentBook(email):
    available_books = show_available_books()
    print(email)
    return render_template('BookRent.html', books=available_books, email=email)


@app.route('/return/<email>')
def returnbook(email):
    rentedBooks = ShowUserLoanedBooks(email)
    print(email)
    return render_template('returnBook.html', books=rentedBooks)

@app.route('/lib/<email>')
def lib(email):
    return render_template('lib.html',email=email)


#handle the login form submission, and redirect to the user profile in case of success
# or to 
@app.route('/login', methods=['POST'])
def login():
    email = request.form['logemail']
    password = request.form['logpass']
    login_status, error_message = login_user(email, password)
    if login_status:
        return redirect(url_for('lib',email=email))
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
        return redirect(url_for('lib',email=email))
    else:
        return render_template('auth.html', error=error_message)





# flask --app main run --debug
if __name__ == '__main__':
    app.run(debug=True)