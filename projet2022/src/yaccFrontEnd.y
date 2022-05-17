%{
        extern int yylineno;
        #include "./src/structure.h"
%}

%token  SIZEOF
%token PTR_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP
%token EXTERN
%token INT VOID
%token STRUCT 
%token IF ELSE WHILE FOR RETURN

%union {
        char* label;
        char* type_t;
        int justepourlesswitch;
        struct _symbole *symbole;
        struct _arbre *arbre;
}

%token <label> IDENTIFIER
%token <label> CONSTANT

%type <arbre> expression
%type <arbre> postfix_expression
%type <arbre> argument_expression_list
%type <arbre> multiplicative_expression
%type <arbre> additive_expression
%type <arbre> equality_expression
%type <arbre> relational_expression
%type <arbre> logical_and_expression
%type <arbre> logical_or_expression
%type <arbre> unary_expression
%type <arbre> primary_expression
%type <arbre> compound_statement
%type <arbre> compound_statement2
%type <arbre> statement
%type <arbre> selection_statement
%type <arbre> expression_statement
%type <arbre> iteration_statement
%type <arbre> jump_statement
%type <arbre> statement_list
%type <arbre> function_definition

%type <justepourlesswitch> unary_operator
%type <symbole> struct_identifier_declarator
%type <symbole> struct_declaration_list
%type <symbole> struct_declaration
%type <symbole> struct_specifier
%type <symbole> parameter_list_creator

%type <symbole> parameter_declaration
%type <symbole> parameter_list
%type <symbole> declarator
%type <symbole> direct_declarator
%type <symbole> declaration
%type <symbole> declaration_list
%type <symbole> declaration_list_local

%type <type_t> declaration_specifiers
%type <type_t> type_specifier

%start program
%%

primary_expression
        : IDENTIFIER    {$$=creer_arbre($1,MON_VARIABLE,search_by_label($1),NULL,NULL);}
        | CONSTANT      {$$=creer_arbre($1,MON_CONSTANT,creer_symbole($1,"INT"),NULL,NULL);}
        | '(' expression ')' {$$ = $2;}
        ;

postfix_expression
        : primary_expression  { $$ = $1; }
        | postfix_expression '(' ')' 
        { 
                
                if(!(strcmp($1->symbol_t->type_symbol,"PTR"))) {
                      if($1->symbol_t->contenu_adresse->nb_param == -1){
                        erreur("n'est pas une fonction",$1->symbol_t->label);
                      }
                       if($1->symbol_t->contenu_adresse->nb_param>0){
                        erreur("aucun argument donnée",$1->symbol_t->label);
                       }                   
                }else {
                        if($1->symbol_t->nb_param == -1){
                                erreur("1 n'est pas une fonction",$1->symbol_t->label);
                        }
                        if($1->symbol_t->nb_param>0){
                                erreur("aucun argument donnée",$1->symbol_t->label);
                        }
                }
                
                char* buf = malloc(256);
                char* copy = malloc(256);
                snprintf(buf,256,"%s",$1->symbol_t->label);
                char* buf2 = malloc(256);
                char* copy2 = malloc(256);
                snprintf(buf2,256,"%s",$1->symbol_t->type_symbol);
                strcpy(copy,buf);
                strcpy(copy2,buf2);
                ajouter_frere($1,NULL);
                $$=creer_arbre(copy,MON_APPEL,creer_symbole(copy,copy2),$1,NULL);
                               
                $$->symbol_t->nb_param=-1;
                if(!(strcmp($$->symbol_t->type_symbol,"PTR")))  {    
                        char* buf3 = malloc(256);
                        char* copy3 = malloc(256);
                        snprintf(buf3,256,"%s",$1->symbol_t->contenu_adresse->label);
                        strcpy(copy3,buf3);
                        char* buf4 = malloc(256);
                        char* copy4 = malloc(256);
                        snprintf(buf4,256,"%s",$1->symbol_t->contenu_adresse->type_symbol);
                        strcpy(copy4,buf4);
                        $$->symbol_t->contenu_adresse = creer_symbole(copy3,copy4);
                        free(buf3);
                        free(buf4);
                }
                free(buf);
                free(buf2);   
               
        } 
        | postfix_expression '(' argument_expression_list ')' 
        {
               
               if(!(strcmp($1->symbol_t->type_symbol,"PTR"))) {
                      if($1->symbol_t->contenu_adresse->nb_param == -1){
                              //printf("%s nb_param %d \n",$1->contenu_adresse->label,$1->contenu_adresse->var_or_func);
                        erreur(" n'est pas une fonction",$1->symbol_t->label);
                      }
                       verif_param($1->symbol_t->contenu_adresse,$3->symbol_t);
                 
                }else { 
                        if($1->symbol_t->nb_param == -1){
                                erreur(" n'est pas une fonction",$1->symbol_t->label);
                        }
                       verif_param($1->symbol_t,$3->symbol_t);
                }
                char* buf = malloc(256);
                char* copy = malloc(256);
                snprintf(buf,256,"%s",$1->symbol_t->label);
                char* buf2 = malloc(256);
                char* copy2 = malloc(256);
                snprintf(buf2,256,"%s",$1->symbol_t->type_symbol);
                strcpy(copy,buf);
                strcpy(copy2,buf2);
                ajouter_frere($1,$3);
              
                $$=creer_arbre(copy,MON_APPEL,creer_symbole(copy,copy2),$1,NULL);
                $$->symbol_t->nb_param=-1;
                if(!(strcmp($$->symbol_t->type_symbol,"PTR"))) {             
                         
                        char* buf3 = malloc(256);
                        char* copy3 = malloc(256);
                        snprintf(buf3,256,"%s",$1->symbol_t->contenu_adresse->label);
                        strcpy(copy3,buf3);
                        char* buf4 = malloc(256);
                        char* copy4 = malloc(256);
                        snprintf(buf4,256,"%s",$1->symbol_t->contenu_adresse->type_symbol);
                        strcpy(copy4,buf4);
                        $$->symbol_t->contenu_adresse = creer_symbole(copy3,copy4);
                        free(buf3);
                        free(buf4);
                }
                free(buf);
                free(buf2);
                /////////////affiche arbre////////
               // affiche_arbre($$);
               
        }        
        | postfix_expression PTR_OP IDENTIFIER 
        {
                if(strcmp($1->symbol_t->type_symbol,"PTR") ){
                        erreur("pas un pointeur vers structure",$1->label);
                }else{
                        struct _symbole *lastruct = search_by_label_struct($1->symbol_t->contenu_adresse->type_symbol);
                        struct _symbole *leMembre = find_membre(lastruct,$3);
                        ajouter_frere($1,creer_arbre($3,MON_VARIABLE,leMembre,NULL,NULL));
                        $$ = creer_arbre("->",MON_FLECHE,leMembre,$1,NULL);
                         //printf("TROUVER %s | %s \n",leMembre->label,leMembre->type_symbol);
                        // affiche_arbreN($$);
                }
        }
        ;

