all: parser

lex.yy.cpp: scanner.l
	lex -o lex.yy.cpp scanner.l

y.tab.cpp: parser.y
	yacc -dv -o y.tab.cpp parser.y

parser: y.tab.cpp lex.yy.cpp symbolTable.h symbolTable.cpp 
	g++ -o parser y.tab.cpp symbolTable.cpp -ll -ly -std=c++11

clean_parser:
	rm lex.yy.* parser y.*

clean_test:
	rm *.jasm *.class

clean_all: clean_parser clean_test

test:
	./parser HellowWorld.scala
	./parser sigma.scala
	./parser fib.scala
	./parser example.scala

javaa_:
	./javaa HellowWorld.jasm
	./javaa sigma.jasm
	./javaa fib.jasm
	./javaa example.jasm