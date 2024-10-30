%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"

int yycolumno = 1; /* Contador de columnas */

void reportError(const char* message);

%}

Letra            [a-zA-Z]
Digito           [0-9]
Identificador    {Letra}({Letra}|{Digito})*
Constante        {Digito}({Digito})*
Cadena           \"([^\"]*)\"
Comentario       "//".*

%%

"inicio"            return INICIO;
"fin"               return FIN;
"leer"              return LEER;
"escribir"          return ESCRIBIR;
"random"            return RANDOM;

":="                return ASIGNACION;

"+"                 return SUMA;
"-"                 return RESTA;

"("                 return PARENIZ;
")"                 return PARENDER;
","                 return COMA;
";"                 return PUNTOYCOMA;

{Identificador}     {yylval.id = strdup(yytext); return ID;}
{Constante}         {yylval.cte = atoi(yytext); return CONSTANTE;}
{Cadena}            {
                        int length = strlen(yytext);
                        yylval.cadena = strndup(yytext + 1, length - 2);
                        return CADENA;
                    }

{Comentario}        /* Ignorar comentarios */

[ \t]               { yycolumno += yyleng; } /* Incrementa columnas */
\n                  { yylineno++; yycolumno = 1; } /* Nueva línea, reset columna */


<<EOF>>             return 0;

.                   { reportError("Error léxico"); }

%%

/* Función para reportar errores léxicos */
void reportError(const char* message) {
    fprintf(stderr, "Error: %s en línea %d, columna %d: %s\n", message, yylineno, yycolumno, yytext);
    yycolumno += yyleng; /* Ajustar la posición de la columna */
    exit(1);
}