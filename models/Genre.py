from configs.DBconnect import db

class Genre(db.Model):
    genre_name=db.Column(db.String(50), primary_key=True)
    