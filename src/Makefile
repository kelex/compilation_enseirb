LEX=lex
YACC=yacc
CFLAGS=-Wall
CC=gcc

all: struct.o parse

parse:y.tab.c lex.yy.c struct.h
	$(CC) $(CFLAGS) -o $@ $^

struct.o:struct.c
	 $(CC) -o $@ $(CFLAGS) -c $<

y.tab.c:grammar.y
	$(YACC) -d $^

lex.yy.c:scanner.l
	$(LEX) -o $@ $^

clean:
	rm -f grammar.c scanner.c
	rm -f *.o
