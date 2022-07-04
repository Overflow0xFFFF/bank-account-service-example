from flask import Blueprint, request, abort
from app.extensions import db
from .models import AccountModel

blueprint = Blueprint('accounts', __name__, url_prefix='/account')

@blueprint.route('/', methods=['GET'])
def list():
    return "<p>Hello, world!</p>"


@blueprint.route('/<string:name>', methods=['GET'])
def show(name):
    """Show the balance of the account."""

    account = AccountModel.query.filter_by(name = name).first()

    if not account:
        return ({}, http.client.NOT_FOUND)

    return {
        "name": account.name,
        "balance": account.balance,
        "success": True
    }


@blueprint.route('/', methods=['POST'])
def create():
    """Create a new account."""
    json = request.json
    name = json['name']
    balance = 0.0

    print("Request: {}".format(name))

    if not name:
        return ({}, http.client.NOT_FOUND)

    account = AccountModel(name, balance)

    db.session.add(account)
    db.session.commit()

    return {
        "success": True
    }


@blueprint.route('/<string:name>/deposit', methods=['POST'])
def deposit(name):
    """Deposit an amount into an existing account."""
    json = request.json
    amount = float(json['amount'])
    account = AccountModel.query.filter_by(name = name).first()

    if not account:
        return ({}, http.client.NOT_FOUND)

    postdeposit_balance = account.balance + amount
    account.balance = postdeposit_balance

    db.session.commit()

    return {
        "success": True
    }


@blueprint.route('/<string:name>/withdraw', methods=['POST'])
def withdraw(name):
    """Withdraw an amount from an existing account."""
    json = request.json
    amount = float(json['amount'])
    account = AccountModel.query.filter_by(name = name).first()

    if not account:
        return ({}, http.client.NOT_FOUND)

    postwithdrawal_balance = account.balance - amount
    account.balance = postwithdrawal_balance

    db.session.commit()

    return {
        "success": True
    }

