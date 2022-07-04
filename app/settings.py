# This file contains configuration options for the application.
# A description of each configuration setting and their defaults
# can be found here:
#
# * https://flask.palletsprojects.com/en/2.1.x/config/
# * https://flask-sqlalchemy.palletsprojects.com/en/master/config/
#
from environs import Env

env = Env()
env.read_env()

ENV = env.str("FLASK_ENV", default="production")
DEBUG = ENV == "development"
TESTING = ENV != "production"
#SQLALCHEMY_DATABASE_URI = 'sqlite:///' + os.path.join(BASE_DIR, 'app.db')
DB_TYPE = env.str("DB_TYPE", default="") # Example: sqlite, postgres
DB_HOST = env.str("DB_HOST", default="")
DB_PORT = env.str("DB_PORT", default="")
DB_USER = env.str("DB_USER", default="")
DB_PASSWORD = env.str("DB_PASSWORD", default="")
DB_NAME = env.str("DB_NAME", default="")

connection_str = "{}://{}:{}@{}:{}/{}".format(DB_TYPE, DB_USER, DB_PASSWORD,
        DB_HOST, DB_PORT, DB_NAME)

SQLALCHEMY_DATABASE_URI = env.str("DATABASE_URL", default=connection_str)
SQLALCHEMY_TRACK_MODIFICATIONS = False
