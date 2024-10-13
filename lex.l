%{
#include <stdio.h>
%}

Identificador    [a-zA-Z][a-zA-Z0-9]*
Constante        [0-9]+
%%

"inicio"            return INICIO;
"fin"               return FIN;
"leer"              return LEER;
"escribir"          return ESCRIBIR;

"+"                 return SUMA;
"-"                 return RESTA;
":="                return ASIGNACION;

"("                 return PARENIZQUIERDO;
")"                 return PARENDERECHO;
","                 return COMA;
";"                 return PUNTOYCOMA;

{Identificador}     return ID;
{Constante}         return CONSTANTE;

[ \t\n]+            ;

.                   {printf("Error léxico: %s\n", yytext);}

%%

int yywrap(void) {
    return 1;
}
