

static/%.html: source/%.haml
	haml --unix-newlines --no-escape-attrs --double-quote-attributes $< > $@


