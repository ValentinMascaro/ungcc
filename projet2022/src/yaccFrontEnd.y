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
        struct _symbole *symbole;
}

%token <label> IDENTIFIER
%token <label> CONSTANT

%type <symbole> unary_operator

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
        : IDENTIFIER    {$$=search_by_label($1);
                        }
        | CONSTANT      {$$=creer_symbole($1,"INT");}
        | '(' expression ')' { $$ = $2;}
        ;

postfix_expression
        : primary_expression  { $$ = $1;}
        | postfix_expression '(' ')'
        | postfix_expression '(' argument_expression_list ')'
        | postfix_expression PTR_OP IDENTIFIER  {/* -> ? */ }
        ;

argument_expression_list
        : expression
        | argument_expression_list ',' expression
        ;

unary_expression
        : postfix_expression { $$=$1; }
        | unary_operator unary_expression {verif_type($1,$2);
                                                $$=creer_symbole("","");}
        | SIZEOF unary_expression
        ;

unary_operator
        : '&'
        | '*'                 
        | '-'                    {}   
        | 'PTR_OP'               { /* pointeur vers champ de structure manquant, on le rajoute pour avoir les 4 operateurs unaires*/}
         ;  
                

multiplicative_expression
        : unary_expression      {$$ = $1;}
        | multiplicative_expression '*' unary_expression  {$$ = creer_symbole("*","INT");
                                                                verif_type($1,$3);
                                                               }
        | multiplicative_expression '/' unary_expression {$$ = creer_symbole("/","INT");
                                                                verif_type($1,$3);
                                                                }
        ;

additive_expression
        : multiplicative_expression
        | additive_expression '+' multiplicative_expression {$$ = creer_symbole("+","INT");
                                                                verif_type($1,$3);
                                                                }
        | additive_expression '-' multiplicative_expression {$$ = creer_symbole("-","INT");
                                                                verif_type($1,$3);
                                                                }
        ;

relational_expression
        : additive_expression   {$$=$1;}
        | relational_expression '<' additive_expression
        | relational_expression '>' additive_expression
        | relational_expression LE_OP additive_expression
        | relational_expression GE_OP additive_expression
        ;

equality_expression
        : relational_expression { $$ = $1;}
        | equality_expression EQ_OP relational_expression
        | equality_expression NE_OP relational_expression
        ;

logical_and_expression
        : equality_expression {$$ = $1;}
        | logical_and_expression AND_OP equality_expression
        ;

logical_or_expression
        : logical_and_expression {$$ = $1;}
        | logical_or_expression OR_OP logical_and_expression
        ;

expression
        : logical_or_expression        {$$ = $1;}         
        | unary_expression '=' expression       {verif_type_affectation($1,$3);
                                                
                                                }
        ;

declaration
        : declaration_specifiers declarator ';' {
                                               
                                                
                                                
                                                verif_redefinition($2->label,TABLE[ACC]);
                                                if($2->contenu_adresse==NULL){
                                                         $2->type_symbol=$1;
                                                }
                                                else{
                                                        $2->contenu_adresse->type_symbol=$1;
                                                }
                                                $$=$2;
                                                TABLE[ACC]=ajouter_symbole(TABLE[ACC],$2);
                                                
                                                } 
        | struct_specifier ';'  {}
        ;

declaration_specifiers
        : EXTERN type_specifier
        | type_specifier        {$$=$1;
                                }
        ;

type_specifier
        : VOID                  { $$="VOID"; }
        | INT                   { $$="INT";  }
        | struct_specifier      {  $$=$1->label;
                                  }
        ;
struct_identifier_declarator
        : STRUCT IDENTIFIER {
                                       char* buf = malloc(256);
                                       snprintf(buf,256,"struct %s",$2);
                                       char* copy = malloc(256);
                                       strcpy(copy,buf);
                                       $$=creer_symbole(copy,"STRUCT");
                                       //$$->contenu=$4;
                                       verif_redefinition($$->label,TABLE[ACC]);
                                       TABLE[ACC]=ajouter_symbole($$,TABLE[ACC]);
                                       //affiche_memoire_symbole();     
                                       free(buf);
        }
