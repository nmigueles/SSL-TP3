# i wanna execute gcc lex.yy.c -o out -lc -ll && ./out
# -w suppresses warnings
build: scanner.l parser.y
	lex scanner.l && bison -d parser.y && gcc -o micro -lc -ll -w lex.yy.c parser.tab.c
run: build
	echo "Running...\n" && ./micro

ifeq (file,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "run"
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)
endif