argument_expression_list
        : expression 
        { 
                struct _symbole *copy = (symbole*) malloc(sizeof(symbole));
                copy->label = (malloc((strlen($1->symbol_t->label) + 1)  * sizeof(char)));
                copy->type_symbol = (malloc((strlen($1->symbol_t->type_symbol) + 1)  * sizeof(char)));
                
                strncpy(copy->label, $1->symbol_t->label, strlen($1->symbol_t->label) + 1);
                strncpy(copy->type_symbol,$1->symbol_t->type_symbol, strlen($1->symbol_t->type_symbol) + 1);
                copy->nb_param = $1->symbol_t->nb_param;
                copy->contenu = NULL;
                copy->contenu_adresse = NULL;
                copy->frere=NULL;
               
                $$ = creer_arbre($1->label,$1->type_arbre_t,copy,$1->fils_t,$1->frere_t);
                
                //$$=creer_arbre($1->symbol_t->label,MON_VARIABLE,creer_symbole($1->symbol_t->label,$1->symbol_t->type_symbol),NULL,NULL);
        }
        | argument_expression_list ',' expression 
        {       
                ajouter_frere($1,$3);      
                $1->symbol_t = ajouter_symbole($1->symbol_t,creer_symbole($3->symbol_t->label,$3->symbol_t->type_symbol));
                //$1 = ajouter_symbole($1->symbol_t,creer_arbre("AEL",MON_ARGEXL,$3->type_symbol));
                $$ = $1;
        }
        ;

unary_expression 
        : postfix_expression { $$=$1; }    
        | unary_operator unary_expression 
        {                                                           
                switch($1) {
                        case 1: $$=creer_arbre("&",MON_OPERATION,creer_symbole($2->label,"adresse"),$2,NULL);break; /* & */
                        case 2: if(strcmp("PTR",$2->symbol_t->type_symbol)){   /* * */  
                                erreur("Ce n'est pas un pointeur",$2->label);
                                }
                                if($2->symbol_t->nb_param>0)
                                {
                                        char *tmp = malloc(256);
                                        snprintf(tmp,256,"(*%s)",$2->symbol_t->label);
                                        char *copy = malloc(256);
                                        strcpy(copy,tmp);
                                        $$=creer_arbre("*",MON_OPERATION,creer_symbole(copy,$2->symbol_t->contenu_adresse->type_symbol),$2,NULL);        
                                        $$->symbol_t->nb_param = $2->symbol_t->nb_param;
                                        free(tmp);
                                        }
                                else{
                                        $$=creer_arbre("*",MON_OPERATION,creer_symbole($2->label,$2->symbol_t->contenu_adresse->type_symbol),$2,NULL);
                                        $$->symbol_t->nb_param = $2->symbol_t->nb_param;
                                }
                                
                               
                                break;
                        case 3:
                                if(!strcmp($2->symbol_t->type_symbol,"INT")){
                                        $$=creer_arbre("-",MON_OPERATION,creer_symbole($2->label,"INT"),$2,NULL); /* - */
                                        break;
                                }
                                erreur("Moins unaire avec un non int",$2->symbol_t->label);
                                                                
                                                        
                        }
                
        }

        | SIZEOF unary_expression       { 
                                        char *tmp = malloc(8);
                                        snprintf(tmp,8,"%d",sizeof(int));
                                        $$=creer_arbre(tmp,MON_CONSTANT,creer_symbole($2->label,"INT"),$2,NULL); 
                                        } 
        | SIZEOF '(' type_specifier ')' { 
                        if(!strcmp("INT",$3))
                        {       char *tmp = malloc(8);
                                snprintf(tmp,8,"%d",sizeof(int));
                                $$=creer_arbre(tmp,MON_CONSTANT,creer_symbole("type_sizeof","INT"),creer_arbre($3,MON_CONSTANT,NULL,NULL,NULL),NULL); 
                        }
                        else if(!strcmp("VOID",$3)){
                                erreur("sizeof void impossible",$3);     
                        }
                        else{ 
                                struct _symbole *courant = search_by_label_struct($3);
                                int incr = 0;
                                if(courant->contenu != NULL) {              
                                        struct _symbole *contenu_courant = courant->contenu;
                                        while(contenu_courant != NULL) {                
                                                contenu_courant=contenu_courant->frere;
                                                incr = incr + sizeof(int); 
                                        }
                                }
                                 char *tmp = malloc(8);
                                 snprintf(tmp,8,"%d",incr);
                                 $$=creer_arbre(tmp,MON_CONSTANT,creer_symbole("type_sizeof","INT"),creer_arbre($3,MON_CONSTANT,NULL,NULL,NULL),NULL);  
                        }
                  } 
        ;

unary_operator
        : '&'                   {$$=1;}
        | '*'                   {$$=2;}
        | '-'                   {$$=3;}  
         ;  
                

multiplicative_expression
        : unary_expression      {$$ = $1;}
        | multiplicative_expression '*' unary_expression  
        {
                ajouter_frere($1,$3);
                $$=creer_arbre("*",MON_OPERATION, creer_symbole("*","INT"),$1,NULL);
                 //printf("%s * %s\n",$1->type_symbol,$3->type_symbol);
                //verif_type($1,$3);
        }
        | multiplicative_expression '/' unary_expression 
        {
                ajouter_frere($1,$3);
                $$=creer_arbre("/",MON_OPERATION, creer_symbole("/","INT"),$1,NULL);
                 //printf("%s / %s\n",$1->type_symbol,$3->type_symbol);
                //verif_type($1,$3);
        }
        ;

