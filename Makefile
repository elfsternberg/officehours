SOURCES = source/*.coffee source/*.haml main.hy

all: static/index.html static/index.js static/officehours.js main.py

# Needed because Flask's "debugger" setting doesn't grok
# Hy directly.  Nuisance!

main.py:
	hy2py main.hy > main.py

static/%.html: source/%.haml
	haml --unix-newlines --no-escape-attrs --double-quote-attributes $< > $@

static/%.js: source/%.coffee
	coffee --compile -o $(dir $@) $<

clean:
	rm static/*.html static/*.js

watch:
	while inotifywait $(SOURCES); do clear ; make all ; done

