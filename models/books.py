from configs.DBconnect import db

class Books(db.Model):
    book_id=db.Column(db.Integer, primary_key=True)
    book_name=db.Column(db.String(255))
    author_name=db.Column(db.String(255))
    genre_name=db.Column(db.String(50))
    stock_amount=db.Column(db.Integer)
    
