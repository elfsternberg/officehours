-- Users known by the application.  "Nickname" is a misnomer.  Nom de
-- user was too pretentious.  It's how the customer wishes to be
-- addressed, but "address" would be confusing.

-- requires extensions citex, btree_gist

--DROP VIEW IF EXISTS staff_members;
--DROP VIEW IF EXISTS client_members;
--DROP VIEW IF EXISTS usernames;

DROP VIEW IF EXISTS staff_appointments;
DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS officehours;
DROP VIEW IF EXISTS staff_client_relationships;
DROP TABLE IF EXISTS relationship;
DROP VIEW IF EXISTS staff_members;
DROP TABLE IF EXISTS staff;
DROP VIEW IF EXISTS client_members;
DROP TABLE IF EXISTS clients;
DROP VIEW IF EXISTS usernames;
DROP TABLE IF EXISTS users CASCADE;

-- DROP VIEW IF EXISTS relationships;

CREATE TABLE users (
       id SERIAL PRIMARY KEY UNIQUE,
       email CITEXT UNIQUE NOT NULL,
       nickname TEXT NOT NULL
);

-- Users who are currently staff

CREATE TABLE staff (
       staff_id INTEGER UNIQUE REFERENCES users(id) ON DELETE CASCADE,
       active BOOLEAN
);

-- Users who are currently clients

CREATE TABLE clients (
       client_id INTEGER UNIQUE REFERENCES users(id) ON DELETE CASCADE,
       active BOOLEAN
);

-- This is interesting, because we've basically created a M:1
-- relationship of staff and clients, but a 1:1 relationship of
-- clients to staff.  That satisfies the current assignment, mostly.
-- An appointment can then be made my a client, and there's only one
-- staff person who it could apply to, so the query is straightforward
-- then.
--
-- If we wanted a client to have more than one coach, we'd have to
-- remove the UNIQUE constraint and let there be more than one
-- client-staff relationships.

CREATE TABLE relationship (
       id SERIAL PRIMARY KEY UNIQUE,
       client_id INTEGER UNIQUE NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
       staff_id INTEGER NOT NULL REFERENCES staff(staff_id) ON DELETE CASCADE
);

-- Staff members may create office hours, but to prevent confusion we
-- should not allow a single staff-member's officehour entries to
-- overlap.  The && is the "overlaps" (has points in common) operator
-- for ranges.  

CREATE TABLE officehours (
       id SERIAL PRIMARY KEY UNIQUE,
       staff_id INTEGER NOT NULL REFERENCES staff(staff_id) ON DELETE CASCADE,
       during TSRANGE,
       EXCLUDE USING gist (staff_id WITH =, during WITH &&)
);

-- This one is tricky.  We're basically saying that the client has an
-- appointment, and that's all we care about.  BUT the INSERT must
-- find the staff member with whom this client has a relationship, and
-- assert that the staff member has office hours at that time, and
-- that no other client off that staff member has already chosen an
-- overlapping appointment.

CREATE TABLE appointments (
       id SERIAL PRIMARY KEY UNIQUE,
       during TSRANGE,
       client_id INTEGER NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE
);

CREATE VIEW usernames AS SELECT id, nickname FROM users;

CREATE VIEW staff_members AS          
       (SELECT users.nickname AS staff_name, users.id AS staff_id 
        FROM users WHERE users.id IN (SELECT staff_id FROM staff WHERE active=true));

CREATE VIEW client_members AS
         (SELECT users.nickname AS client_name, users.id AS client_id 
          FROM users WHERE users.id IN (SELECT client_id FROM clients WHERE active=true));

CREATE VIEW staff_client_relationships AS
       (SELECT staff_name, staff_members.staff_id AS staff_id, 
                           client_name, client_members.client_id AS client_id FROM relationship 
               INNER JOIN staff_members ON relationship.staff_id = staff_members.staff_id 
               INNER JOIN client_members ON relationship.client_id = client_members.client_id);

CREATE VIEW staff_appointments AS
       (SELECT staff_name, staff_client_relationships.staff_id AS staff_id,
               client_name, staff_client_relationships.client_id AS client_id, during 
        FROM appointments INNER JOIN staff_client_relationships 
                          ON appointments.client_id = staff_client_relationships.client_id);

