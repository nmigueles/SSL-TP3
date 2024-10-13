%{
#include <stdio.h>
#include <stdlib.h>

int yylex();
void yyerror(char *s);

typedef struct {
    char id[32]; // Limitación de 32 caracteres para el identificador
    int valor;
} SIMBOLO; // Estructura de un símbolo, que es un identificador con su valor

int obtenerValorIdentificador(char* id);
void guardarIdentificador(char* id, int valor);
void ingresarIdentificador(char* id);

extern int yynerrs;
extern int yylexerrs;
extern FILE* yyin;

%}

%token INICIO FIN LEER ESCRIBIR PUNTOYCOMA PARENIZ PARENDER
%left SUMA RESTA COMA
%right ASIGNACION

%token <id> ID
%token <cte> CONSTANTE
%union {
    char* id;
    int cte;
}

%type <cte> expresion termino

%%

programa:
       INICIO listaSentencias FIN       {if (yynerrs || yylexerrs) YYABORT; return 0;}
; 

listaSentencias:
       sentencia
    |  listaSentencias sentencia
;

sentencia:
       ID ASIGNACION expresion PUNTOYCOMA   {guardarIdentificador($1, $3);}
    |  leer
    |  escribir
;

leer:
    LEER PARENIZ listaIdentificadores PARENDER PUNTOYCOMA
;

listaIdentificadores:
       ID                                   {ingresarIdentificador($1);}           
    |  listaIdentificadores COMA ID         {ingresarIdentificador($3);}
;

escribir:
    ESCRIBIR PARENIZ listaExpresiones PARENDER PUNTOYCOMA
;

listaExpresiones:
       expresion                            {printf("%d\n", $1);}
    |  listaExpresiones COMA expresion      {printf("%d\n", $3);}
;

expresion:
       termino                              {$$ = $1;}
    |  expresion SUMA termino               {$$ = $1 + $3;}
    |  expresion RESTA termino              {$$ = $1 - $3;}                    
;

termino:
       ID                                   {$$ = obtenerValorIdentificador($1);}
    |  CONSTANTE                            {$$ = $1;}
    |  PARENIZ expresion PARENDER{$$ = $2;}

%%

int yylexerrs = 0;

// Imprimir los errores en STDERR
void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

// TODO Implementar
void guardarIdentificador(char* id, int valor) {
    printf("Guardando %s con valor %d\n", id, valor);
}

// TODO Implementar
int obtenerValorIdentificador(char* id) {
    printf("Obteniendo valor de %s\n", id);
    return 0;
}

// TODO Implementar
void ingresarIdentificador(char* id) {
    printf("Ingresando en %s\n", id);
}

int main(int argc, char** argv) {
    // Verificar el mal uso del binario
    if (argc > 2){
        printf("Uso: micro <archivo>\n");
        return 1;
    }
    
    if (argc == 2) {
        // Tomar desde el archivo
        yyin = fopen(argv[1], "r");
    } else {
        // Tomar desde la stdin
        // echo "inicio leer a, b; escribir a + b;" | ./micro
        yyin = stdin;
    }

    int result = yyparse();

    // Correr el parser
    switch (result){
        case 0: 
            // Si no hay errores, la compilación fue exitosa. No imprimir nada
            break;
        case 1: 
            // Si hay errores, imprimir el mensaje de error
            printf("\nSe encontraron errores en la estapa de compilación\n");
            // TODO MEJORAR LOS MENSAJES DE ERROR INCLUYENDO LA LÍNEA Y EL ERROR
            // Imprimir la cantidad de errores
            printf("Errores sintácticos: %i\n", yynerrs);
            printf("Errores léxicos: %i\n", yylexerrs);
            break;
    }

    return 0;
}