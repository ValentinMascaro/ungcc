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
}

%token <label> IDENTIFIER
%token <label> CONSTANT

%type <justepourlesswitch> unary_operator
%type <symbole> argument_expression_list
%type <symbole> struct_identifier_declarator
%type <symbole> struct_declaration_list
%type <symbole> struct_declaration
%type <symbole> struct_specifier
%type <symbole> parameter_list_creator
%type <symbole> function_definition
%type <symbole> parameter_declaration
%type <symbole> parameter_list
%type <symbole> expression
%type <symbole> unary_expression
%type <symbole> primary_expression
%type <symbole> postfix_expression
%type <symbole> multiplicative_expression
%type <symbole> additive_expression
%type <symbole> equality_expression
%type <symbole> declarator
%type <symbole> direct_declarator
%type <symbole> declaration
%type <symbole> declaration_list
%type <symbole> relational_expression
%type <symbole> logical_and_expression
%type <symbole> logical_or_expression

%type <type_t> declaration_specifiers
%type <type_t> type_specifier

%start program
%%

primary_expression
        : IDENTIFIER    {$$=search_by_label($1);}
        | CONSTANT      {$$=creer_symbole($1,"INT");}
        | '(' expression ')' {$$ = $2;}
        ;

postfix_expression
        : primary_expression  { $$ = $1;}
        | postfix_expression '(' ')' 
        {
                if(!(strcmp($1->type_symbol,"PTR")))
                {
                      if($1->contenu_adresse->nb_param == -1){
                        erreur("n'est pas une fonction",$1->label);
                      }
                       if($1->contenu_adresse->nb_param>0){
                        erreur("aucun argument donnée",$1->label);
                }        
                   
                }
                else {
                        if($1->nb_param == -1){
                                erreur("1 n'est pas une fonction",$1->label);
                        }
                        if($1->nb_param>0){
                                erreur("aucun argument donnée",$1->label);
                        }
                }
        }
        | postfix_expression '(' argument_expression_list ')' 
        {
               if(!(strcmp($1->type_symbol,"PTR")))
                {
                      if($1->contenu_adresse->nb_param == -1){
                              printf("%s nb_param %d \n",$1->contenu_adresse->label,$1->contenu_adresse->var_or_func);
                        erreur("2 n'est pas une fonction",$1->label);
                      }
                       verif_param($1->contenu_adresse,$3);
                   
                }
                else {
                        if($1->nb_param == -1){
                                erreur("3 n'est pas une fonction",$1->label);
                        }
                       verif_param($1,$3);
                }
               
        }        
        | postfix_expression PTR_OP IDENTIFIER 
        {
                if(strcmp($1->type_symbol,"PTR") ){
                        erreur("pas un pointeur vers structure",$1->label);
                }else{
                        struct _symbole *lastruct = search_by_label_struct($1->contenu_adresse->type_symbol);
                        struct _symbole *leMembre = find_membre(lastruct,$3);
                        $$ = leMembre;
                         //printf("TROUVER %s | %s \n",leMembre->label,leMembre->type_symbol);
                }
        }
        ;

argument_expression_list
        : expression {$$=creer_symbole($1->label,$1->type_symbol);}
        | argument_expression_list ',' expression 
        {
                $1 = ajouter_symbole($1,creer_symbole($3->label,$3->type_symbol));
                $$ = $1;
        }
        ;

unary_expression
        : postfix_expression { $$=$1; }
        | unary_operator unary_expression 
        {                                                           
                switch($1) {
                        case 1:$$=creer_symbole("adresse","adresse");break; /* & */
                        case 2: if(strcmp("PTR",$2->type_symbol)){   /* * */  
                                erreur("Ce n'est pas un pointeur",$2->label);
                                }
                                $$=creer_symbole("dereference",$2->contenu_adresse->type_symbol);
                                $$->nb_param = $2->nb_param;
                                printf("nb_param %d\n",$$->nb_param);
                                break;
                        case 3:
                                if(!strcmp($2->type_symbol,"INT")){
                                        $$=creer_symbole("MOINSUNAIRE","INT"); /* - */
                                        break;
                                }
                                erreur("Moins unaire avec un non int",$2->label);
                                                                
                                                        
                        }
                
        }

        | SIZEOF unary_expression       { $$ = creer_symbole($2->label,"INT");}
        | SIZEOF '(' type_specifier ')' {$$=creer_symbole("type_sizeof","INT");}
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
                $$ = creer_symbole("*","INT");
                 printf("%s * %s\n",$1->type_symbol,$3->type_symbol);
                verif_type($1,$3);
        }
        | multiplicative_expression '/' unary_expression 
        {
                $$ = creer_symbole("/","INT");
                 printf("%s / %s\n",$1->type_symbol,$3->type_symbol);
                verif_type($1,$3);
        }
        ;

