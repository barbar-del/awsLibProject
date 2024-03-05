# models/user.py
from configs.DBconnect import db

class User(db.Model):
    __tablename__ = 'users'
    email = db.Column(db.String(255), primary_key=True)
    fullname = db.Column(db.String(255))
    password = db.Column(db.String(255))

    def __repr__(self):
        return f'<User {self.email}>'