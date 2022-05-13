#include "structure.h"

int ACC = 0;

extern int yylineno;
int flag = 0;
int acc_new_temp = 1;
int acc_temp_declaration=1;
int acc_temp_instruction=1;
int acc_temp_declaration_etiquette=1;
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
    nouveau_symbole->size=sizeof(int);
    nouveau_symbole->adresse=0;
    nouveau_symbole->frere = NULL;
    nouveau_symbole->var_or_func=0;
    nouveau_symbole->extern_or_no = 1;
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
    erreur("la structure n'est pas defini ",label);
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
    int incr = 0;
    if(courant->contenu != NULL) {              
        struct _symbole *contenu_courant = courant->contenu;
        while(contenu_courant != NULL) {
            if(!strcmp(membre_rechercher,contenu_courant->label)){
                contenu_courant->adresse=incr;
                return contenu_courant;
            }                  
            contenu_courant=contenu_courant->frere;
            incr = incr + sizeof(int); 

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
    printf("Type_arbre_t : [%d]",un_arbre->type_arbre_t);
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
        printf("\n");
    }else{   
       printf("Impossible de supprimer le fichier\n");   
    }
}
/*
void new_temp(char *str,size_t len){
    snprintf(str,len,"_var%d",acc_new_temp);
    str[len-1]='\0';
    acc_new_temp++;
}*/
////TODO 
/*
réponse du prof par rapport à fact
fonction récursive

*/
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
        if(symbole_arbre->extern_or_no==0)
        {
            if (!strcmp(symbole_arbre->type_symbol, "PTR")){
                fprintf(fd_c, "extern void *%s", symbole_arbre->label);
            }else {
                if(!strcmp(symbole_arbre->type_symbol,"VOID")){
                    fprintf(fd_c,"extern void %s",symbole_arbre->label);
                }
                else
                {
                    fprintf(fd_c, "extern int %s", symbole_arbre->label);
                }
            }
            if(symbole_arbre->nb_param==-1)
            {

            }
            else if(symbole_arbre->nb_param>0){ 
                fprintf(fd_c,"(");
            int incr = 0;
            struct _symbole *param = symbole_arbre->param_t;
            
                if(!strcmp(param->type_symbol,"PTR")) {
                    fprintf(fd_c,"void *%s",param->label);
                }else{
                    fprintf(fd_c,"int %s",param->label);
            }
            incr++;
            while(incr<symbole_arbre->nb_param){
                param=param->frere;
                if(!strcmp(param->type_symbol,"PTR")) {
                    fprintf(fd_c,", void *%s",param->label); 
                }else{
                    fprintf(fd_c,", int %s",param->label);
                }  
                    incr++; 
                }
            fprintf(fd_c,")");
            }
            fprintf(fd_c,";\n");
        }//
        else if(symbole_arbre->nb_param>=0) 
        {
            if (!strcmp(symbole_arbre->type_symbol, "PTR")){
                fprintf(fd_c, "void *(*%s)(", symbole_arbre->label);
            } else
        
             {  
                if(!strcmp(symbole_arbre->type_symbol,"VOID")){
                    fprintf(fd_c," void %s",symbole_arbre->label);
                }else
                {
                    fprintf(fd_c, " int %s", symbole_arbre->label);
                }
            }
            if(symbole_arbre->nb_param>0){ 
                int incr = 0;
                struct _symbole *param = symbole_arbre->param_t;
                
                    if(!strcmp(param->type_symbol,"PTR")) {
                        fprintf(fd_c,"void *%s",param->label);
                    }else{
                        fprintf(fd_c,"int %s",param->label);
                    }
                incr++;
                while(incr<symbole_arbre->nb_param){
                    param=param->frere;
                    if(!strcmp(param->type_symbol,"PTR")) {
                        fprintf(fd_c,", void *%s",param->label); 
                    }else{
                        fprintf(fd_c,", int %s",param->label);
                    }  
                    incr++; 
                    }
            }
     fprintf(fd_c,");\n");
        }else
            {
            if (!strcmp(symbole_arbre->type_symbol, "PTR")){
                fprintf(fd_c, "void *%s ;\n", symbole_arbre->label);
            }else {
                if(!strcmp(symbole_arbre->type_symbol,"VOID")){
                    fprintf(fd_c,"void %s;\n",symbole_arbre->label);
                }else
                {
                    fprintf(fd_c, "int %s;\n", symbole_arbre->label);
                }
            }
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
        if(symbole_arbre->extern_or_no==0)
        {
            if (!strcmp(symbole_arbre->type_symbol, "PTR")){
            fprintf(fd_c, "extern void *%s", symbole_arbre->label);
            }else {
                if(!strcmp(symbole_arbre->type_symbol,"VOID")){
                    fprintf(fd_c,"extern void %s",symbole_arbre->label);
                }else
                {fprintf(fd_c, "extern int %s", symbole_arbre->label);
                }
            }
            if(symbole_arbre->nb_param==-1)
            {
            }else
            if(symbole_arbre->nb_param>0){ 
                fprintf(fd_c,"(");
            int incr = 0;
            struct _symbole *param = symbole_arbre->param_t;
            
                if(!strcmp(param->type_symbol,"PTR")) {
                    fprintf(fd_c,"void *%s",param->label);
                }else{
                    fprintf(fd_c,"int %s",param->label);
            }
            incr++;
            while(incr<symbole_arbre->nb_param){
                param=param->frere;
                if(!strcmp(param->type_symbol,"PTR")) {
                    fprintf(fd_c,", void *%s",param->label); 
                }else{
                    fprintf(fd_c,", int %s",param->label);
                }  
                incr++; 
                }
            fprintf(fd_c,")");
            }
            fprintf(fd_c,";\n");
        }
     /*   else if(symbole_arbre->nb_param>0) 
        {
            if (!strcmp(symbole_arbre->type_symbol, "PTR")){
            fprintf(fd_c, "void *(*%s)(", symbole_arbre->label);
            }else {
            fprintf(fd_c, "int (%s)(", symbole_arbre->label);
            }
            if(symbole_arbre->nb_param>0){ 
            int incr = 0;
            struct _symbole *param = symbole_arbre->param_t;
            
                if(!strcmp(param->type_symbol,"PTR")) {
                    fprintf(fd_c,"void *%s",param->label);
                }else{
                    fprintf(fd_c,"int %s",param->label);
            }
            incr++;
            while(incr<symbole_arbre->nb_param){
                param=param->frere;
                if(!strcmp(param->type_symbol,"PTR")) {
                    fprintf(fd_c,", void *%s",param->label); 
                }else{
                    fprintf(fd_c,", int %s",param->label);
                }  
                incr++; 
                }
            }
         fprintf(fd_c,");\n");
        }*/
        else{
            if (!strcmp(symbole_arbre->type_symbol, "PTR")){
                fprintf(fd_c, "void *%s ;\n", symbole_arbre->label);
            }else {
                fprintf(fd_c, "int %s ;\n", symbole_arbre->label);
            }
        }
      }else {
        if (courant->type_arbre_t == MON_FONCTION){
            parcoursFonction(courant, fd_c);
        }
      }
    }
}

