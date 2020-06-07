all: scanner parser

lex.yy.cpp: scanner.l
	lex -o lex.yy.cpp scanner.l

scanner: lex.yy.cpp symbolTable.cpp
	g++ -o scanner -O lex.yy.c symbolTable.cpp -ll

y.tab.cpp: parser.y
	yacc -dv -o y.tab.cpp parser.y

parser: y.tab.cpp lex.yy.cpp symbolTable.h symbolTable.cpp 
	g++ -o parser y.tab.cpp symbolTable.cpp -ll -std=c++11

clean:
	rm lex.yy.* parser y.*

test:
	./parser HellowWorld.scala
	./parser sigma.scala
	./parser fib.scala
	./parser example.scala