#!/usr/local/bin/hy

(import [flask [Flask]])
(def app (Flask __name__))

(with-decorator (.route app "/") (defn hello [] "Hello World"))

(if (= __name__ "__main__")
 (.run app))

