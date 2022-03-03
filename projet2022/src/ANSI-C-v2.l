D                       [0-9]
L                       [a-zA-Z_]
INTERDIT                [²&é~"#'è`ç^à@°€$£¤¨µ%ù§.?■ÜÖ☺]

%{
#include <stdio.h>
//#include "y.tab.h"


/* Ne g re pas les commentaires. A rajouter */
/* Supprimer les lignes dont vous n'avez pas besoin. */

%}

%x C_COMMENT

%option yylineno

%%



"/*"            { BEGIN(C_COMMENT); }
<C_COMMENT>"*/" { BEGIN(INITIAL); }
<C_COMMENT>\n   { }
<C_COMMENT>.    { }




"else"                  {   printf("ELSE "); /*return ELSE; */ }
"extern"                {   printf("EXTERN ");   /*return EXTERN; */}
"for"                   {   printf("FOR "); /*return FOR;*/ }
"if"                    {   printf("IF "); /*return IF; */}
"int"                   {   printf("INT"); /* return INT; */ }  
"return"                {   printf("RETURN "); /*return RETURN; */ }
"sizeof"                {   printf("SIZEOF "); /*return SIZEOF;*/ }
"struct"                {   printf("TOKEN_STRUCT "); /*return TOKEN_STRUCT*/ }
"void"                  {   printf("VOID "); /*return VOID; */}
"while"                 {   printf("WHILE "); /* return WHILE; */ }


{L}({L}|{D})*           {  printf("IDENTIFIANT ");/*identifiant*/ }
"*"{L}({L}|{D})*        {  printf("POINTEUR_ADD");/* pointeur adresse */ }
"&"{L}({L}|{D})*        {  printf("POINTEUR_VAL ");/* pointeur valeur */ }
{D}+                    {  printf("DECIMAUX ");/* Decimaux */}


">>"                    {   printf("RSHIFT ");/*return RSHIFT; */ }
"<<"                    {   printf("LSHIFT ");/*return LSHIFT; */ }
"<"                     {   printf("LT ");/* return '<' */ }   
">"                     {   printf("GT ");/* return '>' */ }
"&&"                    {   printf("LAND ");/* return LAND; */ }
"||"                    {   printf("LOR ");/* return LOR; */ }
"<="                    {   printf("LEQ ");/* return LEQ; */ }
">="                    {   printf("GEQ ");/* return GEQ; */ }
"=="                    {   printf("EQ ");/* return EQ; */ }
"!="                    {   printf("NEQ ");/* return NEQ; */ }

"+"                     {   printf("PLUS "); /* return 'PLUS' */ }
"*"                     {   printf("MUL "); /*return 'MUL' */}
"-"                     {   printf("MOINS "); /* return 'MOINS' */ }
"/"                     {   printf("DIV "); /* return 'DIV' */ }
"="                     {   printf("= "); /* return '='*/  }


"{"                     {   printf("{ ");/* return '{' */ }
"}"                     {   printf("} ");/* return '}' */ }
"("                     {   printf("( ");/* return '(' */ }
")"                     {   printf(") ");/* return ')' */ }
","                     {   printf(", ");/* return ',' */ }
";"                     {   printf("; ");/* return ';' */ }


[ \t\v\n\f]+            { printf("%s",yytext); }
{INTERDIT}              { printf("ERROR"); }
.                       {}
%%

int main(void)
{
    yylex();
    return 0;
}