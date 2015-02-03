
build:
	@npm install
	@echo "Compiling coffee-script"
	@node_modules/.bin/coffee -c callbax.coffee
	@echo "Adding header to executable js file"
	@echo "#!/usr/bin/env node" | cat - ./callbax.js > /tmp/callbax.js
	@mv /tmp/callbax.js ./callbax.js
	@echo "Set executable bit for runnable JS files"
	@chmod a+x callbax.js
	@echo " -- DONE"

test: build
	@node_modules/.bin/coffee ./test.coffee
