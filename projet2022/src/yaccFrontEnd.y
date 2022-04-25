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

/*
%type <symbole> expression
%type <symbole> unary_expression
%type <symbole> primary_expression
%type <symbole> postfix_expression
%type <symbole> multiplicative_expression
%type <symbole> additive_expression
%type <symbole> equality_expression
%type <symbole> relational_expression
%type <symbole> logical_and_expression
%type <symbole> logical_or_expression
*/

%type <justepourlesswitch> unary_operator
%type <symbole> struct_identifier_declarator
%type <symbole> struct_declaration_list
%type <symbole> struct_declaration
%type <symbole> struct_specifier
%type <symbole> parameter_list_creator
%type <symbole> function_definition
%type <symbole> parameter_declaration
%type <symbole> parameter_list

%type <symbole> declarator
%type <symbole> direct_declarator
%type <symbole> declaration
%type <symbole> declaration_list


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
        : primary_expression  { $$ = $1;}
        | postfix_expression '(' ')' 
        { 
                if(!(strcmp($1->symbol_t->type_symbol,"PTR")))
                {
                      if($1->symbol_t->contenu_adresse->nb_param == -1){
                        erreur("n'est pas une fonction",$1->symbol_t->label);
                      }
                       if($1->symbol_t->contenu_adresse->nb_param>0){
                        erreur("aucun argument donnée",$1->symbol_t->label);
                }        
                   
                }
                else {
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
                if(!(strcmp($$->symbol_t->type_symbol,"PTR")))
                {    
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
               if(!(strcmp($1->symbol_t->type_symbol,"PTR")))
                {
                      if($1->symbol_t->contenu_adresse->nb_param == -1){
                              //printf("%s nb_param %d \n",$1->contenu_adresse->label,$1->contenu_adresse->var_or_func);
                        erreur(" n'est pas une fonction",$1->symbol_t->label);
                      }
                       verif_param($1->symbol_t->contenu_adresse,$3->symbol_t);
                   
                }
                else {
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
               // ajouter_frere($1,$3);
                $$=creer_arbre(copy,MON_APPEL,creer_symbole(copy,copy2),$3,NULL);
               
                
                $$->symbol_t->nb_param=-1;
                if(!(strcmp($$->symbol_t->type_symbol,"PTR")))
                {             
                         
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
                affiche_arbre($$);
               
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
                }
        }
        ;

argument_expression_list
        : expression { $$ = $1;
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
                        case 1: $$=creer_arbre("u&",MON_AUTRE,creer_symbole("adresse","adresse"),$2,NULL);break; /* & */
                        case 2: if(strcmp("PTR",$2->symbol_t->type_symbol)){   /* * */  
                                erreur("Ce n'est pas un pointeur",$2->label);
                                }
                                $$=creer_arbre("u*",MON_AUTRE,creer_symbole("dereference",$2->symbol_t->contenu_adresse->type_symbol),$2,NULL);
                                $$->symbol_t->nb_param = $2->symbol_t->nb_param;
                                //printf("nb_param %d\n",$$->nb_param);
                                break;
                        case 3:
                                if(!strcmp($2->symbol_t->type_symbol,"INT")){
                                        $$=creer_arbre("u-",MON_AUTRE,creer_symbole("MOINSUNAIRE","INT"),$2,NULL); /* - */
                                        break;
                                }
                                erreur("Moins unaire avec un non int",$2->symbol_t->label);
                                                                
                                                        
                        }
                
        }

        | SIZEOF unary_expression       { $$=creer_arbre("SIZE",MON_APPEL,creer_symbole($2->label,"INT"),$2,NULL);  } 
        | SIZEOF '(' type_specifier ')' { $$=creer_arbre("SIZE",MON_APPEL,creer_symbole("type_sizeof","INT"),creer_arbre($3,MON_CONSTANT,NULL,NULL,NULL),NULL);  } 
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
               $$=creer_arbre("*",MON_AUTRE, creer_symbole("*","INT"),$1,$3);
                 //printf("%s * %s\n",$1->type_symbol,$3->type_symbol);
                //verif_type($1,$3);
        }
        | multiplicative_expression '/' unary_expression 
        {
                ajouter_frere($1,$3);
                $$=creer_arbre("/",MON_AUTRE, creer_symbole("/","INT"),$1,$3);
                 //printf("%s / %s\n",$1->type_symbol,$3->type_symbol);
                //verif_type($1,$3);
        }
        ;

additive_expression
        : multiplicative_expression {$$=$1;}
        | additive_expression '+' multiplicative_expression
        {      
                printf("%s + %s\n",$1->symbol_t->type_symbol,$3->symbol_t->type_symbol);
                if( ( ( strcmp($1->symbol_t->type_symbol, "INT") ) && (strcmp($3->symbol_t->type_symbol, "PTR") ) ) 
                ||( ( strcmp($3->symbol_t->type_symbol, "INT") ) && (strcmp($1->symbol_t->type_symbol, "PTR") ) ) ){
                        ajouter_frere($1,$3);
                        $$=creer_arbre("+",MON_AUTRE,creer_symbole("INT_PTR","PTR"),$1,NULL);     
                }
                if ( !( strcmp($1->symbol_t->type_symbol, "INT") ) && !(strcmp($3->symbol_t->type_symbol, "INT") ) )
                {
                      
                        ajouter_frere($1,$3);
                        $$=creer_arbre("+",MON_AUTRE,creer_symbole("INT_INT","INT"),$1,NULL);    
                         //$$=creer_arbre("+",MON_AUTRE,creer_symbole("INT_INT","INT"),$1,NULL); ex: cas 2+3    
                }
                if  ( !( strcmp($1->symbol_t->type_symbol, "PTR") ) && !(strcmp($3->symbol_t->type_symbol, "PTR") ) ) {
                       erreur("PTR + PTR = opération impossible", $1->symbol_t->label);
                }
                


        }
        | additive_expression '-' multiplicative_expression 
        {
                //printf("%s - %s\n",$1->type_symbol,$3->type_symbol);
                if( ( ( strcmp($1->symbol_t->type_symbol, "INT") ) && (strcmp($3->symbol_t->type_symbol, "PTR") ) ) 
                ||( ( strcmp($3->symbol_t->type_symbol, "INT") ) && (strcmp($1->symbol_t->type_symbol, "PTR") ) ) ){
                        ajouter_frere($1,$3);
                        $$=creer_arbre("-",MON_AUTRE,creer_symbole("INT_PTR","PTR"),$1,$3);
                                        
                }
                if  ( !( strcmp($1->symbol_t->type_symbol, "PTR") ) && !(strcmp($3->symbol_t->type_symbol, "PTR") ) ) {
                        ajouter_frere($1,$3);
                        $$=creer_arbre("-",MON_AUTRE,creer_symbole("PTR_PTR","INT"),$1,$3);
                }
                                                                
        }
        ;

relational_expression
        : additive_expression   {$$=$1;}
        | relational_expression '<' additive_expression {ajouter_frere($1,$3);
                $$=creer_arbre("<",MON_AUTRE,creer_symbole("x_<_y","INT"),$1,NULL);
        // printf("%s < %s\n",$1->type_symbol,$3->type_symbol);
        }
                /*if  ( !( strcmp($1->type_symbol, "INT") ) && !(strcmp($3->type_symbol, "INT") ) ) 
                Si jamais on trouve une erreur on doit voir une execption*/
                //{
               
        | relational_expression '>' additive_expression {ajouter_frere($1,$3);
                                        $$=creer_arbre(">",MON_AUTRE,creer_symbole("x_>_y","INT"),$1,NULL);
       //  printf("%s > %s\n",$1->type_symbol,$3->type_symbol);
         }
        | relational_expression LE_OP additive_expression{ajouter_frere($1,$3);
                                       $$=creer_arbre("LE_OP",MON_AUTRE,creer_symbole("x_<=_y","INT"),$1,NULL);
        // printf("%s <= %s\n",$1->type_symbol,$3->type_symbol);
         }
        | relational_expression GE_OP additive_expression{ajouter_frere($1,$3);
                                         $$=creer_arbre("GE_OP",MON_AUTRE,creer_symbole("x_>=_y","INT"),$1,NULL);
        // printf("%s >= %s\n",$1->type_symbol,$3->type_symbol);
         }
        ;

equality_expression
        : relational_expression { $$ = $1;}
        | equality_expression EQ_OP relational_expression {ajouter_frere($1,$3);
                                                        $$=creer_arbre("EQ_OP",MON_AUTRE,creer_symbole("x_==_Ey","INT"),$1,NULL);
        // printf("%s == %s\n",$1->type_symbol,$3->type_symbol);
         }
        | equality_expression NE_OP relational_expression  {ajouter_frere($1,$3);
                                       $$=creer_arbre("NE_OP",MON_AUTRE,creer_symbole("x_!=_Ey","INT"),$1,NULL);
         //printf("%s != %s\n",$1->type_symbol,$3->type_symbol);
         }
        ;

logical_and_expression
        : equality_expression {$$ = $1;}
        | logical_and_expression AND_OP equality_expression  {ajouter_frere($1,$3);
                $$=creer_arbre("AND_OP",MON_AUTRE,creer_symbole("x_&&_Ey","INT"),$1,NULL);
        // printf("%s && %s\n",$1->type_symbol,$3->type_symbol);
         }
        ;

logical_or_expression
        : logical_and_expression {$$ = $1;}
        | logical_or_expression OR_OP logical_and_expression  {ajouter_frere($1,$3);
                                                $$=creer_arbre("OR_OP",MON_AUTRE,creer_symbole("x_||_Ey","INT"),$1,NULL);
         //printf("%s || %s\n",$1->type_symbol,$3->type_symbol);
         }
        ;
        // a = b = c = 2
        // ( = , a , ( = , b , ( = ,c , 2 )))
expression
        : logical_or_expression        {$$ = $1;}         
        | unary_expression '=' expression
        {//verif_type_affectation($1,$3);
                //printf("%s = %s\n",$1->type_symbol,$3->type_symbol);
                if($1->symbol_t->var_or_func==1)
                {
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
                
                if(!strcmp($1,"VOID") && flag == 0)
                {
                       // printf("FLAG : %d\n",flag);
                        erreur(" type void sur declaration de variable",$2->label);
                }
                
                verif_redefinition($2->label,TABLE[ACC]);
                
                if($2->contenu_adresse==NULL){
                      // printf("%s type = %s\n",$2->label,$1);
                        $2->type_symbol=$1;
                      
                }else{
                       
                        $2->contenu_adresse->type_symbol=$1;
                        
                }
                $$=$2; flag = 0;
                
               
               
               // TABLE[ACC]=ajouter_symbole(TABLE[ACC],$2);
                                                
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

        | STRUCT '{' struct_declaration_list '}' {$$=creer_symbole("PLACEHOLDER STRUCT VIDE","STRUCT");
                                                $$->contenu = $3;}
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
                $$->contenu_adresse=$2;
        }
        | direct_declarator {$$=$1;}
        
        ;

direct_declarator
        : IDENTIFIER       { $$=creer_symbole($1,NULL);
                                }   
        
         | IDENTIFIER '(' parameter_list_creator ')' { $$=creer_symbole_fonction($1,NULL,$3);
                                                       // printf("Nom fonction : %s, Nb_param : %d \n",$1,$$->nb_param);
                                                      if(flag == 0)
                                                      {
                                              
                                                      }
                                                      else
                                                      {
                                                             // printf("free the table for %s flag = %d \n",$1,flag);

                                                                liberer_tables(); // on viens de déclaré un extern donc on libere sa table d'arg
                                                                
                                                      }
                                                       
                                                         
                                                       /* TABLE[ACC]=ajouter_symbole($$,TABLE[ACC]);*/}
         | '(' '*' IDENTIFIER ')' '(' parameter_list_creator ')' { 
                                                                
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
               // affiche_memoire_symbole();
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
        : compound_statement 
        | expression_statement
        | selection_statement
        | iteration_statement
        | jump_statement 
        ;

compound_statement
        : '{'  '}'   {      }
        | '{' statement_list '}'
        | '{' declaration_list_local '}' {  liberer_tables();}
        | '{' declaration_list_local statement_list  '}' { liberer_tables();}   
        ;       
declaration_list_local 
        : {nouvelle_adresse();}
        | declaration_list  {nouvelle_adresse();TABLE[ACC]=ajouter_symbole(TABLE[ACC],$1);
        }
        ;
declaration_list
        : declaration {$$=$1;}
        | declaration_list declaration {$1=ajouter_symbole($1,$2);}
        ;

statement_list 
        : statement
        | statement_list statement
        ;

expression_statement
        : ';'
        | expression ';'
        ;

selection_statement
        : IF '(' expression ')' statement
        | IF '(' expression ')' statement ELSE statement
        ;

iteration_statement
        : WHILE '(' expression ')' statement
        | FOR '(' expression_statement expression_statement expression ')' statement
        ;

jump_statement
        : RETURN ';'
        | RETURN expression ';'
        ;

program
        : external_declaration {}
        | program external_declaration {}
        ;

external_declaration
        : function_definition {TABLE[ACC]=ajouter_symbole(TABLE[ACC],$1);}
        | declaration {
                if(strcmp($1->type_symbol,"STRUCT"))
                {
                       TABLE[ACC]=ajouter_symbole(TABLE[ACC],$1);}
                }
                
        ;

function_definition
        : declaration_specifiers declarator compound_statement
        {
              //  printf("DEBUT Nom : %s Type : %s nb_param : %d Contenu_adresse_nom : %s Contenu_adresse_type : %s Contenu_nb_param : %d\n",$2->label,$2->type_symbol,$2->nb_param,$2->contenu_adresse->label,$2->contenu_adresse->type_symbol,$2->contenu_adresse->nb_param);
                if($2->type_symbol == NULL){
                        $2->type_symbol=$1;
                        // $$=$2;
                }else{
                        $2->contenu_adresse->type_symbol = $1;
                }
                if(!(strcmp($2->type_symbol,"PTR")))
                {
                   if($2->contenu_adresse->var_or_func==0)
                        {
                                erreur(" attribut attendu",$2->label);
                        }      
                }        
                else if($2->var_or_func==0)
                {
                        erreur(" attribut attendu",$2->label);
                }
                /*
                if($2->type_symbol == NULL){
                        $2->type_symbol=$1;
                        // $$=$2;
                }else{
                        $2->contenu_adresse->type_symbol = $1;
                }
                */
                $$=$2;

                verif_redefinition($2,TABLE[ACC]);
               // printf("Fin fonction %s \n",$2->label);
                //printf("Nom : %s Type : %s nb_param : %d Contenu_adresse_nom : %s Contenu_adresse_type : %s Contenu_nb_param : %d\n",$$->label,$$->type_symbol,$$->nb_param,$$->contenu_adresse->label,$$->contenu_adresse->type_symbol,$$->contenu_adresse->nb_param);
               // affiche_memoire_symbole();
                liberer_tables();
                $$=$2;
                //TABLE[ACC]=ajouter_symbole(TABLE[ACC],$2);
                
                
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
        yyparse();
        printf("FIN\n");
        affiche_memoire_symbole();
   
        return 0;
}
