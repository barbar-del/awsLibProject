libraryDB master username: admin 	master pasword: 1234567890  endpoint: librarydb.cbukmucwgnnr.us-east-1.rds.amazonaws.com

app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://admin:1234567890@librarydb.cbukmucwgnnr.us-east-1.rds.amazonaws.com:3306/awsLibrary'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
