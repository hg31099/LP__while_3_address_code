calc: lex.yy.c y.tab.c
	cc -g lex.yy.c y.tab.c -o calc -lm

lex.yy.c: y.tab.c calc.l
	lex calc.l

y.tab.c: calc.y
	yacc -d calc.y

clean:
	rm -rf lex.yy.c y.tab.c y.tab.h calc calc.dSYM

