#!/usr/local/bin/hy

(import  psycopg2 psycopg2.extras datetime [flask [Flask jsonify send-from-directory]])
(def app (Flask __name__))

(defn connect []
   (psycopg2.connect "host='localhost' dbname='officehours' user='officehours' password='eatabug'"))

(defn tap [a] (print (str a)) a)

(defn select [curs cmd &rest args]
  (.execute curs cmd (list args))
  (.fetchall curs))


(defn during-to-utc [d]
  (let [[ud (.isoformat (getattr (get d 0) "upper"))]
        [ld (.isoformat (getattr (get d 0) "lower"))]]
    (, ld ud)))

; This is purely for demonstration purposes.

(with-decorator
  (.route app "/")
  (defn home []
    (send-from-directory "static" "index.html")))

(with-decorator
  (.route app "/oh/hours/<start:start>")
  (print start)
  (jsonify { start: start }))

;(with-decorator 
;  (.route app "/") 
;  (defn hello [] 
;    (let [[conn (connect)]
;          [curs (.cursor conn)]
;          [week (psycopg2.extras.DateTimeRange (datetime.datetime 2015 1 31 0 0)
;                                               (datetime.datetime 2015 2 7 23 59))]
;          [cmd1 (+ "SELECT during FROM staff_appointments WHERE staff_id IN "
;                   "(SELECT staff_id FROM staff_client_relationships "
;                   "WHERE client_id = %s) AND during && %s")]
;          [appointments (select curs cmd1 3 week)]
;          [cmd2 (+ "SELECT during, appointment_id, client_id FROM staff_appointments "
;                   "WHERE client_id = %s AND during && %s")]
;          [client_appointments (select curs cmd2 3 week)]
;          [cmd3 (+ "SELECT during FROM officehours WHERE staff_id IN "
;                    "(SELECT staff_id FROM staff_client_relationships "
;                    "WHERE client_id = %s) AND during && %s")]
;          [officehours (select curs cmd3 3 week)]]
;      (jsonify { "appointments" (list (map during-to-utc appointments))
;                 "officehours" (list (map during-to-utc officehours)) }))))

(if (= __name__ "__main__")
  (do
   (setv app.debug True)
   (.run app)))