additive_expression
        : multiplicative_expression {$$=$1;}
        | additive_expression '+' multiplicative_expression
        {      
                
               // printf("%s + %s\n",$1->symbol_t->type_symbol,$3->symbol_t->type_symbol);
                if( ( ( strcmp($1->symbol_t->type_symbol, "INT") ) && (strcmp($3->symbol_t->type_symbol, "PTR") ) ) 
                ||( ( strcmp($3->symbol_t->type_symbol, "INT") ) && (strcmp($1->symbol_t->type_symbol, "PTR") ) ) ){
                        ajouter_frere($1,$3);
                        $$=creer_arbre("+",MON_OPERATION,creer_symbole("INT_PTR","PTR"),$1,NULL);     
                }
                else if ( !( strcmp($1->symbol_t->type_symbol, "INT") ) && !(strcmp($3->symbol_t->type_symbol, "INT") ) ){
                        ajouter_frere($1,$3);
                        $$=creer_arbre("+",MON_OPERATION,creer_symbole("INT_INT","INT"),$1,NULL);    
                         //$$=creer_arbre("+",MON_AUTRE,creer_symbole("INT_INT","INT"),$1,NULL); ex: cas 2+3    
                }
                else if  ( !( strcmp($1->symbol_t->type_symbol, "PTR") ) && !(strcmp($3->symbol_t->type_symbol, "PTR") ) ) {
                       erreur("PTR + PTR = opération impossible", $1->symbol_t->label);
                }
        }
        | additive_expression '-' multiplicative_expression 
        {
               
               // printf("%s - %s\n",$1->symbol_t->type_symbol,$3->symbol_t->type_symbol);
                if( ( ( strcmp($1->symbol_t->type_symbol, "INT") ) && (strcmp($3->symbol_t->type_symbol, "PTR") ) ) 
                ||( ( strcmp($3->symbol_t->type_symbol, "INT") ) && (strcmp($1->symbol_t->type_symbol, "PTR") ) ) ){
                        
                        ajouter_frere($1,$3);
                        $$=creer_arbre("-",MON_OPERATION,creer_symbole("INT_PTR","PTR"),$1,NULL);
                                        
                }
                if  ( !( strcmp($1->symbol_t->type_symbol, "INT") ) && !(strcmp($3->symbol_t->type_symbol, "INT") ) ) {
                         
                        ajouter_frere($1,$3);
                        $$=creer_arbre("-",MON_OPERATION,creer_symbole("PTR_PTR","INT"),$1,NULL);
                }
                                                                
        }
        ;

relational_expression
        : additive_expression   {$$=$1;}
        | relational_expression '<' additive_expression 
        {
                ajouter_frere($1,$3);
                $$=creer_arbre("<",MON_OPERATION,creer_symbole("x_<_y","INT"),$1,NULL);
        // printf("%s < %s\n",$1->type_symbol,$3->type_symbol);
        }
                /*if  ( !( strcmp($1->type_symbol, "INT") ) && !(strcmp($3->type_symbol, "INT") ) ) 
                Si jamais on trouve une erreur on doit voir une execption*/
                //{
               
        | relational_expression '>' additive_expression 
        {
                ajouter_frere($1,$3);
                $$=creer_arbre(">",MON_OPERATION,creer_symbole("x_>_y","INT"),$1,NULL);
       //  printf("%s > %s\n",$1->type_symbol,$3->type_symbol);
        }
        | relational_expression LE_OP additive_expression
        {
                ajouter_frere($1,$3);
                $$=creer_arbre("<=",MON_OPERATION,creer_symbole("x_<=_y","INT"),$1,NULL);
        // printf("%s <= %s\n",$1->type_symbol,$3->type_symbol);
        }
        | relational_expression GE_OP additive_expression
        {
                ajouter_frere($1,$3);
                $$=creer_arbre(">=",MON_OPERATION,creer_symbole("x_>=_y","INT"),$1,NULL);
        // printf("%s >= %s\n",$1->type_symbol,$3->type_symbol);
         }
        ;

equality_expression
        : relational_expression { $$ = $1;}
        | equality_expression EQ_OP relational_expression 
        {
                ajouter_frere($1,$3);
                $$=creer_arbre("==",MON_OPERATION,creer_symbole("x_==_Ey","INT"),$1,NULL);
        // printf("%s == %s\n",$1->type_symbol,$3->type_symbol);
        }
        | equality_expression NE_OP relational_expression  
        {
                ajouter_frere($1,$3);
                $$=creer_arbre("!=",MON_OPERATION,creer_symbole("x_!=_Ey","INT"),$1,NULL);
         //printf("%s != %s\n",$1->type_symbol,$3->type_symbol);
        }
        ;

logical_and_expression
        : equality_expression {$$ = $1;}
        | logical_and_expression AND_OP equality_expression  
        {
                ajouter_frere($1,$3);
                $$=creer_arbre("&&",MON_OPERATION,creer_symbole("x_&&_Ey","INT"),$1,NULL);
        // printf("%s && %s\n",$1->type_symbol,$3->type_symbol);
        }
        ;

logical_or_expression
        : logical_and_expression {$$ = $1;}
        | logical_or_expression OR_OP logical_and_expression  
        {
                ajouter_frere($1,$3);
                $$=creer_arbre("||",MON_OPERATION,creer_symbole("x_||_Ey","INT"),$1,NULL);
         //printf("%s || %s\n",$1->type_symbol,$3->type_symbol);
        }
        ;
        // a = b = c = 2
        // ( = , a , ( = , b , ( = ,c , 2 )))
expression
        : logical_or_expression        {$$ = $1;}         
        | unary_expression '=' expression
        {//verif_type_affectation($1,$3);
             //   printf("%s = %s\n",$1->symbol_t->type_symbol,$3->symbol_t->type_symbol);
                if($1->symbol_t->var_or_func==1) {
                        erreur("affectation vers une fonction impossible",$1->label);
                }            
                
                ajouter_frere($1,$3);
                $$ = creer_arbre("=",MON_AFFECT,creer_symbole("affect",$1->symbol_t->type_symbol),$1,NULL);
                // $$ = creer_arbre("=",MON_AFFECT,creer_symbole("affect",$1->type_symbol),NULL,NULL);           
              
        }
        ;

