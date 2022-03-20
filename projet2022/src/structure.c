#include "structure.h"
int ACC = 0;
extern int yylineno;

/* Creer un symbole pour associer un nom avec un type */
symbole *creer_symbole(char* label_t, char* type_t){
    struct _symbole *nouveau_symbole  = (symbole*) malloc(sizeof(symbole));
    nouveau_symbole->label = label_t;
    nouveau_symbole->type_symbol = type_t;
    nouveau_symbole->nb_param=-1;
    return nouveau_symbole;
}
symbole *creer_symbole_fonction(char* label_t, char* type_t, symbole *liste_param)
{
    struct _symbole *nouveau_symbole  = creer_symbole(label_t,type_t);
    struct _param *param_courant = (param*) malloc(sizeof(param));
    nouveau_symbole->nb_param=0;
    nouveau_symbole->param_t=liste_param;

   nouveau_symbole->param_t = param_courant;
    while(liste_param != NULL) 
    {
        nouveau_symbole->nb_param++;
        param_courant->type_t = liste_param->type_symbol;
        struct _param *nouveau_param = (param*) malloc(sizeof(param));
        param_courant->suivant_t = nouveau_param;
        liste_param = liste_param->frere;
        param_courant = param_courant->suivant_t;
    }
    return nouveau_symbole;
}

symbole *ajouter_symbole(symbole *actuel, symbole *futur){
    if(actuel==NULL){
        return futur;
    }
    struct _symbole *courant = actuel;
    while(courant->frere != NULL){
        courant = courant->frere;
    }
    courant->frere=futur;
    return actuel;
}
/* Creer une nouvelle adresse */
void nouvelle_adresse(){
    /* Assurer de ne pas avoir de potentielles erreures (pas super a cause du While)*/
    while (TABLE[ACC] != NULL) {
        ACC++;
    }
}

void liberer_tables(){
   if (ACC > 0){
       affiche_memoire_symbole();
       printf("--------\n");
    TABLE[ACC]=NULL;   
    ACC--;
   }
   else{
       printf("tentative de suppression de globale\n");
   }
     
}

/* Permet de gere une redefinition en comparant les symboles afin d'afficher une erreur de redefinition d'une variable */
symbole *search_by_label(char *label){
    int ACC_copie = ACC;
    while(ACC_copie >= 0) {
       struct _symbole *courant = TABLE[ACC_copie];
        while(courant != NULL){
           if(!strcmp(courant->label,label)){
               return courant;
           }
           courant=courant->frere;
        } 
        ACC_copie--;
    }
    erreur("la variable n'est pas defini",label);
}
void verif_redefinition(char *label,symbole *table_a_verifier){
    //  int ACC_copie = ACC;
   // while(ACC_copie >= 0) {
       struct _symbole *courant = table_a_verifier;
        while(courant != NULL){
           if(!strcmp(courant->label,label)){
               erreur("la variable est deja defini",label);
           }
           courant=courant->frere;
        } 
      //  ACC_copie--;
    //}
}

char *find_type(symbole *expression1){
    char *label = expression1->label;
    int ACC_copie = ACC;
    while(ACC_copie >= 0) {
       struct _symbole *courant = TABLE[ACC_copie];
        while(courant != NULL){
           if(!strcmp(courant->label,label)){
               return courant->type_symbol;
           }
           courant=courant->frere;
        } 
        ACC_copie--;
    }
    erreur("la variable n'est pas defini ",label);
}

/*si aucune erreur, alors la variable de nom label est de type INT */
void verif_type(symbole *expression1, symbole *expression2){
    if(strcmp(expression1->type_symbol,expression2->type_symbol)) {
        erreur("Mauvais type",expression2->label);
    }
}
void verif_type_affectation(symbole *expression1, symbole *expression2){
    if((expression1->nb_param!=-1)){erreur("Ne peux pas affecter a une fonction",expression1->label);}
    if(strcmp(expression1->type_symbol,expression2->type_symbol) ) {
        erreur("Mauvais type",expression2->label);
    }
}





/* --------------------------------------- */
/* Gerer les messages d'erreures : la description d 'erreur en bleu la virgule entre en blanc et la ligne en rouge*/
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

void affiche_memoire_symbole(){
     int ACC_copie = ACC;
         while(ACC_copie >= 0) {
        struct _symbole *courant = TABLE[ACC_copie];
        while(courant != NULL){
          printf("ACC : %d Variable : %s\n",ACC_copie,courant->label);
           courant=courant->frere;
        } 
        ACC_copie--;
    }
}



