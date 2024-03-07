from configs.DBconnect import db

class Users(db.Model):
    email = db.Column(db.String(255), primary_key=True)
    full_name = db.Column(db.String(255))
    password = db.Column(db.String(255))

    # Other model methods
