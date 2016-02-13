all: static/index.html static/index.js static/officehours.js

static/%.html: source/%.haml
	haml --unix-newlines --no-escape-attrs --double-quote-attributes $< > $@

static/%.js: source/%.coffee
	coffee --compile -o $(dir $@) $<

clean:
	rm static/*.html static/*.js


