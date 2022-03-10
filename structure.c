#include "structure.h"
int ACC = 0;
extern int yylineno;
/* Créer un symbole pour associer un nom avec un type */
symbole *creer_symbole(char* label_t, char* type_t){
    struct _symbole *nouveau_symbole  = (symbole*) malloc(sizeof(symbole));
    nouveau_symbole->label = label_t;
    nouveau_symbole->type_symbol = type_t;

    return nouveau_symbole;
}

/* Créer une nouvelle adresse */
void nouvelle_adresse(){
    /* Assurer de ne pas avoir de potentielles erreures (pas super à cause du While)*/
    while (TABLE[ACC] != NULL) {
        ACC++;
    }
}

void verif_redefinition(char *label)
{
    int i = 0;
    
    while(TABLE[i]!=NULL){
        struct _symbole *courant = TABLE[i];
        if( !strcmp(courant->label,label)){
            erreur("la variable est déjà défini",label);
        }
        i++;
    }    
}

void erreur(char *description, char *terme_concerne) {
    char destination[100];
    if (terme_concerne != NULL) {
        
        sprintf(destination,"\x1B[34m%s : %s \x1b[31m \x1b[37m ,  \x1b[31m ligne : %d\x1B[   0m\n", terme_concerne, description, yylineno );
        yyerror(destination);
    } else {
        sprintf("\x1B[31m%s, ligne : %d\x1B[0m\n", description, yylineno );
        yyerror(destination);
    }
    
}


