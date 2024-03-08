from configs.DBconnect import db

class Books(db.Model):
    book_id=db.Column(db.Integer, primary_key=True)
    book_name=db.Column(db.String(255))
    book_author_name=db.Column(db.String(255))
    book_genre_name=db.Column(db.String(50))
    book_stock_amount=db.Column(db.Integer)
    
