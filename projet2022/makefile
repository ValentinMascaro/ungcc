CC=gcc
YC=yacc
FL=flex

FILE=test

TARGET=structitfrontend
TARGET2=structibackend
compile:
	@$(YC) -d ./src/yaccFrontEnd.y
	@$(FL) ./src/lexFrontEnd.l
	@$(CC) lex.yy.c y.tab.c ./src/structure.c -lfl -o $(TARGET)
	@make -s clean
	@$(YC) -d ./src/yaccBackEnd.y
	@$(FL) ./src/lexBackEnd.l
	@$(CC) lex.yy.c y.tab.c -lfl -o $(TARGET2)
	@make -s clean

clean:
	@rm y.tab.c y.tab.h lex.yy.c
	
clean_all_backend:
	@rm ./resultat_backend/*.c

run_test:
	@./testYacc < ./test/test.c

run_all:	
	@./src/bash/run_all.sh

run :
	@echo "---------------"
	@echo "\e[0;37mEst entrain de compiler $(FILE) ...\e[0;37m"
	@./$(TARGET) < ./test/$(FILE)
	@mkdir -p resultat_backend/
	@mv ./_tmp_file.c ./resultat_backend/backend_$(FILE)
	@echo "\e[0;37mFichier en backend généré dans ./resultat_backend/backend_$(FILE)\e[0;37m"
	@echo
	@echo "\e[0;37mFichier backend en cours de vérification ... \e[0;37m"
	@./$(TARGET2) < ./resultat_backend/backend_$(FILE)
	@echo
	@echo "\e[0;37mFichier backend ont été vérifié et valider par le parseur ! \e[0;37m"
	@echo "\e[0;37mFin\e[0;37m"
	@echo "---------------"

run_backend_only :
	@echo
	@echo "\e[0;37mFichier backend en cours de vérification ... \e[0;37m"
	@./$(TARGET2) < ./resultat_backend/$(FILE)
	@echo "\e[0;37mFichier backend ont été vérifié et valider par le parseur ! \e[0;37m"
	@echo "\e[0;37mFin\e[0;37m"