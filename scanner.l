%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"

int yylex();

int yylexerrs; // Contador de errores léxicos
char errorBuffer[256]; // Buffer para almacenar el mensaje de error

int yycolumno = 1; /* Contador de columnas */

void reportError(const char* message);
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

[ \t]           { yycolumno += yyleng; } /* Incrementa columnas */
\n              { yylineno++; yycolumno = 1; } /* Nueva línea, reset columna */


<<EOF>>             return 0;

.               { reportError("Error léxico"); }

%%

/* Función para reportar errores léxicos */
void reportError(const char* message) {
    yylexerrs++;
    fprintf(stderr, "Error: %s en línea %d, columna %d: %s\n", message, yylineno, yycolumno, yytext);
    yycolumno += yyleng; /* Ajustar la posición de la columna */
}

int yywrap(void) {
    return 1;
}