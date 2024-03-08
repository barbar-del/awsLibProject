from configs.DBconnect import db

class Users(db.Model):
    user_email = db.Column(db.String(255), primary_key=True)
    user_full_name = db.Column(db.String(255))
    user_password = db.Column(db.String(255))

    # Other model methods
