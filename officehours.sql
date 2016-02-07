-- Users known by the application.  "Nickname" is a misnomer.  Nom de
-- user was too pretentious.  It's how the customer wishes to be
↓-- addressed, but "address" would be confusing.

CREATE TABLE users (
       id SERIAL,
       email CITEX UNIQUE NOT NULL,
       nickname TEXT NOT NULL
);

-- Users who are currently staff

CREATE TABLE staff (
       staff_id INTEGER UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
       active BOOLEAN
);

-- Users who are currently clients

CREATE TABLE clients (
       client_id INTEGER UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
       active BOOLEAN
);

-- This is interesting, because we've basically created a M:1
-- relationship of staff and clients, but a 1:1 relationship of
-- clients to staff.  That satisfies the current assignment, mostly.
-- An appointment can then be made my a client, and there's only one
-- staff person who it could apply to, so the query is straightforward
-- then.
-- 
-- To extend this into a M:M relationship, you'd have to remove the
-- "UNIQUE" setting from the staff_id field and use the
-- relationship.id field instead for appointments. 

CREATE TABLE relationship (
       id SERIAL,
       client_id INTEGER NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
       staff_id INTEGER UNIQUE NOT NULL REFERENCES staff(staff_id) ON DELETE CASCADE
);
       
