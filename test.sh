#!/bin/sh

SERVER="172.27.0.3:3000"

http -j POST $SERVER/account/ name="Savings"
http -j GET $SERVER/account/Savings

http -j POST $SERVER/account/Savings/deposit amount="3.41"
http -j GET $SERVER/account/Savings

http -j POST $SERVER/account/Savings/withdraw amount="1.38"
http -j GET $SERVER/account/Savings

