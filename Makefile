all: scanner

scanner: scanner.l
	lex scanner.l
	g++ -o scanner -O lex.yy.c symbolTable.cpp -ll

test:
	./scanner