void parcoursFonction(arbre *arbre, FILE *fd_c){
    struct _symbole *symbole_arbre = arbre->symbol_t;
         
     if(!strcmp(symbole_arbre->type_symbol,"PTR")) {
        fprintf(fd_c,"void *%s(",symbole_arbre->label);
    }else{
        if(!strcmp(symbole_arbre->type_symbol,"VOID"))
        {
            fprintf(fd_c,"void %s(",symbole_arbre->label);
        }
        else{
fprintf(fd_c,"int %s(",symbole_arbre->label);
        }
        
    }
   //////////////////ARGUMENT FONCTION /////////////////////////
    if(symbole_arbre->nb_param>0 ){ 
        int incr = 0;
        struct _symbole *param = symbole_arbre->param_t;
        /*printf("param : %s %d\n",param->label,param->nb_param);
        if(param->nb_param>0) 
        {
            if (!strcmp(param->type_symbol, "PTR")){
                fprintf(fd_c, "void *(*%s)(", param->label);
            }else {
                fprintf(fd_c, "int (%s)(", param->label);
            }
            if(param->nb_param>0 || (symbole_arbre->contenu_adresse!=NULL && symbole_arbre->contenu_adresse->nb_param>0)){ 
                int incr = 0;
                struct _symbole *param2 = param->param_t;
            
                if(!strcmp(param->type_symbol,"PTR")) {
                    fprintf(fd_c,"void *%s",param->label);
                }else{
                    fprintf(fd_c,"int %s",param->label);
                }
                incr++;
                while(incr<param->nb_param){
                        param2=param2->frere;
                        if(!strcmp(param2->type_symbol,"PTR")) {
                            fprintf(fd_c,", void *%s",param2->label); 
                        }else{
                            fprintf(fd_c,", int %s",param2->label);
                        }  
                        incr++; 
                }
            }
        }
        else{*/
            if(!strcmp(param->type_symbol,"PTR")) {
                    fprintf(fd_c,"void *%s",param->label);
            }else{
                    fprintf(fd_c,"int %s",param->label);
            }
            incr++;
        
        while(incr<symbole_arbre->nb_param){
            param=param->frere;
            if(!strcmp(param->type_symbol,"PTR")) {
                fprintf(fd_c,", void *%s",param->label); 
            }else{
                fprintf(fd_c,", int %s",param->label);
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
                fprintf(fd_c,"\tint %s;\n",symbole_bloc_courant->label);
            }  
        
        while(symbole_bloc_courant->frere!=NULL) {
            symbole_bloc_courant=symbole_bloc_courant->frere;
            if(!strcmp(symbole_bloc_courant->type_symbol,"PTR")) {
                fprintf(fd_c,"\tvoid *%s;\n",symbole_bloc_courant->label);
            }else{
                fprintf(fd_c,"\tint %s;\n",symbole_bloc_courant->label);
            }  
        }
    }
    //\\\\\\\\\\\\\\\\\\FIN SYMBOLE DE BASE FONCTION//////////////
    
    // a -> a [Arbre MONFLECHE , a , a ]
    // a + a + a + a  [ Arbre :  a , [Arbre]]
    
    struct _arbre *arbre_corps = arbre->fils_t;
    if(arbre_corps->fils_t!=NULL)    {
        struct _arbre *arbre_instruction =arbre_corps->fils_t;
       // struct _arbre *arbre_instruction_courant =arbre_corps->fils_t;
        parcoursArbreDeclaration(arbre_corps,fd_c);
        fprintf(fd_c,"%s",arbre_corps->code);
        
        // parcoursArbreInstruction(arbre_corps,fd_c);
    }
    fprintf(fd_c,"}\n");
}
/*



*/
void parcoursArbreDeclaration(arbre *arbre, FILE *fd_c){ // refaire à  l'envers si premier fils pas op
    if(arbre->type_arbre_t==MON_BLOC)
    {
       // printf("Entree bloc :[%s]\n",arbre->fils_t->label);
        arbre->code=(char*)malloc(sizeof(char)*(65536));
        snprintf(arbre->code,2,"\0");
        arbre->var_code=malloc(256);
        if(arbre->fils_t!=NULL)
        {
            struct _arbre *courant = arbre->fils_t;
            parcoursArbreDeclaration(courant,fd_c);
          //  char *new_code=malloc(4096);
           /* snprintf(new_code,2,"\0");
            snprintf(new_code,65536,"%s",courant->code); 
            char* copy = malloc(4096);
            snprintf(copy,2,"\0");
            snprintf(copy,4096,"%s",new_code);*/
            
            if(courant->type_arbre_t==MON_APPEL)
            { 
                strcat(arbre->code,courant->code);
                strcat(arbre->code,"\t");
               
                strcat(arbre->code,courant->var_code);
                strcat(arbre->code,";\n");
              
            }
            else{
                strcat(arbre->code,courant->code);
               
            }
            //free(new_code); 
            courant=courant->frere_t;
            
            while(courant!=NULL)
            {                        
                parcoursArbreDeclaration(courant,fd_c);
                //char *new_code=malloc(4096);
                //snprintf(new_code,2,"\0");
                //snprintf(new_code,4096,"%s",courant->code);
                //char* copy = malloc(4096);
                //snprintf(copy,2,"\0");
                //snprintf(copy,4096,"%s",new_code);
                strcat(arbre->code,courant->code);
                if(courant->type_arbre_t==MON_APPEL)
                {
                    strcat(arbre->code,"\t");
                    strcat(arbre->code,courant->var_code);
                    strcat(arbre->code,";\n");
                }
                //free(new_code);
                courant=courant->frere_t;
                
            }
        }
       /* if(arbre->frere_t != NULL)
        {
            parcoursArbreDeclaration(arbre->frere_t,fd_c);
        }*/
       // printf("Bloc.code fin : {%s}\n",arbre->code);
        //printf("{{{{%s}}}}",arbre->code);
    }
    else if(arbre->type_arbre_t==MON_OPERATION)    {
        if(arbre->fils_t->frere_t==NULL) // unaire
        {
                parcoursArbreDeclaration(arbre->fils_t,fd_c);
                 arbre->var_code=malloc(50);
                    arbre->code=malloc(256);
                if(arbre->fils_t->type_arbre_t==MON_OPERATION)
                {
                    fprintf(fd_c,"\tint _var%d;\n",acc_temp_declaration);
                    snprintf(arbre->code,256,"\t_var%d=%s;\n",acc_temp_declaration,
                    arbre->fils_t->var_code);
                    snprintf(arbre->var_code,50,"%s%s_var%d",
                    arbre->fils_t->code,
                    arbre->label,
                    acc_temp_declaration
                    );
                    acc_temp_declaration++;
                }
                else{
                   
                    snprintf(arbre->code,256,"%s",arbre->fils_t->code);
                    snprintf(arbre->var_code,50,"%s%s%s",
                    arbre->fils_t->code,
                    arbre->label,
                    arbre->fils_t->var_code
                    );
                }
        }
        else
        if ( (arbre->fils_t->type_arbre_t==MON_OPERATION || arbre->fils_t->frere_t->type_arbre_t == MON_OPERATION) 
        ||(arbre->fils_t->type_arbre_t==MON_APPEL || arbre->fils_t->frere_t->type_arbre_t == MON_APPEL ) ){
                                         // (+ ( + ( + 1 2) 3) 4 )
                                            // (4 + (3 + ( 1 + 2 ) ) ) -> vrai
            parcoursArbreDeclaration(arbre->fils_t,fd_c);
            parcoursArbreDeclaration(arbre->fils_t->frere_t,fd_c);
            if( (arbre->fils_t->type_arbre_t==MON_OPERATION || arbre->fils_t->type_arbre_t == MON_APPEL )
            && (arbre->fils_t->frere_t->type_arbre_t==MON_OPERATION || arbre->fils_t->frere_t->type_arbre_t==MON_APPEL) )
            {
                fprintf(fd_c,"\tint _var%d;\n",acc_temp_declaration);
                fprintf(fd_c,"\tint _var%d;\n",acc_temp_declaration+1);
                arbre->var_code=malloc(50);
                arbre->code=malloc(256);
                char* new_var = malloc(50);
                char* new_var2 = malloc(50);
                snprintf(new_var,50,"_var%d",acc_temp_declaration);
                snprintf(new_var2,50,"_var%d",acc_temp_declaration+1); // (1+2) + ( 3 + 4)  (1+2).var_code = 1+2   (3+4).var_code = 3+4 var1 = 1+2 var2 = 3+4 a = var1 + var2  
                snprintf(arbre->code,256,"%s%s\t%s = %s;\n\t%s = %s;\n",//snprintf(arbre->code,2048,"A %s B %s C \tD %s E = F %s G ;\n",
                arbre->fils_t->code,
                arbre->fils_t->frere_t->code,
                new_var,
                arbre->fils_t->var_code,
                new_var2,
                arbre->fils_t->frere_t->var_code);
                snprintf(arbre->var_code,50," %s %s %s",//snprintf(arbre->var_code,2048,"H %s I %s J %s",
                new_var
                ,arbre->label
                ,new_var2);
                acc_temp_declaration++;
                acc_temp_declaration++;
            }
            else {
            struct _arbre *courant1;
            struct _arbre *courant2;
            int sens;
                if(arbre->fils_t->type_arbre_t == MON_OPERATION || arbre->fils_t->type_arbre_t == MON_APPEL)
                {
                    courant1 = arbre->fils_t;
                    courant2 = arbre->fils_t->frere_t;
                    sens = 0;
                }else if(arbre->fils_t->frere_t->type_arbre_t==MON_OPERATION || arbre->fils_t->frere_t->type_arbre_t == MON_APPEL)
                {
                    courant1 = arbre->fils_t->frere_t;
                    courant2 = arbre->fils_t;
                    sens = 1;
                }
                    // Choix de tjrs mettre INT \\  
                   // if(!strcmp(courant1->label,"+-*") ){
                     //   fprintf(fd_c,"\tvoid _var%d;\n",acc_temp_declaration);
                   // }else{
                        fprintf(fd_c,"\tint _var%d;\n",acc_temp_declaration);
                    //}
                        arbre->var_code=malloc(50);
                        arbre->code=malloc(256); // arbre->fils_t-> var_code = 1+2  code = 1+2  OBJECTIF = code -> var1 = 1+2 \n ;
                        char* new_var=malloc(50);
                        snprintf(new_var,50,"_var%d",acc_temp_declaration);
                        snprintf(arbre->code,256,"%s%s\t%s = %s;\n",courant1->code,
                        courant2->code,
                        new_var,
                        courant1->var_code); 
                    // printf("coucou : %s\n",arbre->fils_t->var_code);
                    if(sens){
                        snprintf(arbre->var_code,50,"%s %s %s",courant2->var_code,arbre->label,new_var);
                    }else{
                        snprintf(arbre->var_code,50,"%s %s %s",new_var,arbre->label,courant2->var_code);
                    } 
                    // snprintf(arbre->code,2048,"%s%s+ %s",arbre->fils_t->code,arbre->fils_t->var_code,arbre->fils_t->frere_t->var_code);
                    acc_temp_declaration++;
            }
        }else {
                parcoursArbreDeclaration(arbre->fils_t,fd_c); // generation var_code du fils de l'operation
                parcoursArbreDeclaration(arbre->fils_t->frere_t,fd_c); 
                /* var ou pas */ 
                arbre->var_code=malloc(50);
                arbre->code=malloc(256);
                snprintf(arbre->code,256,"%s%s",arbre->fils_t->code,arbre->fils_t->frere_t->code);
                snprintf(arbre->var_code,50,"%s %s %s",arbre->fils_t->var_code,
                arbre->label,
                arbre->fils_t->frere_t->var_code);
            }
            //snprintf(arbre->code,512,"%s %s %s",arbre->fils_t->var_code,arbre->label,arbre->fils_t->frere_t->var_code);
          //  parcoursArbreDeclaration(arbre->fils_t->frere_t,fd_c); // same pour frere
    
    }
    else if(arbre->type_arbre_t==MON_AFFECT)
    {       
        parcoursArbreDeclaration(arbre->fils_t,fd_c);
        parcoursArbreDeclaration(arbre->fils_t->frere_t,fd_c);
        arbre->var_code=malloc(50);
        arbre->code=malloc(256);
        if(arbre->fils_t->type_arbre_t==MON_FLECHE)
        {
            snprintf(arbre->code,256,"%s%s\t*%s = %s;\n",
            arbre->fils_t->code,
            arbre->fils_t->frere_t->code,
            arbre->fils_t->var_code,
            arbre->fils_t->frere_t->var_code);
            snprintf(arbre->var_code,256,"%s",arbre->fils_t->var_code);
        }
        else{
            snprintf(arbre->code,256,"%s%s\t%s = %s;\n",
            arbre->fils_t->code,
            arbre->fils_t->frere_t->code,
            arbre->fils_t->var_code,
            arbre->fils_t->frere_t->var_code);
            snprintf(arbre->var_code,256,"%s",arbre->fils_t->var_code);
        }
    }
   else if(arbre->type_arbre_t==MON_FLECHE){ // ( -> ( -> a6 c) c ) 
        parcoursArbreDeclaration(arbre->fils_t,fd_c);
        arbre->var_code=malloc(50);
        arbre->code=malloc(256);
        char* new_var=malloc(50);
        snprintf(new_var,50,"_var%d",acc_temp_declaration);
        fprintf(fd_c,"\tvoid *_var%d;\n",acc_temp_declaration);
        snprintf(arbre->var_code,50,"%s",new_var);
        snprintf(arbre->code,256,"%s\t%s = %s + %d;\n",
        arbre->fils_t->code,
        new_var,
        arbre->fils_t->var_code,
        arbre->symbol_t->adresse);
        acc_temp_declaration++;
        
   }else if(arbre->type_arbre_t==MON_APPEL)
   {
        arbre->var_code=malloc(50);
        arbre->code=malloc(256);
        
        if(arbre->fils_t->frere_t==NULL)
        {
           
            snprintf(arbre->var_code,50,"%s()",arbre->label);
           
        }
        else{
            
            snprintf(arbre->var_code,50,"%s(",arbre->label);
            struct _arbre *courant=arbre->fils_t->frere_t;
            parcoursArbreDeclaration(courant,fd_c);
            if(courant->type_arbre_t==MON_VARIABLE || courant->type_arbre_t==MON_CONSTANT )
            {
               
                char *new_temp=malloc(50);
                char *new_code=malloc(256);
                snprintf(new_temp,256,"%s",courant->label);
                //fprintf(fd_c,"\tint %s;\n",new_temp);
                snprintf(new_code,256,"%s",courant->code);
                char* copy = malloc(256);
                char* copy2 = malloc(50);
                snprintf(copy2,50,"%s",new_temp);
                snprintf(copy,256,"%s",new_code);
                strcat(arbre->code,copy);
                strcat(arbre->var_code,copy2);
                free(new_code);
                free(new_temp);
                courant=courant->frere_t;
                
               // acc_temp_declaration++;
            }
            else{
              
                char *new_temp=malloc(50);
                char *new_code=malloc(256);
                snprintf(new_temp,50,"_var%d",acc_temp_declaration);
                fprintf(fd_c,"\tint %s;\n",new_temp);
                snprintf(new_code,256,"%s\t%s = %s;\n",courant->code,new_temp,courant->var_code);
              
                char* copy = malloc(256);
                char* copy2 = malloc(50);
                snprintf(copy2,50,"%s",new_temp);
                snprintf(copy,256,"%s",new_code);
                strcat(arbre->code,copy);
                strcat(arbre->var_code,copy2);
                //free(new_code);
                //free(new_temp);
                courant=courant->frere_t;
                acc_temp_declaration++;
               
                
            }
            while(courant!=NULL)
            {
               
                parcoursArbreDeclaration(courant,fd_c);
                if(courant->type_arbre_t==MON_VARIABLE || courant->type_arbre_t==MON_CONSTANT )
                 {
                  
                    char *new_temp=malloc(50);
                    char *new_code=malloc(256);
                    snprintf(new_temp,256,"%s",courant->label);
                    //fprintf(fd_c,"\tint %s;\n",new_temp);
                    snprintf(new_code,256,"%s",courant->code);
                    char* copy = malloc(256);
                    char* copy2 = malloc(50);
                    snprintf(copy2,50,", %s",new_temp);
                    snprintf(copy,2,"%s",new_code);
                    strcat(arbre->code,copy);
                    strcat(arbre->var_code,copy2);
                    free(new_code);
                    free(new_temp);
                    courant=courant->frere_t;
                   
                 }else{
                    
                    char *new_temp=malloc(50);
                    char *new_code=malloc(256);
                    snprintf(new_temp,50,"_var%d",acc_temp_declaration);
                    fprintf(fd_c,"\tint %s;\n",new_temp);
                    snprintf(new_code,256,"%s\t%s = %s;\n",courant->code,new_temp,courant->var_code);
                    char* copy = malloc(256);
                    char* copy2 = malloc(256);
                    snprintf(copy2,256,", %s",new_temp);
                    snprintf(copy,256,"%s",new_code);
                    strcat(arbre->code,copy);
                    strcat(arbre->var_code,copy2);
                   // free(new_code);
                    //free(new_temp);
                    courant=courant->frere_t;
                    acc_temp_declaration++;
                 }
            }
    
            strcat(arbre->var_code,")");
             
        }
   } 
   else if(arbre->type_arbre_t==MON_IF)   {
       arbre->code = malloc(256);
       arbre->var_code=malloc(50);
        parcoursArbreDeclaration(arbre->fils_t,fd_c);
        parcoursArbreDeclaration(arbre->fils_t->frere_t,fd_c);
        if(arbre->fils_t->frere_t->frere_t!=NULL) // implique un else
        {
            parcoursArbreDeclaration(arbre->fils_t->frere_t->frere_t,fd_c);
            if(arbre->fils_t->type_arbre_t!=MON_OPERATION)
            {
                snprintf(arbre->code,256,"%s\tif (%s == 0) goto Lelse%d;\n\t{\n\t%s\t}\nLelse%d:\n\t{\n\t%s\t}\n",
                arbre->fils_t->code,
                arbre->fils_t->var_code,
                acc_temp_declaration_etiquette,
                arbre->fils_t->frere_t->code,
                acc_temp_declaration_etiquette,
                arbre->fils_t->frere_t->frere_t->code
            );
                acc_temp_declaration_etiquette++;
            }
            else
            {
                snprintf(arbre->code,256,"%s\tif (%s) goto Lelse%d;\n\t{\n\t%s\t}\nLelse%d:\n\t{\n\t%s\t}\n",
                arbre->fils_t->code,
                arbre->fils_t->var_code,
                acc_temp_declaration_etiquette,
                arbre->fils_t->frere_t->code,
                acc_temp_declaration_etiquette,
                arbre->fils_t->frere_t->frere_t->code
                );
                acc_temp_declaration_etiquette++;
            }
           // parcoursArbreDeclaration(arbre->frere_t,fd_c);
        }
        else{
            // parcoursArbreDeclaration(arbre->fils_t->frere_t->frere_t,fd_c);
            if(arbre->fils_t->type_arbre_t!=MON_OPERATION)
            {
                snprintf(arbre->code,256,"%s\tif (%s == 0) goto Lelse%d;\n\t{\n\t%s\t}\nLelse%d:\n\t", 
                arbre->fils_t->code,
                arbre->fils_t->var_code,
                acc_temp_declaration_etiquette,
                arbre->fils_t->frere_t->code,
                acc_temp_declaration_etiquette
                );
                acc_temp_declaration_etiquette++;
            }
            else
            {
                snprintf(arbre->code,256,"%s\tif (%s) goto Lelse%d;\n\t{\n\t%s\t}\nLelse%d:\n\t", 
                arbre->fils_t->code,
                arbre->fils_t->var_code,
                acc_temp_declaration_etiquette,
                arbre->fils_t->frere_t->code,
                acc_temp_declaration_etiquette
                );
                acc_temp_declaration_etiquette++;
            }
           // parcoursArbreDeclaration(arbre->frere_t,fd_c);
            
        }
   }
    else if(arbre->type_arbre_t==MON_ITERATION)
    {
        arbre->code=(char*)malloc(sizeof(char)*(65536));;
        arbre->var_code=malloc(50);
        parcoursArbreDeclaration(arbre->fils_t,fd_c);
        parcoursArbreDeclaration(arbre->fils_t->frere_t,fd_c);
        snprintf(arbre->code,10,'\0');
        if(arbre->fils_t->type_arbre_t!=MON_OPERATION)
        {
            snprintf(arbre->code,65536,"%s\tgoto Ltest%d;\nLBody%d :\n%sLtest%d:\n\tif(%s == 0) goto LBody%d\n",
            arbre->fils_t->code,
            acc_temp_declaration_etiquette,
            acc_temp_declaration_etiquette,
            arbre->fils_t->frere_t->code,
            acc_temp_declaration_etiquette,
            arbre->fils_t->var_code,
            acc_temp_declaration_etiquette
        );
        }
        else{
            snprintf(arbre->code,65536,"%s\tgoto Ltest%d;\nLBody%d :\n%sLtest%d:\n\tif(%s) goto LBody%d\n",
            arbre->fils_t->code,
            acc_temp_declaration_etiquette,
            acc_temp_declaration_etiquette,
            arbre->fils_t->frere_t->code,
            acc_temp_declaration_etiquette,
            arbre->fils_t->var_code,
            acc_temp_declaration_etiquette
        );
        }
        
    }
    else if(arbre->type_arbre_t==MON_RETURN)
    {
        
        arbre->code=malloc(256);
        arbre->var_code = malloc(50);
        if(arbre->fils_t==NULL)
        {
            snprintf(arbre->code,256,"\treturn;\n");
        }
        else{
            parcoursArbreDeclaration(arbre->fils_t,fd_c);
            snprintf(arbre->code,256,"%s\treturn %s;\n",
            arbre->fils_t->code,
            arbre->fils_t->var_code
            );
           
        }

    }
       
   else {
        arbre->var_code=malloc(50);
        arbre->code=malloc(256);
        snprintf(arbre->var_code,50,"%s",arbre->label);
      
        snprintf(arbre->code,10,""); // debordement memoire quelque part,
        // alors on écrase le debordement memoire en croisant les doigts pour que sa casse rien d'autre
        if(arbre->fils_t==NULL)   {
            if(arbre->frere_t!=NULL)  {
                //parcoursArbreDeclaration(arbre->frere_t,fd_c);  
            }
        }else if(arbre->fils_t!=NULL) {
           // parcoursArbreDeclaration(arbre->fils_t,fd_c);
            if(arbre->frere_t!=NULL) {
               // parcoursArbreDeclaration(arbre->frere_t,fd_c);
            }
        }
        // a = 1 + ( 2 + ( 3 + 4 ) ) 
        // a = 1 + 2;
    }
}

void parcoursArbreInstruction(arbre *arbre, FILE *fd_c){
     
    if(arbre->type_arbre_t==MON_BLOC)
    {
        fprintf(fd_c,"%s",arbre->code);
    }
    if(arbre->type_arbre_t==MON_AFFECT)
    {
        
        fprintf(fd_c,"%s",arbre->code);
       if(arbre->frere_t!=NULL){
        
            parcoursArbreInstruction(arbre->frere_t,fd_c);
        }

    }
   else if(arbre->type_arbre_t==MON_FLECHE){ // ( -> ( -> a6 c) c ) 
        parcoursArbreInstruction(arbre->fils_t,fd_c);
       // fprintf(fd_c,"void *_var%d;\n",acc_temp_declaration);
        //acc_temp_declaration++;
   }
   else if(arbre->type_arbre_t==MON_IF)   {
        if(arbre->fils_t->frere_t->frere_t!=NULL) // implique un else
        {
            fprintf(fd_c,"%s",arbre->code);
            fprintf(fd_c,"{\n");
            parcoursArbreInstruction(arbre->fils_t->frere_t,fd_c);
            fprintf(fd_c,"}\n");

            parcoursArbreInstruction(arbre->fils_t->frere_t->frere_t,fd_c);
        }
        else{
        }
   }
   else  {
        if(arbre->fils_t==NULL)   {
            if(arbre->frere_t!=NULL)  {
                parcoursArbreInstruction(arbre->frere_t,fd_c);
            }
        }else if(arbre->fils_t!=NULL) {
            parcoursArbreInstruction(arbre->fils_t,fd_c);
            if(arbre->frere_t!=NULL) {
                parcoursArbreInstruction(arbre->frere_t,fd_c);
            }
        }

        // a = 1 + ( 2 + ( 3 + 4 ) ) 
        // a = 1 + 2;
    }
}

void parcoursVariable(){   
    struct _arbre *frere_courant = Program->fils_t;
    while(frere_courant->type_arbre_t!=MON_FONCTION)  {
        frere_courant=frere_courant->frere_t;
    }
    struct _symbole *table_courante = frere_courant->symbol_t;
}