declaration
        : declaration_specifiers declarator ';' 
        {
                
                if(!strcmp($1,"VOID") && flag == 0){
                        erreur(" type void sur declaration de variable",$2->label);
                }  
              //  verif_redefinition($2->label,TABLE[ACC]);//tds
                if($2->contenu_adresse==NULL){
                        $2->type_symbol=$1;
                }else{   
                        $2->contenu_adresse->type_symbol=$1;       
                }
                $$=$2; flag = 0;
                 
        } 
        | struct_specifier ';'  {}
        ;

declaration_specifiers
        : EXTERN type_specifier {$$=$2;flag = 1;}
        | type_specifier        {$$=$1;}
        ;

type_specifier
        : VOID                  { $$="VOID";}
        | INT                   { $$="INT";}
        | struct_specifier      { $$=$1->label;}
        ;
struct_identifier_declarator
        : STRUCT IDENTIFIER 
        {
                char* buf = malloc(256);
                snprintf(buf,256," \"struct\" %s",$2);
                char* copy = malloc(256);
                strcpy(copy,buf);
                $$=creer_symbole(copy,"STRUCT");
                //$$->contenu=$4;
                verif_redefinition($$->label,TABLE[ACC]);
                TABLE[ACC]=ajouter_symbole($$,TABLE[ACC]);
               // affiche_memoire_symbole();     
                free(buf);
        }
struct_specifier
        : struct_identifier_declarator '{' struct_declaration_list '}' 
        {     
                $1->contenu = $3;
                $$=$1;
        }

        | STRUCT '{' struct_declaration_list '}' 
        {
                $$=creer_symbole("PLACEHOLDER STRUCT VIDE","STRUCT");
                $$->contenu = $3;
        }
        | STRUCT IDENTIFIER     
        {
               
                char* buf = malloc(256);
                snprintf(buf,256," \"struct\" %s",$2);
                char* copy = malloc(256);
                strcpy(copy,buf);
                search_by_label_struct(copy);
                $$=creer_symbole(copy,NULL);
                free(buf);

        } 
        ;

struct_declaration_list
        : struct_declaration {$$=$1;}
        | struct_declaration_list struct_declaration
        { 
                verif_redefinition($2->label,$1);        
                $1=ajouter_symbole($1,$2);
                $$=$1;
        }
        | {$$=NULL;}
        ;

struct_declaration
        : type_specifier declarator ';' 
        {              
                char *buf = malloc(256);
                char *substring=malloc(256);
                strcpy(buf,$1);
                substring= strtok(buf,"\"");
                substring= strtok(NULL,"\"");
//printf("the thing in between quotes is '%s'\n", substring); merci https://stackoverflow.com/questions/19555434/how-to-extract-a-substring-from-a-string-in-c
                if(substring != NULL){
                        if(!strcmp(substring,"struct")){
                                if($2->type_symbol==NULL){
                                        erreur("Declaration de structure sans pointeur",$2->label);
                                }
                        }
                }
                if($2->contenu_adresse==NULL){
                        $2->type_symbol=$1;
                }else{
                        $2->contenu_adresse->type_symbol=$1;
                        if(!strcmp($2->contenu_adresse->type_symbol,"VOID")){
                                erreur("void sur declaration de pointeur de variable",$2->label);
                        }
                }
                $$=$2;
                if(!strcmp($$->type_symbol,"VOID")){
                        erreur("type void sur declaration de variable",$$->label);
                }
                free(buf);
        }
        ;


declarator
        : '*' direct_declarator 
        {
                $$=creer_symbole($2->label,"PTR");
                $$->extern_or_no = $2->extern_or_no;
                $$->var_or_func = $2->var_or_func;
                $$->nb_param=$2->nb_param;
                $$->param_t = $2->param_t;
                $$->contenu_adresse=$2;
        }
        | direct_declarator {$$=$1;}
        
        ;

direct_declarator
        : IDENTIFIER       { $$=creer_symbole($1,NULL);
                               if(flag==1)
                               {
                                       $$->extern_or_no=0;
                               } 
                           }   
        
        | IDENTIFIER '(' parameter_list_creator ')' { 
                
                $$=creer_symbole_fonction($1,"INT",$3);
                if(flag == 0)  {
                       
                        TABLE[0]=ajouter_symbole(TABLE[0],$$); // tds 
                      
                }else{
                        $$->extern_or_no = 0;
                         verif_redefinition($1,TABLE[0]);
                         liberer_tables(); // on viens de déclaré un extern donc on libere sa table d'arg
                }
                    }
        | '(' '*' IDENTIFIER ')' '(' parameter_list_creator ')' 
        { 
                $$=creer_symbole_fonction($3,"PTR",$6);
                $$->contenu_adresse=creer_symbole($3,NULL); 
                liberer_tables();
                $$->var_or_func=0;
        }                                                        
       
        ;
parameter_list_creator
        : parameter_list        
        {  
                nouvelle_adresse();
                TABLE[ACC]=ajouter_symbole(TABLE[ACC],$1);
                $$=$1;
        }
        | 
        {
                nouvelle_adresse(); 
                $$=NULL;
        }

parameter_list
        : parameter_declaration {$$=$1;}
        | parameter_list ',' parameter_declaration 
        {
                verif_redefinition($3->label,$1);
                $1=ajouter_symbole($1,$3);
                $$=$1;
        }
        ;

parameter_declaration
       : declaration_specifiers declarator 
        {  
                //verif_redefinition($2->label,TABLE[ACC]);
                if($2->contenu_adresse==NULL){
                        $2->type_symbol=$1;
                      
                }else{
                      $2->contenu_adresse->type_symbol=$1;
                }
                $$=$2;                                             
        } 
        | struct_specifier ';'  {}
        ;

statement
        : compound_statement {$$=$1;}
        | expression_statement {$$=$1;}
        | selection_statement {$$=$1;}
        | iteration_statement {$$=$1;}
        | jump_statement {$$=$1;}
        ;

