%{
#include <stdio.h>

// Extracto del libro de munchnik
typedef enum {
    INICIO, FIN, LEER, ESCRIBIR, ID, CONSTANTE, PARENIZQUIERDO,
    PARENDERECHO, PUNTOYCOMA, COMA, ASIGNACION, SUMA, RESTA, FDT
} TOKEN;

char *debug(int token);

%}

Identificador    [a-zA-Z][a-zA-Z0-9]*
Constante        [0-9]+
%%

"inicio"            { return INICIO; }
"fin"               { return FIN; }
"leer"              { return LEER; }
"escribir"          { return ESCRIBIR; }

"+"                 { return SUMA; }
"-"                 { return RESTA; }
":="                { return ASIGNACION; }

"("                 { return PARENIZQUIERDO; }
")"                 { return PARENDERECHO; }
","                 { return COMA; }
";"                 { return PUNTOYCOMA; }

{Identificador}     { return ID; }
{Constante}         { return CONSTANTE; }

[ \t\n]+            { /* Ignorar */ }

<<EOF>>             { return FDT; }

.                   { printf("Error léxico: %s\n", yytext); }

%%

char *debug(int token) {
    switch (token) {
        case INICIO: return "INICIO";
        case FIN: return "FIN";
        case LEER: return "LEER";
        case ESCRIBIR: return "ESCRIBIR";
        case ASIGNACION: return "ASIGNACION";
        case PARENIZQUIERDO: return "PARENIZQUIERDO";
        case PARENDERECHO: return "PARENDERECHO";
        case COMA: return "COMA";
        case PUNTOYCOMA: return "PUNTOYCOMA";
        case SUMA: return "SUMA";
        case RESTA: return "RESTA";
        case ID: return "IDENTIFICADOR";
        case CONSTANTE: return "CONSTANTE";
        case FDT: return "FDT";
    }
}

int main() {
    TOKEN token;
    while((token = yylex()) != FDT) {
        printf("Token encontrado: %s\n", debug(token));
    }
    return 0;
}
