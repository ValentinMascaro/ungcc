%option noyywrap
D                       [0-9]
L                       [a-zA-Z_]
INTERDIT                [²é~"#'è`ç^à@°€$£¤¨µ%ù§.?■ÜÖ☺]

%{

#include "y.tab.h"
#include "./src/structure.h"


/* Ne gere pas les commentaires. A rajouter */
/* Supprimer les lignes dont vous n'avez pas besoin. */

%}

%x C_COMMENT

%option yylineno

%%



"/*"            { BEGIN(C_COMMENT); }
<C_COMMENT>"*/" { BEGIN(INITIAL);   }
<C_COMMENT>\n   {                   }
<C_COMMENT>.    {                   }




"else"                  {   return ELSE;            }
"extern"                {   return EXTERN;          }
"for"                   {   return FOR;             }
"if"                    {   return IF;              }
"int"                   {   return INT;             }  
"return"                {   return RETURN;          }
"sizeof"                {   return SIZEOF;          }
"struct"                {   return STRUCT;    }
"void"                  {   return VOID;            }
"while"                 {   return WHILE;           }
"structure"             {   return STRUCT;          }

{L}({L}|{D})*           {  yylval.label = strdup(yytext);return IDENTIFIER;         }
{D}+                    {  yylval.label = strdup(yytext);return CONSTANT;           }
"->"                    {  return PTR_OP; /* Champ de structure */}

"<"                     {   return '<';     }   
">"                     {   return '>';     }
"&&"                    {   return AND_OP;    }
"||"                    {   return OR_OP;     }
"<="                    {   return LE_OP;     }
">="                    {   return GE_OP;     }
"=="                    {   return EQ_OP;      }
"!="                    {   return NE_OP;     }

"&"                     {   return '&';     }
"+"                     {   return '+';}
"*"                     {   return '*';}
"-"                     {   return '-';}
"/"                     {   return '/';}
"="                     {   return '=';}


"{"                     {  return '{' ;}
"}"                     {   return '}' ;}
"("                     {   return '(' ;}
")"                     {   return ')' ;}
","                     {   return ',' ;}
";"                     {   return ';' ;}


[ \t\v\n\r\f]+          { /*printf("%s",yytext); */ }
{INTERDIT}              { erreur("caractere interdit",yytext);     }
.                       {}
%%
