#include "structure.h"

int ACC = 0;
int adresseACC = 1;
extern int yylineno;
int flag = 0;
int acc_new_temp = 1;
int acc_temp_declaration=1;
int acc_temp_instruction=1;
void init(){
    //Program = creer_arbre("Program",MON_AUTRE,NULL,creer_arbre("NULL",MON_NULL,NULL,NULL,NULL),NULL);
    Program = creer_arbre("Program",MON_AUTRE,NULL,creer_arbre("NULL",MON_NULL,NULL,NULL,NULL),NULL);
}

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
    struct _symbole *symbole_courant = (symbole*) malloc(sizeof(symbole));
    nouveau_symbole->nb_param=0;
    nouveau_symbole->param_t=liste_param;
    nouveau_symbole->var_or_func = 1;
    nouveau_symbole->param_t = symbole_courant;
    while(liste_param != NULL){
        nouveau_symbole->nb_param++;
        symbole_courant->label=liste_param->label;
        symbole_courant->type_symbol = liste_param->type_symbol;
        struct _symbole *nouveau_param = (symbole*) malloc(sizeof(symbole));
        symbole_courant->frere = nouveau_param;
        liste_param = liste_param->frere;
        symbole_courant = symbole_courant->frere;
    }
    return nouveau_symbole;
}

