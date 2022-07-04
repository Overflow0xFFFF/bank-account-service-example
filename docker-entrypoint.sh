#!/bin/sh
#
# References:
# * https://testdriven.io/blog/dockerizing-flask-with-postgres-gunicorn-and-nginx/
#

if [ "$DB_TYPE" = "postgres" ]
then
    echo "Waiting for postgres..."

    while ! nc -z "$DB_HOST" "$DB_PORT"; do
      sleep 1
    done

    echo "PostgreSQL started."
fi

/venv/bin/pdm run flask db upgrade
/venv/bin/pdm run flask run --port=3000 --host=0.0.0.0

exec "$@"

