# Re-learning how to install Postgres (*Sigh)
## WITH Postgres 9.4

CREATE DATABASE officehours;
CREATE USER officehours;
ALTER USER officehours WITH UNENCRYPTED PASSWORD '<password>';
ALTER USER officehours LOGIN;
GRANT ALL PRIVILEGES ON DATABASE officehours TO officehours;

-- Been a while since I used Postgres.  I'd forgotten that Postgres
-- thinks in terms of privileged connections.  It makes sense, certainly
-- better than MySQL.
\CONNECT officehours;

-- Enable case-insensitive matches on some text columns, good for email
CREATE EXTENSION citext; 
CREATE EXTENSION btree_gist; 
CREATE EXTENSION plv8; 
be


# What can I do?

1) Add users and make them clients.
2) Add users and make them staff.
3) Allocate a block of time as "office hours"
4) Allocate a block of time as an "appointment."

## Progress:

## Retrieve "this week" with Flask.
