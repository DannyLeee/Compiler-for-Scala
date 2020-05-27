all: lex.yy.c scanner y.tab.cpp parser

lex.yy.c: scanner.l
	lex scanner.l

scanner: lex.yy.c symbolTable.cpp
	g++ -o scanner -O lex.yy.c symbolTable.cpp -ll

y.tab.cpp: parser.y
	yacc -d -o y.tab.cpp parser.y

parser: y.tab.cpp lex.yy.c symbolTable.h symbolTable.cpp 
	g++ -o parser y.tab.cpp symbolTable.cpp -ll -ly -std=c++11 -Wno-deprecated-register

clean:
	rm lex.yy.c parser y.*