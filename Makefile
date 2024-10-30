build: scanner.l parser.y
	bison -yd parser.y && lex scanner.l && gcc -o micro -lc -ll -w lex.yy.c y.tab.c
run: build
	echo "Running...\n" && ./micro

ifeq (file,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "run"
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)
endif