struct_specifier
        : struct_identifier_declarator '{' struct_declaration_list '}' {
                                       /* TODO le struct_identifier ne doit pas permettre de trouver des * */
                                       $1->contenu = $3;
                                       $$=$1;
                                       /* char tmp2[103];
                                        sprintf(tmp2,"struct_%s",$2);
                                        $$=creer_symbole(tmp2,"STRUCT");
                                        printf("Nom de structure : %s \n",$$->label);
                                        $$->contenu = $4;
                                        TABLE[ACC]=ajouter_symbole($$,TABLE[ACC]);
                                        affiche_memoire_symbole(); */
                                        
        }
        | STRUCT '{' struct_declaration_list '}' {/* Attention pas de nom faire gaffe backend*/}
        | STRUCT IDENTIFIER     {
               
                char* buf = malloc(256);
                snprintf(buf,256,"struct %s",$2);
                char* copy = malloc(256);
                 strcpy(copy,buf);
                search_by_label(copy);
                $$=creer_symbole(copy,NULL);
                free(buf);
                /*printf("COUPABLE 2");
                char tmp[103]; // 97 '- 199_'
                sprintf(tmp,"struct_%s",$2);
                search_by_label_void(tmp);
                $$=creer_symbole(tmp,NULL);*/
                } 
        ;

struct_declaration_list
        : struct_declaration {$$=$1;}
        | struct_declaration_list struct_declaration { verif_redefinition($2->label,$1);
                                                        $1=ajouter_symbole($1,$2);
                                                       
                                                        $$=$1;}
        ;

struct_declaration
        : type_specifier declarator ';' {$2->type_symbol=$1;
                                        $$=$2;}
        ;

declarator
        : '*' direct_declarator {$$=creer_symbole($2->label,"PTR");
                                        $$->contenu_adresse=$2;}
        | direct_declarator {$$=$1;}
        ;

direct_declarator
        : IDENTIFIER       { $$=creer_symbole($1,NULL); }   
        | '(' declarator ')'
        | direct_declarator '(' parameter_list_creator ')' {$$=creer_symbole_fonction($1->label,NULL,$3);
                                                               
                                                               }
       
        ;
parameter_list_creator
        : parameter_list        {nouvelle_adresse();
                                 TABLE[ACC]=ajouter_symbole($$,TABLE[ACC]);
                                 $$=$1;}
        | {nouvelle_adresse();
                $$=NULL;}
parameter_list
        : parameter_declaration {$$=$1;}
        | parameter_list ',' parameter_declaration {verif_redefinition($3->label,$1);
                                                        $1=ajouter_symbole($1,$3);
                                                        $$=$1;}
        ;

parameter_declaration
        : declaration_specifiers declarator {$2->type_symbol=$1;
                                                $$=$2;}
        ;

statement
        : compound_statement 
        | expression_statement
        | selection_statement
        | iteration_statement
        | jump_statement 
        ;

compound_statement
        : '{'  '}'        
        | '{' statement_list '}'
        | '{' declaration_list_local '}' { liberer_tables();}
        | '{' declaration_list_local statement_list  '}' { liberer_tables();}   
        ;       
declaration_list_local 
        : {nouvelle_adresse;}
        | declaration_list declaration {nouvelle_adresse();}
        ;
declaration_list
        : {}
        | declaration_list declaration 
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
        : function_definition {}
        | declaration 
        ;

function_definition
        : declaration_specifiers declarator compound_statement {$2->type_symbol=$1;
                                                                $$=$2;
                                                                verif_redefinition($2,TABLE[ACC]);
                                                                liberer_tables();
                                                                TABLE[ACC]=ajouter_symbole(TABLE[ACC],$2);
                                                                }
        ;

%%
int yyerror(char *s)
{
        fprintf(stderr,"%s\n",s);
        exit(1);
}
int main(void)
{
        /* compile projet ->
        flex lexFrontEnd.l
        yacc yaccFrontEnd.y -d
        gcc lex.yy.c y.tab.c structure.c -o testYacc */
        yyparse();
        printf("FIN\n");
        affiche_memoire_symbole();
   
        return 0;
}
