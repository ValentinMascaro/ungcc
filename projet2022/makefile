CC=gcc
YC=yacc
FL=flex

FILE=test

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

run_all:
	
	@./src/bash/run_all.sh

run :
	@echo
	@echo "\e[0;35mCompiling $(FILE) ...\e[0;37m"
	@./testYacc < ./test/$(FILE)
	@echo "\e[0;32mFin\e[0;37m"