symbole *creer_symbole_fonction_old(char* label_t, char* type_t, symbole *liste_param){
    struct _symbole *nouveau_symbole  = creer_symbole(label_t,type_t);
    struct _symbole *symbole_courant = (symbole*) malloc(sizeof(symbole));
    nouveau_symbole->nb_param=0;
    nouveau_symbole->param_t=liste_param;
    nouveau_symbole->var_or_func = 1;
    nouveau_symbole->param_t = symbole_courant;
    while(liste_param != NULL){
        nouveau_symbole->nb_param++;
        symbole_courant->label=liste_param->label;
        symbole_courant->type_symbol = liste_param->type_symbol;
        struct _symbole *nouveau_param = (symbole*) malloc(sizeof(symbole));
        
        symbole_courant->frere = nouveau_param;
        liste_param = liste_param->frere;
        symbole_courant = symbole_courant->frere;
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
            if(courant->nb_param>-1) {
                printf("ACC : %d Func : %s | Type %s |>",ACC_copie,courant->label,courant->type_symbol);
                if( courant->param_t==NULL)  {
                            
                }else{
                    struct _symbole *param_courant = courant->param_t;
                    while(param_courant!=NULL) {
                        printf(" Type_Arg %s |",param_courant->type_symbol);
                        param_courant = param_courant->frere;
                    }
                    printf("\n");
                }
            }else{       
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
                        printf("  Var : %s  Type %s  ", contenu_courant->label,contenu_courant->type_symbol);
                        if(contenu_courant->contenu_adresse!=NULL) {
                            printf("TYPE adresse : %s  ",contenu_courant->contenu_adresse->type_symbol);
                        }
                        printf(" |\n");
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

/* ------ ARBRE ------ */

arbre *creer_arbre(char *label, enum type_arbre typeEnum, symbole *element, arbre *fils, arbre *frere){
     struct _arbre *nouvel_arbre = (arbre*) malloc(sizeof(arbre));
    nouvel_arbre->type_arbre_t = typeEnum; 
    nouvel_arbre->label=label;
    nouvel_arbre->symbol_t = element;
    nouvel_arbre->frere_t=frere;
    nouvel_arbre->fils_t=fils;
    return nouvel_arbre;
}

void *ajouter_frere_old(arbre *actuel, arbre *frere) {
    struct _arbre *frere_courant = actuel;
    while(frere_courant->type_arbre_t!=MON_NULL ) { // tant qu'on trouve des freres on continue de les parcourirs
        frere_courant = frere_courant->frere_t;
    }
    frere_courant = frere; // On viens de trouver un frere sans aucun frere, on lui rajoute donc son frere
}

void *ajouter_frere(arbre *actuel, arbre *frere) {
    struct _arbre *frere_courant = actuel;
    while(frere_courant->frere_t != NULL) { // tant qu'on trouve des freres on continue de les parcourirs
        frere_courant = frere_courant->frere_t;
    }
    
    frere_courant->frere_t = frere; // On viens de trouver un frere sans aucun frere, on lui rajoute donc son frere
}


void affiche_arbre2(arbre *un_arbre){
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


void affiche_arbreN(arbre *un_arbre){
    if(un_arbre->fils_t==NULL) {   
        if(un_arbre->label == NULL){printf("true\n");}
        printf("    Feuille : %s ,",un_arbre->label);
        
        if(un_arbre->frere_t!=NULL) {
            affiche_arbre(un_arbre->frere_t);       
        }
    }else if(un_arbre->fils_t!=NULL)    {
        printf("[Arbre : %s\n",un_arbre->label);
        affiche_arbre(un_arbre->fils_t);
        printf("]\n");
        if(un_arbre->frere_t!=NULL) {
            affiche_arbre(un_arbre->frere_t);       
        }
    }
}
void affiche_arbre(arbre *un_arbre){
    if(un_arbre->type_arbre_t==MON_BLOC) {
        printf("Bloc : \n");
        affiche_memoire_symbole2(un_arbre->symbol_t);
    }    
    if(un_arbre->fils_t==NULL)   {
        printf("    Feuille : %s \n",un_arbre->label);
        if(un_arbre->frere_t!=NULL) {
            affiche_arbre(un_arbre->frere_t);       
        }
    } else if(un_arbre->fils_t!=NULL)   {
        printf("[Arbre : %s ,",un_arbre->label);
        if(un_arbre->type_arbre_t==MON_FONCTION)    {
            printf("\nArg : \n");
            affiche_memoire_symbole2(un_arbre->symbol_t->param_t);
            printf("FinArg\n");
        }
   
        affiche_arbre(un_arbre->fils_t);
        printf("]\n");
        if(un_arbre->frere_t!=NULL) {
            affiche_arbre(un_arbre->frere_t);       
        }
    }
}
//pas utilise
void affiche_memoire_symbole2(symbole *le_symbole){
    struct _symbole *courant = le_symbole;
    while(courant != NULL){
        if(courant->nb_param>-1)  {
            printf("Func : %s | Type %s |>",courant->label,courant->type_symbol);
            if( courant->param_t==NULL)   {
                        
            }else{
                struct _symbole *param_courant = courant->param_t;
                    
                while(param_courant!=NULL) {
                    printf(" Nom : %s Type_Arg %s |",param_courant->label,param_courant->type_symbol);
                    param_courant = param_courant->frere;
                }
                printf("\n");
            }
        }else{      
            printf("Variable : %s | Type : %s  ",courant->label,courant->type_symbol);
            if(courant->contenu_adresse!=NULL) {
                printf("TYPE adresse : %s ",courant->contenu_adresse->type_symbol);
            }
            printf("\n");
            if(courant->contenu != NULL) {
                printf("Contenu : %s \n",courant->label);
                struct _symbole *contenu_courant = courant->contenu;
                while(contenu_courant != NULL) {
                    printf("nb_param : %d\n",contenu_courant->nb_param);              
                    printf("  Var : %s  Type %s  ", contenu_courant->label,contenu_courant->type_symbol);
                    if(contenu_courant->contenu_adresse!=NULL) {
                        printf("TYPE adresse : %s  ",contenu_courant->contenu_adresse->type_symbol);
                    }
                    printf(" |\n");
                    contenu_courant=contenu_courant->frere;
                }
                printf("Fin contenu : %s\n",courant->label);           
            }
        }
        printf("\n");
        courant=courant->frere;
    } 
}

/* ------ GENERATION ------ */

void clean_file(){
    if (remove("_tmp_file.c") == 0){
        printf("C'est remove\n");
    }else{   
       printf("Impossible de supprimer le fichier\n");   
    }
}

void new_temp(char *str,size_t len){
    snprintf(str,len,"_var%d",acc_new_temp);
    str[len-1]='\0';
    acc_new_temp++;
}

void creer_fichier_c(arbre *arbre){
    FILE *fd_c;
    fd_c=fopen("_tmp_file.c","w+");
    parcoursProgramme(arbre,fd_c);
    fclose(fd_c);
}

void parcoursProgramme(arbre *arbre, FILE *fd_c) {
  struct _arbre *courant = arbre->fils_t;
  struct _symbole *symbole_arbre = courant->symbol_t;

    if (courant->type_arbre_t == MON_VARIABLE) {
        if (!strcmp(symbole_arbre->type_symbol, "PTR")){
            fprintf(fd_c, "void *%s ;\n", symbole_arbre->label);
        }else {
            fprintf(fd_c, "%s %s ;\n", symbole_arbre->type_symbol, symbole_arbre->label);
        }
    }else {
        if (courant->type_arbre_t == MON_FONCTION) {
            parcoursFonction(courant, fd_c);

    }
    } 
    while (courant->frere_t != NULL) {
        courant = courant->frere_t;
        symbole_arbre = courant->symbol_t;
        if (courant->type_arbre_t == MON_VARIABLE) {
            if (!strcmp(symbole_arbre->type_symbol, "PTR")){
                fprintf(fd_c, "void *%s ;\n", symbole_arbre->label);
        }else {
            fprintf(fd_c, "%s %s ;\n", symbole_arbre->type_symbol, symbole_arbre->label);
        }
      }else {
        if (courant->type_arbre_t == MON_FONCTION){
            parcoursFonction(courant, fd_c);
        }
      }
    }
}
/* struct _symbole *param_courant = courant->param_t;
                    
                while(param_courant!=NULL) {
                    printf(" Nom : %s Type_Arg %s |",param_courant->label,param_courant->type_symbol);
                    param_courant = param_courant->frere;
                }
                printf("\n"); */
void parcoursFonction(arbre *arbre, FILE *fd_c){
    struct _symbole *symbole_arbre = arbre->symbol_t;
    if(!strcmp(symbole_arbre->type_symbol,"PTR")) {
        fprintf(fd_c,"void *%s(",symbole_arbre->label);
    }else{
        fprintf(fd_c,"%s %s(",symbole_arbre->type_symbol,symbole_arbre->label);
    }
   //////////////////ARGUMENT FONCTION /////////////////////////
    if(symbole_arbre->nb_param>0){ 
        int incr = 0;
        struct _symbole *param = symbole_arbre->param_t;
        
            if(!strcmp(param->type_symbol,"PTR")) {
                fprintf(fd_c,"void *%s",param->label);
            }else{
                fprintf(fd_c,"%s %s",param->type_symbol,param->label);
        }
        incr++;
        while(incr<symbole_arbre->nb_param){
            param=param->frere;
            if(!strcmp(param->type_symbol,"PTR")) {
                fprintf(fd_c,", void *%s",param->label); 
            }else{
                fprintf(fd_c,", %s %s",param->type_symbol,param->label);
            }  
            incr++; 
        }
       
    }
    fprintf(fd_c,")\n{\n");
    //////////////////fin ARGUMENT FONCTION /////////////////////////

    //////////////////SYMBOLE DE BASE FONCTION \\\\\\\\\\\\\\\\\

    if(arbre->fils_t->symbol_t!=NULL) {
        struct _symbole *symbole_bloc = arbre->fils_t->symbol_t;
        struct _symbole *symbole_bloc_courant = symbole_bloc;
       if(!strcmp(symbole_bloc_courant->type_symbol,"PTR")) {
                fprintf(fd_c,"\tvoid *%s;\n",symbole_bloc_courant->label);
            }else{
                fprintf(fd_c,"\t%s %s;\n",symbole_bloc_courant->type_symbol,symbole_bloc_courant->label);
            }  
        
        while(symbole_bloc_courant->frere!=NULL) {
            symbole_bloc_courant=symbole_bloc_courant->frere;
            if(!strcmp(symbole_bloc_courant->type_symbol,"PTR")) {
                fprintf(fd_c,"\tvoid *%s;\n",symbole_bloc_courant->label);
            }else{
                fprintf(fd_c,"\t%s %s;\n",symbole_bloc_courant->type_symbol,symbole_bloc_courant->label);
            }  
        }
    }
    //\\\\\\\\\\\\\\\\\\FIN SYMBOLE DE BASE FONCTION//////////////
    
    // a -> a [Arbre MONFLECHE , a , a ]
    // a + a + a + a  [ Arbre :  a , [Arbre]]
    
    struct _arbre *arbre_corps = arbre->fils_t;
    if(arbre_corps->fils_t!=NULL)
    {
        struct _arbre *arbre_instruction =arbre_corps->fils_t;
       // struct _arbre *arbre_instruction_courant =arbre_corps->fils_t;

        parcoursArbreDeclaration(arbre_instruction,fd_c);
       // parcoursArbreInstruction(arbre_instruction,fd_c);
    }
    







    fprintf(fd_c,"}\n");
}

void parcoursArbreDeclaration(arbre *arbre, FILE *fd_c)
{
     if(arbre->type_arbre_t==MON_OPERATION)
    {
        if(arbre->fils_t->type_arbre_t==MON_OPERATION) // ( 1 + ( 2 + ( 3 + 4) ))
        {                                            // (+ ( + ( + 1 2) 3) 4 )
                                            // (4 + (3 + ( 1 + 2 ) ) )
            struct _arbre *courant = arbre->fils_t;
            parcoursArbreDeclaration(courant,fd_c); // -- 
             if(!strcmp(courant->label,"+-*") ){
                fprintf(fd_c,"void _var%d;\n",acc_temp_declaration);
             }
             else{
                 fprintf(fd_c,"int _var%d;\n",acc_temp_declaration);
             }
            acc_temp_declaration++;
        }
        else
        {
            parcoursArbreDeclaration(arbre->fils_t->frere_t,fd_c);
        }
    }
   else if(arbre->type_arbre_t==MON_FLECHE){ // ( -> ( -> a6 c) c ) 
        parcoursArbreDeclaration(arbre->fils_t,fd_c);
        fprintf(fd_c,"void *_var%d;\n",acc_temp_declaration);
        acc_temp_declaration++;
   }
   else
    {
        if(arbre->fils_t==NULL)
        {
            if(arbre->frere_t!=NULL)
            {
                parcoursArbreDeclaration(arbre->frere_t,fd_c);
            }
        }
        else if(arbre->fils_t!=NULL)
        {
            parcoursArbreDeclaration(arbre->fils_t,fd_c);
            if(arbre->frere_t!=NULL)
            {
                parcoursArbreDeclaration(arbre->frere_t,fd_c);
            }
        }

        // a = 1 + ( 2 + ( 3 + 4 ) ) 
        // a = 1 + 2;
    }
}

void parcoursArbreDeclaration_old(arbre *arbre, FILE *fd_c){  
    if(arbre->fils_t==NULL)
    {
        if(arbre->type_arbre_t==MON_FLECHE){
            fprintf(fd_c,"\tvoid *_var%d;\n",acc_temp_declaration);
            acc_temp_declaration++;
        }
        if(arbre->type_arbre_t==MON_OPERATION && arbre->frere_t->type_arbre_t==MON_OPERATION){
            if(!strcmp(arbre->frere_t->label,"+-*") ){
            
                fprintf(fd_c,"\tvoid *_var%d;\n",acc_temp_declaration);
                acc_temp_declaration++;
            }else{
                fprintf(fd_c,"\tint _var%d;\n",acc_temp_declaration);
                acc_temp_declaration++;
            }
        }
        if(arbre->frere_t!=NULL) {
            parcoursArbreDeclaration(arbre->frere_t,fd_c);       
        }    
    }else 
    if(arbre->fils_t!=NULL)
    {
        if(arbre->type_arbre_t==MON_FLECHE){
            fprintf(fd_c,"\tvoid *_var%d;\n",acc_temp_declaration);
            acc_temp_declaration++;
        }
        if(arbre->fils_t->type_arbre_t==MON_OPERATION && arbre->fils_t->frere_t->type_arbre_t==MON_OPERATION)
        {
            if(!strcmp(arbre->fils_t->frere_t->label,"+-*") )  {
                fprintf(fd_c,"\tvoid *_var%d;\n",acc_temp_declaration);
                acc_temp_declaration++;
                if(!strcmp(arbre->fils_t->label,"+-*")) {
                    fprintf(fd_c,"\tvoid *_var%d;\n",acc_temp_declaration);
                    acc_temp_declaration++;
                }
                else{
                    fprintf(fd_c,"\tint _var%d;\n",acc_temp_declaration);
                    acc_temp_declaration++;
                }
            }else{
                fprintf(fd_c,"\t int _var%d;\n",acc_temp_declaration);
                acc_temp_declaration++;
                if(!strcmp(arbre->fils_t->label,"+-*")){
                    fprintf(fd_c,"\tvoid *_var%d;\n",acc_temp_declaration);
                    acc_temp_declaration++;
                }else{
                    fprintf(fd_c,"\tint _var%d;\n",acc_temp_declaration);
                    acc_temp_declaration++;
                }
            }
        }else if(arbre->type_arbre_t==MON_OPERATION && ( arbre->fils_t->type_arbre_t==MON_OPERATION || arbre->fils_t->frere_t->type_arbre_t==MON_OPERATION)){   
                 if(!strcmp(arbre->fils_t->label,"+-*")){
                    fprintf(fd_c,"\tvoid *_var%d;\n",acc_temp_declaration);
                    acc_temp_declaration++;
                }else{
                    fprintf(fd_c,"\tint _var%d;\n",acc_temp_declaration);
                    acc_temp_declaration++;
                }
            }
            parcoursArbreDeclaration(arbre->fils_t,fd_c);   
            if(arbre->frere_t!=NULL) {
                parcoursArbreDeclaration(arbre->frere_t,fd_c);       
            }
    }
}
/*
void parcoursArbreInstruction(arbre *arbre, FILE *fd_c){  
    if(arbre->fils_t==NULL)
    {
        if(arbre->type_arbre_t==MON_FLECHE){
          
            acc_temp_instruction++;
        }
        if(arbre->type_arbre_t==MON_OPERATION && arbre->frere_t->type_arbre_t==MON_OPERATION){
            if(!strcmp(arbre->frere_t->label,"+-*") ){
               
               acc_temp_instruction++;
            }else{
                parcoursArbreInstruction(arbre->frere_t,fd_c);

               acc_temp_instruction++;
            }
        }
        if(arbre->frere_t!=NULL) {
             parcoursArbreInstruction(arbre->frere_t,fd_c);       
        }  
    }else 
    if(arbre->fils_t!=NULL)
    {
        if(arbre->type_arbre_t==MON_FLECHE){
           
           acc_temp_instruction++;
        }
        if(arbre->fils_t->type_arbre_t==MON_OPERATION && arbre->fils_t->frere_t->type_arbre_t==MON_OPERATION)
        {
            if(!strcmp(arbre->fils_t->frere_t->label,"+-*") )  {
               
              acc_temp_instruction++;
                if(!strcmp(arbre->fils_t->label,"+-*")) {
                  
                  acc_temp_instruction++;
                }
                else{
                   
                   acc_temp_instruction++;
                }
            }else{
                
                acc_temp_instruction++;
                if(!strcmp(arbre->fils_t->label,"+-*")){
                   
                    acc_temp_instruction++;
                }else{
                  
                   acc_temp_instruction++;
                }
            }
        }else if(arbre->type_arbre_t==MON_OPERATION && ( arbre->fils_t->type_arbre_t==MON_OPERATION || arbre->fils_t->frere_t->type_arbre_t==MON_OPERATION)){   
                 if(!strcmp(arbre->fils_t->label,"+-*")){
                   
                   acc_temp_instruction++;
                }else{
                   
                    acc_temp_instruction++;
                }
            }
            parcoursArbreInstruction(arbre->fils_t,fd_c);   
            if(arbre->frere_t!=NULL) {
                parcoursArbreInstruction(arbre->frere_t,fd_c);       
            }
    }
}*/
void parcoursVariable(){
    
    struct _arbre *frere_courant = Program->fils_t;
    while(frere_courant->type_arbre_t!=MON_FONCTION)  {
        frere_courant=frere_courant->frere_t;
    }
    struct _symbole *table_courante = frere_courant->symbol_t;
    
}