DROP FUNCTION IF EXISTS add_appointment(INT, TSRANGE);
CREATE OR REPLACE FUNCTION add_appointment(q_client_id INT, q_timerange TSRANGE) RETURNS VOID as $$
BEGIN 
IF NOT EXISTS (SELECT officehours.id FROM officehours INNER JOIN relationship 
    ON relationship.staff_id = officehours.staff_id 
    WHERE relationship.client_id = q_client_id
    AND (q_timerange <@ officehours.during)) THEN
   RAISE EXCEPTION 'There are no office hours for your coach at that time.';
END IF;
IF EXISTS (SELECT appointments.id FROM appointments WHERE client_id IN (
                                 SELECT client_id FROM relationship WHERE staff_id IN (
                                 SELECT staff_id FROM relationship WHERE client_id = q_client_id))
                                  AND (q_timerange && appointments.during)) THEN
   RAISE EXCEPTION 'That appointment slot is already taken.';
END IF;
INSERT INTO appointments (client_id, during) SELECT q_client_id, q_timerange;
END
$$ LANGUAGE plpgsql;

-- Some basic testing starts below:

-- INSERT INTO users (nickname, email) VALUES ('Alice', 'alice@example.com');
-- INSERT INTO users (nickname, email) VALUES ('Bob', 'bob@example.com');
-- INSERT INTO users (nickname, email) VALUES ('Carol', 'carol@example.com');
-- INSERT INTO users (nickname, email) VALUES ('Doug', 'doug@example.com');

-- SELECT * from usernames;

-- INSERT INTO users (nickname, email) VALUES ('Ellen', 'ellen@example.com');
-- INSERT INTO users (nickname, email) VALUES ('Fred', 'fred@example.com');

-- SELECT * from usernames;

-- INSERT INTO staff (staff_id) SELECT id from users where email IN ('alice@example.com', 'bob@example.com');
-- INSERT INTO clients (client_id) SELECT id from users where email NOT IN ('alice@example.com', 'bob@example.com');
-- UPDATE staff SET active = True;
-- UPDATE clients SET active = True;

-- INSERT INTO relationship (staff_id, client_id) VALUES (1, 3);
-- INSERT INTO relationship (staff_id, client_id) VALUES (1, 4);
-- INSERT INTO relationship (staff_id, client_id) VALUES (2, 5);
-- INSERT INTO relationship (staff_id, client_id) VALUES (2, 6);

-- Note the plural:

-- WITH staff_members AS (SELECT users.nickname AS staff_name, users.id AS staff_id FROM users WHERE users.id IN (SELECT staff_id FROM staff WHERE active=true))


-- SELECT staff_name from staff_members;
-- SELECT client_name from client_members;

-- INSERT INTO officehours (staff_id, during) VALUES (1, '[2015-02-07 10:00, 2015-02-07 17:00)');
-- INSERT INTO officehours (staff_id, during) VALUES (2, '[2015-02-07 12:00, 2015-02-07 15:00)');

-- Insert an appointment with a client
-- WHERE the client's staffer has those office hours (DOES OVERLAP)

-- SELECT * FROM officehours INNER JOIN relationship 
--                           ON relationship.staff_id = officehours.staff_id 
--                           WHERE relationship.client_id = 3;




-- SELECT add_appointment(3, '[2015-02-07 10:00, 2015-02-07 10:30)');
-- SELECT add_appointment(4, '[2015-02-07 10:30, 2015-02-07 11:00)');
-- SELECT add_appointment(5, '[2015-02-07 13:00, 2015-02-07 13:30)');
-- SELECT add_appointment(6, '[2015-02-07 13:30, 2015-02-07 14:00)');

-- INSERT INTO appointments (client_id, during) 
--        SELECT 3, '[2015-02-07 10:00, 2015-02-07 10:30)'
--        WHERE EXISTS (SELECT * FROM officehours INNER JOIN relationship 
--                           ON relationship.staff_id = officehours.staff_id 
--                           WHERE relationship.client_id = 3
--                           AND (officehours.during && '[2015-02-07 10:00, 2015-02-07 10:30)'))
--        AND NOT EXISTS (SELECT * from appointments INNER JOIN 
--                           
-- SELECT * FROM officehours INNER JOIN relationship 
--                           ON relationship.staff_id = officehours.staff_id 
--                           WHERE relationship.client_id = 3
--                           AND (officehours.during && '[2015-02-07 10:00, 2015-02-07 10:30)');
-- 

-- SELECT client_id, during FROM appointments WHERE client_id IN (
--        SELECT client_id FROM relationship WHERE staff_id IN (
--               SELECT staff_id FROM relationship WHERE client_id = 3));
-- 
