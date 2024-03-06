from configs.DBconnect import db

class User(db.Model):
    email = db.Column(db.String(255), primary_key=True)
    fullname = db.Column(db.String(255))
    password = db.Column(db.String(255))

    # Other model methods
