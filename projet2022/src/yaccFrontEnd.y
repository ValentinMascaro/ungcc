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
        | unary_operator unary_expression
        | SIZEOF unary_expression
        ;

unary_operator
        : '&'
        | '*'                 
        | '-'                    {printf("expression moins unaire");}   
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
                                                printf("%s %s \n",$1->label,$3->label);
                                                printf("param %d \n",$1->nb_param);}
        ;

declaration
        : declaration_specifiers declarator ';' {
                                                $2->type_symbol=$1;
                                                $$=$2;
                                                //printf("ACC : %d \n",ACC);
                                                verif_redefinition($2->label,TABLE[ACC]);
                                               // printf("uhkh");
                                                TABLE[ACC]=ajouter_symbole(TABLE[ACC],$2);
                                               
                                                } 
        | struct_specifier ';'
        ;

declaration_specifiers
        : EXTERN type_specifier
        | type_specifier        {$$=$1;}
        ;

type_specifier
        : VOID                  { $$="VOID"; /*TODO Doit fonctionner pour les fonctions ,ne doit pas fonctionner pour des variables*/ }
        | INT                   { $$="INT";  }
        | struct_specifier      {     }
        ;

struct_specifier
        : STRUCT IDENTIFIER '{' struct_declaration_list '}'
        | STRUCT '{' struct_declaration_list '}'
        | STRUCT IDENTIFIER     {}
        ;

struct_declaration_list
        : struct_declaration
        | struct_declaration_list struct_declaration
        ;

struct_declaration
        : type_specifier declarator ';' 
        ;

declarator
        : '*' direct_declarator
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
        | '{' declaration_list '}' { liberer_tables();}
        | '{' declaration_list statement_list  '}' { liberer_tables();}
        ;       

declaration_list
        : {nouvelle_adresse();}
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
                                                                TABLE[ACC]=ajouter_symbole(TABLE[ACC],$2);
                                                                liberer_tables();
                                                                liberer_tables();
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
