#!/usr/local/bin/hy

(import [flask [Flask]])
(def app (Flask __name__))
(def hello ((.route app "/") (fn [] "Hello World")))
(if (= __name__ "__main__")
 (.run app))

