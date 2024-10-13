%{
#include <stdio.h>

// TODO Mover a un archivo de cabecera
#define INICIO 1
#define FIN 2
#define LEER 3
#define ESCRIBIR 4
#define ASIGNACION 5
#define PARENIZQUIERDO 6
#define PARENDERECHO 7
#define COMA 8
#define PUNTOYCOMA 9
#define SUMA 10
#define RESTA 11
#define IDENTIFICADOR 12
#define CONSTANTE 13

char *debug(int token);
%}

Identificador     [a-zA-Z][a-zA-Z0-9]*
Constante         [0-9]+

%%

"inicio"        { printf("%s\n", debug(INICIO)); }
"fin"           { printf("%s\n", debug(FIN)); }
"leer"          { printf("%s\n", debug(LEER)); }
"escribir"      { printf("%s\n", debug(ESCRIBIR)); }

"+"             { printf("%s\n", debug(SUMA)); }
"-"             { printf("%s\n", debug(RESTA)); }
":="            { printf("%s\n", debug(ASIGNACION)); }

"("             { printf("%s\n", debug(PARENIZQUIERDO)); }
")"             { printf("%s\n", debug(PARENDERECHO)); }
","             { printf("%s\n", debug(COMA)); }
";"             { printf("%s\n", debug(PUNTOYCOMA)); }

{Identificador} { printf("%s\n", debug(IDENTIFICADOR)); }
{Constante}     { printf("%s\n", debug(CONSTANTE)); }

[ \t\n]+        { /* Ignorar */ }

.               { printf("Error léxico: %s\n", yytext); }

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
        case IDENTIFICADOR: return "IDENTIFICADOR";
        case CONSTANTE: return "CONSTANTE";
    }
}

int main() {
    yylex();
    return 0;
}
