%{
        extern int yylineno;
        #include "structure.h"
%}

%token IDENTIFIER CONSTANT SIZEOF
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

%type <label> IDENTIFIER
%type <label> CONSTANT
%type <label> expression
%type <label> unary_expression
%type <label> primary_expression
%type <label> postfix_expression

%type <symbole> declarator
%type <symbole> direct_declarator
%type <symbole> declaration


%type <type_t> declaration_specifiers
%type <type_t> type_specifier

%start program
%%

primary_expression
        : IDENTIFIER    {/*$$=$1;*/}
        | CONSTANT      {/*$$=$1;*/}
        | '(' expression ')'
        ;

postfix_expression
        : primary_expression
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
        : unary_expression      ;
        | multiplicative_expression '*' unary_expression
        | multiplicative_expression '/' unary_expression
        ;

additive_expression
        : multiplicative_expression
        | additive_expression '+' multiplicative_expression
        | additive_expression '-' multiplicative_expression {printf("expression moins");}
        ;

relational_expression
        : additive_expression
        | relational_expression '<' additive_expression
        | relational_expression '>' additive_expression
        | relational_expression LE_OP additive_expression
        | relational_expression GE_OP additive_expression
        ;

equality_expression
        : relational_expression
        | equality_expression EQ_OP relational_expression
        | equality_expression NE_OP relational_expression
        ;

logical_and_expression
        : equality_expression
        | logical_and_expression AND_OP equality_expression
        ;

logical_or_expression
        : logical_and_expression
        | logical_or_expression OR_OP logical_and_expression
        ;

expression
        : logical_or_expression                 
        | unary_expression '=' expression       {printf("%s = %s;", $1,$3);}
        ;

declaration
        : declaration_specifiers declarator ';' {
                                                $2->type_symbol=$1;
                                                $$=$2;
                                                verif_redefinition($2->label);
                                                TABLE[ACC]=$$;
                                                nouvelle_adresse();
                                                printf("type : %s , nom : %s : ",$$->type_symbol,$$->label);} 
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
        | direct_declarator '(' parameter_list ')' 
        | direct_declarator '(' ')'
        ;

parameter_list
        : parameter_declaration
        | parameter_list ',' parameter_declaration
        ;

parameter_declaration
        : declaration_specifiers declarator
        ;

statement
        : compound_statement
        | expression_statement
        | selection_statement
        | iteration_statement
        | jump_statement 
        ;

compound_statement
        : '{' '}'
        | '{' statement_list '}'
        | '{' declaration_list '}'
        | '{' declaration_list statement_list '}'
        ;

declaration_list
        : declaration
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
        : external_declaration
        | program external_declaration
        ;

external_declaration
        : function_definition
        | declaration
        ;

function_definition
        : declaration_specifiers declarator compound_statement
        ;

%%
int yyerror(char *s)
{
        fprintf(stderr,"%s\n",s);
        exit(1);
}
int main(void)
{
        /*flex lexFrontEnd.l
        yacc yaccFrontEnd.y -d
        gcc lex.yy.c y.tab.c -o testYacc */
        yyparse();
        return 0;
}