compound_statement
        : '{'  '}'   { $$ = creer_arbre("corps",MON_BLOC,NULL,NULL,NULL);     }
        | '{' statement_list '}' {$$ = creer_arbre("corps",MON_BLOC,NULL,$2,NULL); }
       ;
compound_statement2
        : '{'  '}'   { $$ = creer_arbre("corps",MON_BLOC,NULL,NULL,NULL);     }
        | '{' statement_list '}' {
               
                $$ = creer_arbre("corps",MON_BLOC,NULL,$2,NULL); }
        | '{' declaration_list_local '}' 
        {  
                struct _symbole *Copy_table = TABLE[ACC];
               // Copy_table = 
                $$=creer_arbre("corps",MON_BLOC,Copy_table,NULL,NULL); 
                //free(TABLE[ACC]);
                liberer_tables();
        }
        | '{' declaration_list_local statement_list  '}' 
        { 
               
                struct _symbole *Copy_table = TABLE[ACC];
               // Copy_table = 
                $$=creer_arbre("corps",MON_BLOC,Copy_table,$3,NULL); 
                //free(TABLE[ACC]);
                liberer_tables();    
        }   
        ;   
declaration_list_local 
        : {nouvelle_adresse(); $$ = NULL;}
        | declaration_list  
        {
                nouvelle_adresse();
                TABLE[ACC]=ajouter_symbole(TABLE[ACC],$1); $$ = $1;
        }        
        ;
declaration_list
        : declaration {$$=$1;}
        | declaration_list declaration {$1=ajouter_symbole($1,$2);}
        ;

statement_list 
        : statement {$$ = $1; }
        | statement_list statement 
        {
                ajouter_frere($1,$2);
                $$=$1;
        }
        ;

expression_statement
        : ';' {$$ = creer_arbre("0",MON_AUTRE,NULL,NULL,NULL);}
        | expression ';' { $$=$1;}
        ;

