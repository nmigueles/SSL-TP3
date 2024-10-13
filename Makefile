# i wanna execute gcc lex.yy.c -o out -lc -ll && ./out
# -w suppresses warnings
build: lex.yy.c
	lex lex.l && gcc lex.yy.c -o out -lc -ll -w
run: build
	echo "Running...\n" && ./out

ifeq (file,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "run"
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)
endif
file: build
	./out < $(RUN_ARGS)
clean:
	rm -f lex.yy.c out