#include "structure.h"
int ACC = 0;
int adresseACC = 1;
extern int yylineno;

int flag = 0;

/* Creer un symbole pour associer un nom avec un type */
symbole *creer_symbole(char* label_t, char* type_t){
    struct _symbole *nouveau_symbole  = (symbole*) malloc(sizeof(symbole));
    nouveau_symbole->label = label_t;
    nouveau_symbole->type_symbol = type_t;
    nouveau_symbole->nb_param=-1;
    nouveau_symbole->contenu = NULL;
    nouveau_symbole->contenu_adresse = NULL;
    nouveau_symbole->adresse=adresseACC;
    nouveau_symbole->frere = NULL;
    nouveau_symbole->var_or_func=0;
    adresseACC++;
    return nouveau_symbole;
}
symbole *creer_symbole_fonction(char* label_t, char* type_t, symbole *liste_param){
   struct _symbole *nouveau_symbole  = creer_symbole(label_t,type_t);
    struct _param *param_courant = (param*) malloc(sizeof(param));
    nouveau_symbole->nb_param=0;
    nouveau_symbole->param_t=liste_param;
    nouveau_symbole->var_or_func = 1;
   nouveau_symbole->param_t = param_courant;
    while(liste_param != NULL){
        nouveau_symbole->nb_param++;
        param_courant->type_t = liste_param->type_symbol;
        struct _param *nouveau_param = (param*) malloc(sizeof(param));
        param_courant->suivant_t = nouveau_param;
        liste_param = liste_param->frere;
        param_courant = param_courant->suivant_t;
    }
    return nouveau_symbole;
}

symbole *ajouter_symbole(symbole *dest, symbole *ajoute){
    if(dest==NULL){
        return ajoute;
    }
    struct _symbole *courant = dest;
    while(courant->frere != NULL){
        courant = courant->frere;
    }
    courant->frere=ajoute;
    return dest;
}
/* Creer une nouvelle adresse */
void nouvelle_adresse(){
    /* Assurer de ne pas avoir de potentielles erreures (pas super a cause du While)*/
   // while (TABLE[ACC] != NULL) {
        ACC++;
    //}
}

