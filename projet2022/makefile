CC=gcc
YC=yacc
FL=flex

TARGET=testYacc

compile:
	@$(YC) -d ./src/yaccFrontEnd.y
	@$(FL) ./src/lexFrontEnd.l
	@$(CC) lex.yy.c y.tab.c ./src/structure.c -lfl -o $(TARGET)
	@make -s clean

clean:
	@rm y.tab.c y.tab.h lex.yy.c

run_test:
	@./testYacc < ./test/test.c