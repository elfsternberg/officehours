#!/usr/local/bin/hy

(def *version* "0.0.2")
(import psycopg2)
(require hy.contrib.anaphoric)

(defn connect []
   (psycopg2.connect "host='localhost' dbname='officehours' user='officehours' password='eatabug'"))


(def users [
            (, "Alice" "alice@example.com")
            (, "Bob" "bob@example.com")
            (, "Carol" "carol@example.com")
            (, "Doug" "doug@example.com")
            (, "Ellen" "ellen@example.com")
            (, "Fred" "fred@example.com")])

(defn insert-user [user conn] 
  (let [[curs (.cursor conn)]]
    (.execute curs "INSERT INTO users (nickname, email) values (%s, %s)" user)))

(let [[conn (connect)]]
  (for [user users] (insert-user user conn))
  (.commit conn))

(let [[conn (connect)]
      [curs (.cursor conn)]]
  (.execute curs "INSERT INTO staff (staff_id) SELECT id from users where email IN ('alice@example.com', 'bob@example.com');")
  (.execute curs "INSERT INTO clients (client_id) SELECT id from users where email NOT IN ('alice@example.com', 'bob@example.com');")
  (.execute curs "UPDATE staff SET active = True;")
  (.execute curs "UPDATE clients SET active = True;")
  (.commit conn))

(let [[conn (connect)]
      [curs (.cursor conn)]]
  (for [pair [(, 1 3) (, 1 4) (, 2 5) (, 2 6)]]
    (.execute curs "INSERT INTO relationship (staff_id, client_id) VALUES (%s, %s)" pair))
  (.commit conn))

(let [[conn (connect)]
      [curs (.cursor conn)]]
  (print "\nStaff Members:")
  (.execute curs "SELECT staff_name from staff_members")
  (for [staff (.fetchall curs)]
    (print (+ "    " (get staff 0)))))

(let [[conn (connect)]
      [curs (.cursor conn)]]
  (print "\nClients:")
  (.execute curs "SELECT client_name from client_members")
  (for [staff (.fetchall curs)]
    (print (+ "    " (get staff 0)))))

(let [[conn (connect)]
      [curs (.cursor conn)]]
  (.execute curs "INSERT INTO officehours (staff_id, during) VALUES (1, '[2015-02-07 10:00, 2015-02-07 17:00)');")
  (.execute curs "INSERT INTO officehours (staff_id, during) VALUES (2, '[2015-02-07 12:00, 2015-02-07 15:00)');")
  (.commit conn))

(let [[conn (connect)]
      [curs (.cursor conn)]
      [ops ["PERFORM add_appointment(3, '[2015-02-07 10:00, 2015-02-07 10:30)');"
            "PERFORM add_appointment(4, '[2015-02-07 10:30, 2015-02-07 11:00)');"
            "PERFORM add_appointment(5, '[2015-02-07 13:00, 2015-02-07 13:30)');"
            "PERFORM add_appointment(6, '[2015-02-07 13:30, 2015-02-07 14:00)');"]]]

  (for [op ops]
    (print op)
    (.execute curs op)
    (.commit conn)))

(let [[conn (connect)]
      [curs (.cursor conn)]]
  (.execute curs "SELECT * FROM staff_appointments WHERE staff_id = 1")
  (for [meeting (.fetchall curs)]
    (print meeting)))



  
   
