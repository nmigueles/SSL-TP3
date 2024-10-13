%{
#include <stdio.h>
#include <string.h>
#include "parser.tab.h"

void yyerror(char *s);
int yylex();

int yylexerrs; // Contador de errores léxicos
char errorBuffer[256]; // Buffer para almacenar el mensaje de error
%}

Identificador    [a-zA-Z][a-zA-Z0-9]*
Constante        [0-9]+
%%

"inicio"            return INICIO;
"fin"               return FIN;
"leer"              return LEER;
"escribir"          return ESCRIBIR;

":="                return ASIGNACION;

"+"                 return SUMA;
"-"                 return RESTA;

"("                 return PARENIZ;
")"                 return PARENDER;
","                 return COMA;
";"                 return PUNTOYCOMA;

{Identificador}     {yylval.id = strdup(yytext); return ID;}
{Constante}         {yylval.cte = atoi(yytext); return CONSTANTE;}

[ \t\n]+            ; // Ignorar whitespace

.                   {yylexerrs++; sprintf(errorBuffer, "Error Lexico: %s\n", yytext); yyerror(errorBuffer);}

%%

int yywrap(void) {
    return 1;
}