selection_statement
        : IF '(' expression ')' statement 
        { 
                
                if(!strcmp($3->label,"<"))
                {
                        $3->label = ">=";
                }
                else if(!strcmp($3->label,">"))
                {
                        $3->label = "<=";
                }
                else  if(!strcmp($3->label,"<="))
                {
                        $3->label = ">";
                }
                else if(!strcmp($3->label,">="))
                {
                        $3->label = "<";
                }
                else if(!strcmp($3->label,"=="))
                {
                        $3->label = "!=";
                }
                else if(!strcmp($3->label,"!="))
                {
                        $3->label = "==";
                }
                /////////////////echange de condition gauche
                // CAS &&
                if(!strcmp($3->label,"&&"))
                {
                        if(!strcmp($3->fils_t->label,"<"))
                        {
                                $3->fils_t->label = ">=";
                        }
                        else if(!strcmp($3->fils_t->label,">"))
                        {
                                $3->fils_t->label = "<=";
                        }
                        else  if(!strcmp($3->fils_t->label,"<="))
                        {
                                $3->fils_t->label = ">";
                        }
                        else if(!strcmp($3->fils_t->label,">="))
                        {
                                $3->fils_t->label = "<";
                        }
                        else if(!strcmp($3->fils_t->label,"=="))
                        {
                                $3->fils_t->label = "!=";
                        }
                        else if(!strcmp($3->fils_t->label,"!="))
                        {
                                $3->fils_t->label = "==";
                        }
                /////////////////echange de condition gauche

                /////////////////echange de condition droite
                        if(!strcmp($3->fils_t->frere_t->label,"<"))
                        {
                                $3->fils_t->frere_t->label = ">=";
                        }
                        else if(!strcmp($3->fils_t->frere_t->label,">"))
                        {
                                $3->fils_t->frere_t->label = "<=";
                        }
                        else  if(!strcmp($3->fils_t->frere_t->label,"<="))
                        {
                                $3->fils_t->frere_t->label = ">";
                        }
                        else if(!strcmp($3->fils_t->frere_t->label,">="))
                        {
                                $3->fils_t->frere_t->label = "<";
                        }
                        else if(!strcmp($3->fils_t->frere_t->label,"=="))
                        {
                                $3->fils_t->frere_t->label = "!=";
                        }
                        else if(!strcmp($3->fils_t->frere_t->label,"!="))
                        {
                                $3->fils_t->frere_t->label = "==";
                        }
                /////////////////echange de condition droite
                struct _arbre *condition1=creer_arbre($3->fils_t->label,$3->fils_t->type_arbre_t,$3->fils_t->symbol_t,$3->fils_t->fils_t,NULL);
                struct _arbre *condition2=creer_arbre($3->fils_t->frere_t->label,$3->fils_t->frere_t->type_arbre_t,$3->fils_t->frere_t->symbol_t,$3->fils_t->frere_t->fils_t,NULL);
                
                struct _arbre *arbre_if = creer_arbre("IF",MON_IF,NULL,condition2,NULL);
                ajouter_frere(condition1,arbre_if);
                ajouter_frere(condition2,$5);
                $$ = creer_arbre("IF",MON_IF,NULL,condition1,NULL);
                
                }
                // CAS || 
                else if(!strcmp($3->label,"||"))
                {
                        if(!strcmp($3->fils_t->label,"<"))
                        {
                                $3->fils_t->label = ">=";
                        }
                        else if(!strcmp($3->fils_t->label,">"))
                        {
                                $3->fils_t->label = "<=";
                        }
                        else  if(!strcmp($3->fils_t->label,"<="))
                        {
                                $3->fils_t->label = ">";
                        }
                        else if(!strcmp($3->fils_t->label,">="))
                        {
                                $3->fils_t->label = "<";
                        }
                        else if(!strcmp($3->fils_t->label,"=="))
                        {
                                $3->fils_t->label = "!=";
                        }
                        else if(!strcmp($3->fils_t->label,"!="))
                        {
                                $3->fils_t->label = "==";
                        }
                /////////////////echange de condition gauche

                /////////////////echange de condition droite
                        if(!strcmp($3->fils_t->frere_t->label,"<"))
                        {
                                $3->fils_t->frere_t->label = ">=";
                        }
                        else if(!strcmp($3->fils_t->frere_t->label,">"))
                        {
                                $3->fils_t->frere_t->label = "<=";
                        }
                        else  if(!strcmp($3->fils_t->frere_t->label,"<="))
                        {
                                $3->fils_t->frere_t->label = ">";
                        }
                        else if(!strcmp($3->fils_t->frere_t->label,">="))
                        {
                                $3->fils_t->frere_t->label = "<";
                        }
                        else if(!strcmp($3->fils_t->frere_t->label,"=="))
                        {
                                $3->fils_t->frere_t->label = "!=";
                        }
                        else if(!strcmp($3->fils_t->frere_t->label,"!="))
                        {
                                $3->fils_t->frere_t->label = "==";
                        }
                /////////////////echange de condition droite
                struct _arbre *condition1=creer_arbre($3->fils_t->label,$3->fils_t->type_arbre_t,$3->fils_t->symbol_t,$3->fils_t->fils_t,NULL);
                struct _arbre *condition2=creer_arbre($3->fils_t->frere_t->label,$3->fils_t->frere_t->type_arbre_t,$3->fils_t->frere_t->symbol_t,$3->fils_t->frere_t->fils_t,NULL);
                
                struct _arbre *arbre_if = creer_arbre("IF",MON_IF,NULL,condition2,NULL);
                ajouter_frere(condition1,$5);
                ajouter_frere($5,arbre_if);
                struct _arbre *arbre_corps = creer_arbre($5->label,$5->type_arbre_t,$5->symbol_t,$5->fils_t,NULL);
                ajouter_frere(condition2,arbre_corps);
                
                $$ = creer_arbre("IF",MON_IF,NULL,condition1,NULL);
                
                }
                else
                {
                        ajouter_frere($3,$5);
                        $$=creer_arbre("IF",MON_IF,NULL,$3,NULL);
                }
                
        }
        | IF '(' expression ')' statement ELSE statement 
        {
               
                 if(!strcmp($3->label,"<"))
                {
                        $3->label = ">=";
                }
                else if(!strcmp($3->label,">"))
                {
                        $3->label = "<=";
                }
                else  if(!strcmp($3->label,"<="))
                {
                        $3->label = ">";
                }
                else if(!strcmp($3->label,">="))
                {
                        $3->label = "<";
                }
                else if(!strcmp($3->label,"=="))
                {
                        $3->label = "!=";
                }
                else if(!strcmp($3->label,"!="))
                {
                        $3->label = "==";
                }
                 /////////////////echange de condition gauche
                if(!strcmp($3->label,"&&"))
                {
                        if(!strcmp($3->fils_t->label,"<"))
                        {
                                $3->fils_t->label = ">=";
                        }
                        else if(!strcmp($3->fils_t->label,">"))
                        {
                                $3->fils_t->label = "<=";
                        }
                        else  if(!strcmp($3->fils_t->label,"<="))
                        {
                                $3->fils_t->label = ">";
                        }
                        else if(!strcmp($3->fils_t->label,">="))
                        {
                                $3->fils_t->label = "<";
                        }
                        else if(!strcmp($3->fils_t->label,"=="))
                        {
                                $3->fils_t->label = "!=";
                        }
                        else if(!strcmp($3->fils_t->label,"!="))
                        {
                                $3->fils_t->label = "==";
                        }
                /////////////////echange de condition gauche

                /////////////////echange de condition droite
                        if(!strcmp($3->fils_t->frere_t->label,"<"))
                        {
                                $3->fils_t->frere_t->label = ">=";
                        }
                        else if(!strcmp($3->fils_t->frere_t->label,">"))
                        {
                                $3->fils_t->frere_t->label = "<=";
                        }
                        else  if(!strcmp($3->fils_t->frere_t->label,"<="))
                        {
                                $3->fils_t->frere_t->label = ">";
                        }
                        else if(!strcmp($3->fils_t->frere_t->label,">="))
                        {
                                $3->fils_t->frere_t->label = "<";
                        }
                        else if(!strcmp($3->fils_t->frere_t->label,"=="))
                        {
                                $3->fils_t->frere_t->label = "!=";
                        }
                        else if(!strcmp($3->fils_t->frere_t->label,"!="))
                        {
                                $3->fils_t->frere_t->label = "==";
                        }
                /////////////////echange de condition droite
                struct _arbre *condition1=creer_arbre($3->fils_t->label,$3->fils_t->type_arbre_t,$3->fils_t->symbol_t,$3->fils_t->fils_t,NULL);
                struct _arbre *condition2=creer_arbre($3->fils_t->frere_t->label,$3->fils_t->frere_t->type_arbre_t,$3->fils_t->frere_t->symbol_t,$3->fils_t->frere_t->fils_t,NULL);
                
                struct _arbre *arbre_if = creer_arbre("IF",MON_IF,NULL,condition2,NULL);
                ajouter_frere(condition1,arbre_if);
                ajouter_frere(condition1,$7);
                ajouter_frere(condition2,$5);
                ajouter_frere(condition2,$7);
                $$ = creer_arbre("IF",MON_IF,NULL,condition1,NULL);
                
                }
                
                // CAS || 
                else if(!strcmp($3->label,"||"))
                {
                        if(!strcmp($3->fils_t->label,"<"))
                        {
                                $3->fils_t->label = ">=";
                        }
                        else if(!strcmp($3->fils_t->label,">"))
                        {
                                $3->fils_t->label = "<=";
                        }
                        else  if(!strcmp($3->fils_t->label,"<="))
                        {
                                $3->fils_t->label = ">";
                        }
                        else if(!strcmp($3->fils_t->label,">="))
                        {
                                $3->fils_t->label = "<";
                        }
                        else if(!strcmp($3->fils_t->label,"=="))
                        {
                                $3->fils_t->label = "!=";
                        }
                        else if(!strcmp($3->fils_t->label,"!="))
                        {
                                $3->fils_t->label = "==";
                        }
                /////////////////echange de condition gauche

                /////////////////echange de condition droite
                        if(!strcmp($3->fils_t->frere_t->label,"<"))
                        {
                                $3->fils_t->frere_t->label = ">=";
                        }
                        else if(!strcmp($3->fils_t->frere_t->label,">"))
                        {
                                $3->fils_t->frere_t->label = "<=";
                        }
                        else  if(!strcmp($3->fils_t->frere_t->label,"<="))
                        {
                                $3->fils_t->frere_t->label = ">";
                        }
                        else if(!strcmp($3->fils_t->frere_t->label,">="))
                        {
                                $3->fils_t->frere_t->label = "<";
                        }
                        else if(!strcmp($3->fils_t->frere_t->label,"=="))
                        {
                                $3->fils_t->frere_t->label = "!=";
                        }
                        else if(!strcmp($3->fils_t->frere_t->label,"!="))
                        {
                                $3->fils_t->frere_t->label = "==";
                        }
                /////////////////echange de condition droite
                struct _arbre *condition1=creer_arbre($3->fils_t->label,$3->fils_t->type_arbre_t,$3->fils_t->symbol_t,$3->fils_t->fils_t,NULL);
                struct _arbre *condition2=creer_arbre($3->fils_t->frere_t->label,$3->fils_t->frere_t->type_arbre_t,$3->fils_t->frere_t->symbol_t,$3->fils_t->frere_t->fils_t,NULL);
                
                struct _arbre *arbre_if = creer_arbre("IF",MON_IF,NULL,condition2,NULL);
                ajouter_frere(condition1,$5);
                ajouter_frere($5,arbre_if);
                
                struct _arbre *arbre_corps = creer_arbre($5->label,$5->type_arbre_t,$5->symbol_t,$5->fils_t,NULL);
                ajouter_frere(condition2,arbre_corps);
                ajouter_frere(condition2,$7);
                $$ = creer_arbre("IF",MON_IF,NULL,condition1,NULL);
                
                }
                else
                {
                        ajouter_frere($3,$5);
                        ajouter_frere($3,$7);
                        $$=creer_arbre("IF",MON_IF,NULL,$3,NULL);
                }
               
        }
        ;

