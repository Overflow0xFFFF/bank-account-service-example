from app.extensions import db

class AccountModel(db.Model):
    __tablename__ = 'accounts'
    name = db.Column(db.String(32), nullable=False, primary_key=True)
    balance = db.Column(db.Float(precision=2), nullable=False)

    def __init__(self, name, balance):
        self.name = name
        self.balance = balance