additive_expression
        : multiplicative_expression
        | additive_expression '+' multiplicative_expression
        {
                printf("%s + %s\n",$1->type_symbol,$3->type_symbol);
                if( ( ( strcmp($1->type_symbol, "INT") ) && (strcmp($3->type_symbol, "PTR") ) ) 
                ||( ( strcmp($3->type_symbol, "INT") ) && (strcmp($1->type_symbol, "PTR") ) ) ){
                        $$=creer_symbole("INT_PTR","PTR");
                                        
                }
                if  ( ( strcmp($1->type_symbol, "INT") ) && (strcmp($3->type_symbol, "INT") ) ) {
                        $$=creer_symbole("INT_INT","INT");

                }
                if  ( !( strcmp($1->type_symbol, "PTR") ) && !(strcmp($3->type_symbol, "PTR") ) ) {
                       erreur("PTR + PTR = opération impossible", $1->label);
                }


        }
        | additive_expression '-' multiplicative_expression 
        {
                printf("%s - %s\n",$1->type_symbol,$3->type_symbol);
                if( ( ( strcmp($1->type_symbol, "INT") ) && (strcmp($3->type_symbol, "PTR") ) ) 
                ||( ( strcmp($3->type_symbol, "INT") ) && (strcmp($1->type_symbol, "PTR") ) ) ){
                        $$=creer_symbole("INT_PTR","PTR");
                                        
                }
                if  ( !( strcmp($1->type_symbol, "PTR") ) && !(strcmp($3->type_symbol, "PTR") ) ) {
                        $$=creer_symbole("PTR_PTR","INT");
                }
                                                                
        }
        ;

relational_expression
        : additive_expression   {$$=$1;}
        | relational_expression '<' additive_expression {$$=creer_symbole("x_<_y","INT");
         printf("%s < %s\n",$1->type_symbol,$3->type_symbol);}
                /*if  ( !( strcmp($1->type_symbol, "INT") ) && !(strcmp($3->type_symbol, "INT") ) ) 
                Si jamais on trouve une erreur on doit voir une execption*/
                //{
               
        | relational_expression '>' additive_expression {$$=creer_symbole("x_>_y","INT");
         printf("%s > %s\n",$1->type_symbol,$3->type_symbol);}
        | relational_expression LE_OP additive_expression{$$=creer_symbole("x_<=_y","INT");
         printf("%s <= %s\n",$1->type_symbol,$3->type_symbol);}
        | relational_expression GE_OP additive_expression{$$=creer_symbole("x_>=_y","INT");
         printf("%s >= %s\n",$1->type_symbol,$3->type_symbol);}
        ;

equality_expression
        : relational_expression { $$ = $1;}
        | equality_expression EQ_OP relational_expression {$$=creer_symbole("x_==_Ey","INT");
         printf("%s == %s\n",$1->type_symbol,$3->type_symbol);}
        | equality_expression NE_OP relational_expression  {$$=creer_symbole("x_!=_Ey","INT");
         printf("%s != %s\n",$1->type_symbol,$3->type_symbol);}
        ;

logical_and_expression
        : equality_expression {$$ = $1;}
        | logical_and_expression AND_OP equality_expression  {$$=creer_symbole("x_&&_Ey","INT");
         printf("%s && %s\n",$1->type_symbol,$3->type_symbol);}
        ;

logical_or_expression
        : logical_and_expression {$$ = $1;}
        | logical_or_expression OR_OP logical_and_expression  {$$=creer_symbole("x_||_Ey","INT");
         printf("%s || %s\n",$1->type_symbol,$3->type_symbol);}
        ;

expression
        : logical_or_expression        {$$ = $1;}         
        | unary_expression '=' expression
        {//verif_type_affectation($1,$3);
                printf("%s = %s\n",$1->type_symbol,$3->type_symbol);
                if($1->var_or_func==1)
                {
                        erreur("affectation vers une fonction impossible",$1->label);
                }
                $$=creer_symbole("affect",$1->type_symbol);
        }
        ;

declaration
        : declaration_specifiers declarator ';' 
        {
                
                if(!strcmp($1,"VOID") && flag == 0)
                {
                       // printf("FLAG : %d\n",flag);
                        erreur(" 1 type void sur declaration de variable",$2->label);
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
        fprintf(stderr,"%s %d\n",s,yylineno);
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