iteration_statement
        : WHILE '(' expression ')' statement 
        {
                
                if(!strcmp($3->label,"&&"))
                {
                       if(!strcmp($3->fils_t->frere_t->label,"<"))
                        {
                                $3->fils_t->frere_t->label = ">=";
                        }
                        else if(!strcmp($3->fils_t->frere_t->label,">"))
                        {
                                $3->fils_t->frere_t->label = "<=";
                        }
                        else  if(!strcmp($3->fils_t->frere_t->label,"<="))
                        {
                                $3->fils_t->frere_t->label = ">";
                        }
                        else if(!strcmp($3->fils_t->frere_t->label,">="))
                        {
                                $3->fils_t->frere_t->label = "<";
                        }
                        else if(!strcmp($3->fils_t->frere_t->label,"=="))
                        {
                                $3->fils_t->frere_t->label = "!=";
                        }
                        else if(!strcmp($3->fils_t->frere_t->label,"!="))
                        {
                                $3->fils_t->frere_t->label = "==";
                        }
                        struct _arbre *condition1=creer_arbre($3->fils_t->label,$3->fils_t->type_arbre_t,$3->fils_t->symbol_t,$3->fils_t->fils_t,NULL);
                        struct _arbre *condition2=creer_arbre($3->fils_t->frere_t->label,$3->fils_t->frere_t->type_arbre_t,$3->fils_t->frere_t->symbol_t,$3->fils_t->frere_t->fils_t,NULL);
                        
                        struct _arbre *arbre_if = creer_arbre("IF",MON_IF,NULL,condition2,NULL);
                        ajouter_frere(condition1,arbre_if);
                        ajouter_frere(condition2,$5);
                        $$=creer_arbre("WHILE",MON_ITERATION,NULL,condition1,NULL);
                }
                else
                if(!strcmp($3->label,"||"))
                {
                       if(!strcmp($3->fils_t->frere_t->label,"<"))
                        {
                                $3->fils_t->frere_t->label = ">=";
                        }
                        else if(!strcmp($3->fils_t->frere_t->label,">"))
                        {
                                $3->fils_t->frere_t->label = "<=";
                        }
                        else  if(!strcmp($3->fils_t->frere_t->label,"<="))
                        {
                                $3->fils_t->frere_t->label = ">";
                        }
                        else if(!strcmp($3->fils_t->frere_t->label,">="))
                        {
                                $3->fils_t->frere_t->label = "<";
                        }
                        else if(!strcmp($3->fils_t->frere_t->label,"=="))
                        {
                                $3->fils_t->frere_t->label = "!=";
                        }
                        else if(!strcmp($3->fils_t->frere_t->label,"!="))
                        {
                                $3->fils_t->frere_t->label = "==";
                        }
                        struct _arbre *condition1=creer_arbre($3->fils_t->label,$3->fils_t->type_arbre_t,$3->fils_t->symbol_t,$3->fils_t->fils_t,NULL);
                        struct _arbre *condition2=creer_arbre($3->fils_t->frere_t->label,$3->fils_t->frere_t->type_arbre_t,$3->fils_t->frere_t->symbol_t,$3->fils_t->frere_t->fils_t,NULL);
                        
                        struct _arbre *arbre_if = creer_arbre("IF",MON_IF,NULL,condition2,NULL);
                        ajouter_frere(condition1,arbre_if);
                        ajouter_frere(condition2,$5);
                        $$=creer_arbre("WHILE",MON_ITERATION,NULL,condition1,NULL);
                }
                else
                {
                ajouter_frere($3,$5);
                $$=creer_arbre("WHILE",MON_ITERATION,NULL,$3,NULL);
                }

                       
        }
        | FOR '(' expression_statement expression_statement expression ')' statement
        {       
               
             
                if(!strcmp($4->label,"&&"))
                {
                        struct _arbre *condition1=creer_arbre($4->fils_t->label,$4->fils_t->type_arbre_t,$4->fils_t->symbol_t,$4->fils_t->fils_t,NULL);
                        struct _arbre *condition2=creer_arbre($4->fils_t->frere_t->label,$4->fils_t->frere_t->type_arbre_t,$4->fils_t->frere_t->symbol_t,$4->fils_t->frere_t->fils_t,NULL);
                        if(!strcmp(condition2->label,"<"))
                        {
                                condition2->label = ">=";
                        }
                        else if(!strcmp(condition2->label,">"))
                        {
                                condition2->label = "<=";
                        }
                        else  if(!strcmp(condition2->label,"<="))
                        {
                               condition2->label = ">";
                        }
                        else if(!strcmp(condition2->label,">="))
                        {
                               condition2->label = "<";
                        }
                        else if(!strcmp(condition2->label,"=="))
                        {
                                condition2->label = "!=";
                        }
                        else if(!strcmp(condition2->label,"!="))
                        {
                                condition2->label = "==";
                        }
                        struct _arbre *arbre_if = creer_arbre("IF",MON_IF,NULL,condition2,NULL);
                        
                        ajouter_frere(condition2,$7);
                       if($7->fils_t==NULL)
                        {
                                $7->fils_t=$5;
                        }else{
                         ajouter_frere($7->fils_t,$5);        
                         }
                         ajouter_frere(condition1,arbre_if);
                         struct _arbre *bouclepour = creer_arbre("FOR",MON_ITERATION,NULL,condition1,NULL);
                         ajouter_frere($3,bouclepour);
                          
                        $$ = $3;
                         
                }
                else if(!strcmp($4->label,"||"))
                {
                        struct _arbre *condition1=creer_arbre($4->fils_t->label,$4->fils_t->type_arbre_t,$4->fils_t->symbol_t,$4->fils_t->fils_t,NULL);
                        struct _arbre *condition2=creer_arbre($4->fils_t->frere_t->label,$4->fils_t->frere_t->type_arbre_t,$4->fils_t->frere_t->symbol_t,$4->fils_t->frere_t->fils_t,NULL);
                      if(!strcmp(condition2->label,"<"))
                        {
                                condition2->label = ">=";
                        }
                        else if(!strcmp(condition2->label,">"))
                        {
                                condition2->label = "<=";
                        }
                        else  if(!strcmp(condition2->label,"<="))
                        {
                               condition2->label = ">";
                        }
                        else if(!strcmp(condition2->label,">="))
                        {
                               condition2->label = "<";
                        }
                        else if(!strcmp(condition2->label,"=="))
                        {
                                condition2->label = "!=";
                        }
                        else if(!strcmp(condition2->label,"!="))
                        {
                                condition2->label = "==";
                        }
                        struct _arbre *arbre_if = creer_arbre("IF",MON_IF,NULL,condition2,NULL);
                        
                        ajouter_frere(condition2,$7);
                       if($7->fils_t==NULL)
                        {
                                $7->fils_t=$5;
                        }else{
                         ajouter_frere($7->fils_t,$5);        
                         }
                         ajouter_frere(condition1,arbre_if);
                         struct _arbre *bouclepour = creer_arbre("FOR",MON_ITERATION,NULL,condition1,NULL);
                         ajouter_frere($3,bouclepour);
                          
                        $$ = $3;
                         
                }
                else{
                        ajouter_frere($4,$7);
                        if($7->fils_t==NULL)
                        {
                                $7->fils_t=$5;
                        }else{
                         ajouter_frere($7->fils_t,$5);        
                         }
                         struct _arbre *bouclepour = creer_arbre("FOR",MON_ITERATION,NULL,$4,NULL);
                        ajouter_frere($3,bouclepour);
                        $$ = $3;
                }
                
                /* for(i=0;i<10;i=i+1)
                [Arbre : "=", i , 0]
                [Arbre : "FOR", [Arbre : < , i , 10] [ArbreA : = , i , [Arbre : + , i , 1]]]
                i = 0;
                goto Ltest1;
                LBody1 : 
                        i = i + 1;
                        corps :
                Ltest1 :
                        if( i < 10) goto LBody1
                
                */
        }
        ;

