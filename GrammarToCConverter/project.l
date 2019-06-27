digit	[0-9]
smallletter[a-z]
%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"
%}
%%	
[A-Z]+ yylval.string=strdup(yytext);return NONTERMINAL;
"int"	yylval.string=strdup(yytext);return INTRSW;
"float"	yylval.string=strdup(yytext);return FLOATRSW;
";" 	yylval.string=strdup(yytext);return SEMICOLMN;
"+"	yylval.string=strdup(yytext);return PLUSOP;
"-"	yylval.string=strdup(yytext);return MINUSOP;
"*"	yylval.string=strdup(yytext);return TIMES;
"/"	yylval.string=strdup(yytext);return DIVOP;
[+|-]?[0-9]+ 	yylval.string=strdup(yytext);return NUMBER;
"number" 	yylval.string=strdup(yytext);return NUMBERNONTERMINAL;
"->"		yylval.string=strdup(yytext);return ARROW;
"%rules" 	yylval.string=strdup(yytext);return RULESRSW;
"("		yylval.string=strdup(yytext);return OPEN;
")"		yylval.string=strdup(yytext);return CLOSE;
\|		yylval.string=strdup(yytext);return OR;
\n
.
[ \t]+
%%


