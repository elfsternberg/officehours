# officehours

A small experiment with Flask/Hy/Postgres.  Doesn't do much yet.

## Initialization

Start with initializing the virtual environment and Postgres

    \# From the project directory:
    $ virtualenv venv
    $ . ./venv/bin/activate
    $ pip install hy psycopg2 flask
    $ sudo -u postgres psql postgres
    \> CREATE DATABASE officehours;
    \> CREATE USER officehours;
    \> ALTER USER officehours WITH UNENCRYPTED PASSWORD '<password>';
    \> ALTER USER officehours LOGIN;
    \> GRANT ALL PRIVILEGES ON DATABASE officehours TO officehours;
    \> \\CONNECT officehours;
    \> CREATE EXTENSION citext; 
    \> CREATE EXTENSION btree_gist; 
    \> CREATE EXTENSION plv8; 
    \> ^d
    
Current functionality is demonstrated with:

$ psql -h localhost -U officehours -d officehours -f officehours.sql
$ hy play.hy