jump_statement
        : RETURN ';' {$$ = creer_arbre("return",MON_RETURN,NULL,NULL,NULL);}
        | RETURN expression ';' {$$ = creer_arbre("return",MON_RETURN,NULL,$2,NULL);}
        ;

program
        : external_declaration {}
        | program external_declaration {}
        ;

external_declaration
        : function_definition 
        {
                
                if(Program->fils_t->type_arbre_t == MON_NULL){
                        Program->fils_t = $1;
                         
                }else{
                        ajouter_frere(Program->fils_t,$1);    
                }
              //  TABLE[ACC]=ajouter_symbole(TABLE[ACC],$1->symbol_t); //tds
        }
        | declaration 
        {
                if(strcmp($1->type_symbol,"STRUCT")){
                       TABLE[ACC]=ajouter_symbole(TABLE[ACC],$1);
                        
                        if(Program->fils_t->type_arbre_t == MON_NULL){
                                Program->fils_t = creer_arbre($1->label,MON_VARIABLE,$1,NULL,NULL);
                         
                        }else{
                                ajouter_frere(Program->fils_t,creer_arbre($1->label,MON_VARIABLE,$1,NULL,NULL));
                        }
                       Program->symbol_t = TABLE[ACC];

                }           
        }
        ;       

function_definition
        : declaration_specifiers declarator compound_statement2
        {
                
                if($2->type_symbol == NULL || (!strcmp($2->type_symbol,"INT"))){
                        $2->type_symbol=$1;
                }else{
                        $2->contenu_adresse->type_symbol = $1;
                }
                if(!(strcmp($2->type_symbol,"PTR"))){
                   if($2->contenu_adresse->var_or_func==0){
                                erreur(" attribut attendu",$2->label);
                        }      
                }else if($2->var_or_func==0){
                        erreur(" attribut attendu",$2->label);
                }
               //$$=$2;
                //verif_redefinition($2,TABLE[ACC]);
                $$=creer_arbre($2->label,MON_FONCTION,$2,$3,NULL);
                liberer_tables();
                
        }
        ;

%%
int yyerror(char *s){
        fprintf(stderr,"%s Ligne : %d\n",s,yylineno);
        exit(1);
}

int main(void){
        /* compile projet ->
        flex lexFrontEnd.l
        yacc yaccFrontEnd.y -d
        gcc lex.yy.c y.tab.c structure.c -o testYacc */
        init();
        yyparse();
        //printf("--FIN--\n");
      //  affiche_arbre(Program);
        //printf("Symbole");
        //affiche_memoire_symbole();
        //printf("Parcours\n");
        //clean_file();
        creer_fichier_c(Program);
        
        //free(TABLE);
        free(Program);
        return 0;
}
