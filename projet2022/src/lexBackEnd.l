%option noyywrap
D                       [0-9]
L                       [a-zA-Z_]
INTERDIT                [²&é~"#'è`ç^à@°€$£¤¨µ%ù§.?■ÜÖ☺]

%{
#include "y.tab.h"


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


"extern"                {   return EXTERN;  }
"int"                   {   return INT;     }  
"void"                  {   return VOID;    }
"goto"                  {   return GOTO;    }
"if"                    {   return IF;      }
"return"                {   return RETURN;  }


{L}({L}|{D})*           {  /*yylval.label = strdup(yytext);*/return IDENTIFIER;         }
{D}+                    {  /*yylval.label = strdup(yytext);*/return CONSTANT;           }
":"                     {return ':';}

"<"                     {   return '<';    }   
">"                     {   return '>';    }
"<="                    {   return LE_OP;  }
">="                    {   return GE_OP;  }
"=="                    {   return EQ_OP;  }
"!="                    {   return NE_OP;  }

"&"                     {   return '&';}
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
{INTERDIT}              {yyerror(yytext)   ; }
.                       {}
%%