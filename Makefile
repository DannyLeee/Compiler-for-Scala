all: scanner

scanner: scanner.l
	lex scanner.l
	cc -o scanner -O lex.yy.c -ll

test:
	./scanner