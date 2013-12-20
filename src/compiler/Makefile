LEX=lex
YACC=yacc
CFLAGS=-Wall
CC=gcc

OBJ=./obj
BIN=./bin
SRC=./src



all: mkdirs $(OBJ)/struct.o $(BIN)/parse 


mkdirs:
	@mkdir -p ${OBJ}
	@mkdir -p ${BIN}

$(BIN)/parse:${OBJ}/y.tab.c ${OBJ}/lex.yy.c $(OBJ)/struct.o
	$(CC) $(CFLAGS) -o $@ $^

${OBJ}/struct.o:${SRC}/struct.c ${SRC}/struct.h
	cp $(SRC)/*.h $(OBJ)/
	 $(CC) -o $@ $(CFLAGS) -c $<

${OBJ}/y.tab.c:${SRC}/grammar.y
	$(YACC) -o $@ -d $^

${OBJ}/lex.yy.c:${SRC}/scanner.l
	$(LEX) -o $@ $^

clean:
	@rm -rf ${OBJ}

distclean: clean
	@rm -rf ${BIN}

export: 
	@D=`pwd`"/bin" ; \
	createdir="../driver/enseirbot" ;\
	X='driver.ll';\
	echo " Exporting $$X to $$createdir/$$X"; \
	ln -sf $$D/$$X $$createdir/$$X ; \
