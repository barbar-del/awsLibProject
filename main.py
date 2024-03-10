from flask import Flask, redirect, render_template, request, url_for
from configs.DBconnect import ShowUserLoanedBooks, init_db, login_user, SignupUser, show_available_books, getGenreNames
from models.user import Users
from models.books import Books
from models.Genre import Genre

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



####################################### pages withouth functions############################################



@app.route('/rent/<email>')
def rentBook(email):
    available_books = show_available_books()
    genres = getGenreNames()
    print(email)

    print(available_books)
    print(type(genres))
    print(genres)
    return render_template('BookRent.html', books=available_books, email=email, genres=genres)


@app.route('/return/<email>')
def returnbook(email):
    rentedBooks = ShowUserLoanedBooks(email)
    print(email)
    return render_template('returnBook.html', books=rentedBooks)

@app.route('/lib/<email>')
def lib(email):
    return render_template('lib.html',email=email)

#######################################auth page############################################

@app.route('/')
def auth():
    return render_template('auth.html')


#handle the login form submission, and redirect to the user profile in case of success
# or to 
@app.route('/login', methods=['POST'])
def login():
    email = request.form['logemail']
    password = request.form['logpass']
    login_status, error_message, admin_status = login_user(email, password)
    if login_status:
        # check admin or user. if admin redirect to admin page
        if admin_status:
            return redirect(url_for('admin',email=email))
        
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
        # no need to check it's and admin. only a user can sign up admins are added manually in sql
        return redirect(url_for('lib',email=email))
    else:
        return render_template('auth.html', error=error_message)


#######################################admin page############################################

@app.route('/admin/<email>')
def admin(email):
    return render_template('admin.html',email=email)




@app.route('/index')
def index():
    ganres = getGenreNames()
    users = Users.query.all()

    print(ganres)
    return render_template('index.html', ganres=ganres, users=users)

@app.route('/call_function', methods=['POST'])
def call_function():
    func_name = request.form['func_name']
    arg = request.form['arg']
    book_name = request.form['book_name']
    author_name = request.form['author_name']
    genre = request.form['genre']
    amount = request.form['amount']

    if func_name == 'newBook':
        print('function1')  # her i want to add new book
    elif func_name == 'function2':
        print('function2')  # here i want to delete user
    # elif func_name == 'function3':
    #     print('function3')  #here i want to 
    # elif func_name == 'function4':
    #     print('function4')

    return f'{func_name} called with book: {book_name}, author: {author_name}, genre: {genre}, amount: {amount}, arg: {arg}'







# flask --app main run --debug
if __name__ == '__main__':
    app.run(debug=True)