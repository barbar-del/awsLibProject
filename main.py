from flask import Flask, redirect, render_template, request, url_for, flash
from configs.DBconnect import AddBook, RemoveUser, ShowUserLoanedBooks, init_db, login_user, SignupUser, show_available_books, getGenreNames, searchBook, LoanBook,getNotAdmins, ReturnBook
from models.user import Users
from models.books import Books
from models.Genre import Genre

app = Flask(__name__)
app.secret_key = 'secret'
# Configure database connection



# Initialize the database connection
init_db(app)

# Define your routes below

#for debugging, remove later
@app.route('/users')
def show_users():
    users = Users.query.all()
    return render_template('users.html', users=users)



####################################### pages without functions ############################################


# activate search button, loan button
@app.route('/rent/<email>', methods=['GET', 'POST'])
def rentBook(email):
    available_books = show_available_books()
    genres = getGenreNames()

    if request.method == 'POST':
        action = request.form.get('action')
        if action == 'borrow':
            book_ids = request.form.getlist('book_ids')
            if(len(book_ids) == 0):
                flash(f'Please select a book to loan.', 'error')
                return render_template('BookRent.html', books=show_available_books(), email=email, genres=genres)
            for book_id in book_ids:
                status, message = LoanBook(email, book_id)
            if status:
                flash(f'Book loaned successfully.', 'success')
            else:
                flash(f'Error: {message}', 'error')
                
        else:
            book_name = request.form.get('bookName', '').strip()
            author_name = request.form.get('bookAuthor', '').strip()
            genre = request.form.get('genre', '')
            searched_books = searchBook(book_name, author_name, genre)
            return render_template('BookRent.html', books=searched_books, email=email, genres=genres)

    print(email)
    return render_template('BookRent.html', books=show_available_books(), email=email, genres=genres)


# activate return button
@app.route('/return/<email>', methods=['GET','POST'])
def returnbook(email):
    rentedBooks = ShowUserLoanedBooks(email)
    if request.method == 'POST':
        action = request.form.get('action')
        if action == 'return':
            book_ids = request.form.getlist('book_ids')
            if(len(book_ids) == 0):
                flash(f'Please select a book to return.', 'error')
                return render_template('returnBook.html', email = email, books=ShowUserLoanedBooks(email))
            for book_id in book_ids:
                status, message = ReturnBook(email, book_id)
            if status:
                flash(f'Book returned successfully.', 'success')
            else:
                flash(f'Error: {message}', 'error')

    print(email)
    return render_template('returnBook.html', email = email, books=ShowUserLoanedBooks(email))

@app.route('/lib/<email>')
def lib(email):
    return render_template('lib.html',email=email)

####################################### auth page ############################################

@app.route('/')
def auth(error_message=None):
    error_message = request.args.get('error_message')
    print("in auth the error is ")
    print(error_message)
    return render_template('auth.html', error_message=error_message)

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
        return redirect(url_for('auth', error_message=error_message))


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
        print("not all filesd are filled in signup t")
        return redirect(url_for('auth', error_message="all fields are requierd"))
    if password != repassword:
        print("passwords dose not match")
        return redirect(url_for('auth', error_message="Password and re-password do not match"))

    login_status,error_message = SignupUser(email,name, password)
    if login_status:
        # no need to check it's and admin. only a user can sign up admins are added manually in sql
        print("signup succses")
        return redirect(url_for('lib',email=email))
    else:
        return redirect(url_for('auth', error_message=error_message))


####################################### admin page ############################################



@app.route('/admin')
def admin(email=None,error_message=None):
    genres = getGenreNames()
    users = getNotAdmins()
    error_message = request.args.get('error_message')
    email=request.args.get('email')
    print(error_message)
    return render_template('admin.html', genres=genres, users=users, email=email, error_message=error_message)


@app.route('/call_function', methods=['POST'])
def call_function():
    func_name = request.form['func_name']
    arg = request.form.get('arg', '')  # Make arg optional
    book_name = request.form.get('book_name', '')
    author_name = request.form.get('author_name', '')
    genre = request.form.get('genre', '')
    amount = request.form.get('amount', '')
    delete_user = request.form.get('user_email', '')

    if func_name == 'newBook':
        print('function1')  # here i want to add new book
        # CHECK THAT ALL THE FIELDS ARE FILLED
        if not all([book_name, author_name, genre, amount]):
            print('all fields are required\n')
            return redirect(url_for('admin', status=False, error_message="All fields are required"))
        # CHECK THAT THE AMOUNT IS A NUMBER AND GREATER THAN 0
        if not is_number(amount):
            print('amount is not a number\n')
            return redirect(url_for('admin', error_message="Amount should be 1 or more"))
        if int(amount) >= 1:
            status, error_message = AddBook(book_name, author_name, genre, amount)
            print(status, error_message)
            print('book added\n')
            return redirect(url_for('admin', error_message=error_message))
        print("was not able to add book\n")
        return redirect(url_for('admin', error_message="Something went wrong"))

    elif func_name == 'deleteUser':
        print('function2')  # here i want to delete user
        if delete_user:
            status, error_message = RemoveUser(delete_user)
            return redirect(url_for('admin', status=status, error_message=error_message))
        else:
            return redirect(url_for('admin', error_message="Please select a user to delete"))

    # elif func_name == 'function3':
    #     print('function3')  # here i want to
    # elif func_name == 'function4':
    #     print('function4')

    return f'{func_name} called with book: {book_name}, author: {author_name}, genre: {genre}, amount: {amount}, arg: {arg}'

def is_number(s):
    try:
        int(s)
        return True
    except ValueError:
        return False



# flask --app main run --debug
if __name__ == '__main__':
    app.run(debug=True)