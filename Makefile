
build:
	@npm install
	@echo "BUILD coffee-script"
	@node_modules/.bin/coffee -c callbax.coffee
	@echo " -- done"

test: build
	@echo "TEST"
	@node_modules/.bin/coffee ./test.coffee
	@echo " -- done"