void liberer_tables(){
   if (ACC > 0){
     //  printf("Debut_Liberation\n");
     //  affiche_memoire_symbole();
     //  printf("Fin_Liberation\n");
    TABLE[ACC]=NULL;   
    ACC--;
    }else{
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

symbole *search_by_label_struct(char *label){ // uniquement pour struct
    int ACC_copie = ACC;
    while(ACC_copie >= 0) {
       struct _symbole *courant = TABLE[ACC_copie];
        while(courant != NULL){
           if(!strcmp(courant->label,label)){
               return courant;
            return 0;
            }
           courant=courant->frere;
        } 
        ACC_copie--;
    }
    erreur("le type de structure n'est pas defini",label);
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
    /*if(strcmp(expression1->type_symbol,expression2->type_symbol)) {
        erreur("Mauvais type",expression2->label);
    }*/
}
void verif_type_affectation(symbole *expression1, symbole *expression2){
   
    /* if((expression1->nb_param!=-1)){erreur("Ne peux pas affecter a une fonction",expression1->label);}
    if(strcmp(expression1->type_symbol,expression2->type_symbol) ) {
       
        erreur("Mauvais type",expression2->label);
        printf("ici2?\n");
    }*/
}





/* --------------------------------------- */
/* Gerer les messages d'erreures : la description d 'erreur en bleu la virgule entre en blanc et la ligne en rouge*/
void erreur(char *description, char *terme_concerne) {
    printf("erreur\n");
    printf("ACC = %d \n",ACC);
    affiche_memoire_symbole(); 
    char destination[96];
    if (terme_concerne!=NULL) {
        sprintf(destination,"(1)\x1B[34m%s : %s \x1b[31m \x1b[37m ,  \x1b[31m ligne : %d\x1B[   0m\n", terme_concerne, description, yylineno );
        yyerror(destination);
    }else{
        sprintf("(2)\x1B[31m%s, ligne : %d\x1B[0m\n", description, yylineno );
        yyerror(destination);
    }
       
}

symbole *find_membre(symbole *une_Struct,char *membre_rechercher){
    struct _symbole *courant = une_Struct;
    if(courant->contenu != NULL) {              
        struct _symbole *contenu_courant = courant->contenu;
        while(contenu_courant != NULL) {
            if(!strcmp(membre_rechercher,contenu_courant->label)){
                return contenu_courant;
            }                  
            contenu_courant=contenu_courant->frere;
        }
    }
    erreur("Le symbole de cette structure n'existe pas",membre_rechercher);
}

void verif_param(symbole *fonction, symbole *parametre){
    if(parametre==NULL){
        if(fonction->nb_param>0){
            erreur("aucun argument en parametre lors de l'appel de cette fonction",fonction->label);
        }

    }else{
        struct _symbole *courant = parametre;
        int i = 1;
            while(courant->frere != NULL) {
                i++;            
                courant=courant->frere;
            }
             
            if(i!=fonction->nb_param) {
                erreur("nbr de parametre different lors de l'appel de cette fonction",fonction->label );
            }
    }
    
}

void affiche_memoire_symbole(){
    int ACC_copie = ACC;
    while(ACC_copie >= 0) {
    struct _symbole *courant = TABLE[ACC_copie];
    while(courant != NULL){
         if(courant->nb_param>-1)
                {
                    printf("ACC : %d Func : %s | Type %s |>",ACC_copie,courant->label,courant->type_symbol);
                    if( courant->param_t==NULL)
                    {
                        
                    }
                    else{
                        struct _param *param_courant = courant->param_t;
                    
                    while(param_courant!=NULL)
                        {
                            printf(" Type_Arg %s |",param_courant->type_t);
                            param_courant = param_courant->suivant_t;
                        }
                        printf("\n");
                    }
                }
                
                else{

                
        printf("ACC : %d Variable : %s | Type : %s  ",ACC_copie,courant->label,courant->type_symbol);
        
        if(courant->contenu_adresse!=NULL) {
            printf("TYPE adresse : %s ",courant->contenu_adresse->type_symbol);
        }
        printf("\n");
        if(courant->contenu != NULL) {
            printf("Contenu : %s \n",courant->label);
            struct _symbole *contenu_courant = courant->contenu;
            while(contenu_courant != NULL) {
                printf("nb_param : %d\n",contenu_courant->nb_param);
               
               
                {
                    printf("  Var : %s  Type %s  ", contenu_courant->label,contenu_courant->type_symbol);
                    if(contenu_courant->contenu_adresse!=NULL) {
                        printf("TYPE adresse : %s  ",contenu_courant->contenu_adresse->type_symbol);
                    }
                    printf(" |\n");
                }
                contenu_courant=contenu_courant->frere;
            }
            printf("Fin contenu : %s\n",courant->label);
         
          }
            
         }
                printf("\n");
            courant=courant->frere;
        } 
        ACC_copie--;
    }
}


/////////////////////////////////
//////////////ARBRE//////////////
/////////////////////////////////

arbre *creer_arbre(char *label, enum type_arbre typeEnum, symbole *element, arbre *fils, arbre *frere){
     struct _arbre *nouvel_arbre = (arbre*) malloc(sizeof(arbre));
    nouvel_arbre->type_arbre_t = typeEnum; 
    nouvel_arbre->label=label;
    nouvel_arbre->symbol_t = element;
    nouvel_arbre->frere_t=frere;
    nouvel_arbre->fils_t=fils;
    return nouvel_arbre;
}

void *ajouter_frere(arbre *actuel, arbre *frere) {
    struct _arbre *frere_courant = actuel;
    while(frere_courant->frere_t != NULL) { // tant qu'on trouve des freres on continue de les parcourirs
        frere_courant = frere_courant->frere_t;
    }
    frere_courant->frere_t = frere; // On viens de trouver un frere sans aucun frere, on lui rajoute donc son frere
}


void affiche_arbre2(arbre *un_arbre)
{
    /*
    printf("a=%s \n  b=%s \n  c=%s \n  d=%s \n",
         un_arbre->label,//a
         un_arbre->fils_t->label,//a->b
         un_arbre->fils_t->frere_t->label,//a->b-->c
         un_arbre->fils_t->frere_t->frere_t->label //a->b-->c-->d
         );*/
printf("Arbre : %s \n + = %s \n Fils+ = %s \n FrereFils+ = %s \n ?? : %s \n"
,un_arbre->label, // a
un_arbre->fils_t->label, // +
un_arbre->fils_t->fils_t->label, // 2
un_arbre->fils_t->fils_t->frere_t->label, // 3
"un_arbre->fils_t->fils_t->fils_t->label")  ;

}


void affiche_arbreN(arbre *un_arbre)
{

    if(un_arbre->fils_t==NULL)
    {
        printf("    Feuille : %s \n",un_arbre->label);
        if(un_arbre->frere_t!=NULL)
         {
            affiche_arbre(un_arbre->frere_t);       
        }
    }
    else
    if(un_arbre->fils_t!=NULL)
    {
        printf("[Arbre : %s\n",un_arbre->label);
        affiche_arbre(un_arbre->fils_t);
        printf("]\n");
        if(un_arbre->frere_t!=NULL)
         {
            affiche_arbre(un_arbre->frere_t);       
        }
    }
}
void affiche_arbre(arbre *un_arbre)
{

    if(un_arbre->fils_t==NULL)
    {
        printf("    Feuille : %s ,",un_arbre->label);
        if(un_arbre->frere_t!=NULL)
         {
            affiche_arbre(un_arbre->frere_t);       
        }
    }
    else
    if(un_arbre->fils_t!=NULL)
    {
        printf("[Arbre : %s ,",un_arbre->label);
        affiche_arbre(un_arbre->fils_t);
        printf("]\n");
        if(un_arbre->frere_t!=NULL)
         {
            affiche_arbre(un_arbre->frere_t);       
        }
    }
}

void affiche_arbre_old(arbre *un_arbre)
{
    if(un_arbre->fils_t==NULL)
    {
        printf("   Feuille :");
        printf(" %s \n",un_arbre->label);
        return 0;
    }
    else{
        printf("Arbre :"); // A // + 
        printf(" %s \n",un_arbre->label);
        struct _arbre *courant ;
        struct _arbre *courant_frere;
        courant=un_arbre->fils_t; 
        printf("Courant = %s \n",courant->label);
        int i=0;
        while(courant!=NULL)
        {
            courant_frere=courant->frere_t;
            affiche_arbre(courant); // + // Feuille 2
            while(courant_frere!=NULL)
            {   
                printf("Frere %d : %s",i,courant_frere->label);
                i++;
                //affiche_arbre(courant_frere);
                courant_frere=courant_frere->frere_t;
            }
            printf("\n");
            courant=courant->fils_t;
    }
    }
    
   
}

/*
1) Dans le code FrontENd, admettons que notre structure contient un int et une struct, que devons-nous faire en backend 
pour traduire liste->int  ?

2)int (*fact) (int n);  que se passe-t-il pour le code functions.c avec un ptr vers une fonction
qui s'affecte comme une variable ?

3) Il n'y a pas de définitions extern de malloc dans pointeurs.c , est-ce voulu ?

4) Accepté vous les passages de rapport avec windows + wsl ? Ou y êtes vous allergique ?

*/