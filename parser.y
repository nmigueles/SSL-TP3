%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE_TABLA_SIMBOLOS 100

int yylex();
void yyerror(char *s);

typedef struct {
    char id[32]; // Limitación de 32 caracteres para el identificador
    int cte;
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
    |  PARENIZ expresion PARENDER           {$$ = $2;}

%%

// Imprimir los errores en STDERR
void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

SIMBOLO tablaSimbolos[SIZE_TABLA_SIMBOLOS]; // Tabla de símbolos, con un máximo de 100 símbolos

void inicializarTablaSimbolos() {
    for (int i = 0; i < SIZE_TABLA_SIMBOLOS; i++) {
        // Inicializar los valores de la tabla de símbolos como -1 para indicar 
        // que no tienen valor, ya que en micro solo se soportan numeros positivos
        tablaSimbolos[i].cte = -1; 
    }
}

// Guardar un identificador en la tabla de símbolos
void guardarIdentificador(char* id, int valor) {
    // Buscar el identificador en la tabla de símbolos
    for (int i = 0; i < SIZE_TABLA_SIMBOLOS; i++) {
        if (tablaSimbolos[i].id == id) {
            // Si se encuentra el identificador, actualizar su valor
            tablaSimbolos[i].cte = valor;
            return;
        }
    }

    // Si no se encontró el identificador, guardarlo en la tabla de símbolos
    for (int i = 0; i < SIZE_TABLA_SIMBOLOS; i++) {
        // Busco el primer espacio vacío en la tabla de símbolos (valor == -1)
        if (tablaSimbolos[i].cte == -1) {
            sprintf(tablaSimbolos[i].id, "%s", id);
            tablaSimbolos[i].cte = valor;
            return;
        }
    }

    // Si no hay espacio en la tabla de símbolos, imprimir un error
    yyerror("No hay espacio en la tabla de símbolos");
    exit(1);
}

// Obtener el valor de un identificador en la tabla de símbolos
int obtenerValorIdentificador(char* id) {
    // Buscar el identificador en la tabla de símbolos
    for (int i = 0; i < SIZE_TABLA_SIMBOLOS; i++) {
        if (!strcmp(tablaSimbolos[i].id, id)) { // Si se encuentra el identificador
            return tablaSimbolos[i].cte;
        }
    }
}

// Ingresar por STDIN un valor para un identificador
void ingresarIdentificador(char* id) {
    char userInput[32];

    printf("Ingresa el valor de %s: ", id);
    fscanf(stdin, "%s", userInput);

    // TODO Validar que el valor ingresado sea un número
    guardarIdentificador(id, atoi(userInput));
}

int yylexerrs = 0;

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

    inicializarTablaSimbolos();

    int result = yyparse();

    // Correr el parser
    switch (result){
        case 0: 
            // Si no hay errores, la compilación fue exitosa. No imprimir nada
            break;
        case 1: 
            // Si hay errores, imprimir el mensaje de error
            printf("\nSe encontraron errores en la etapa de compilación\n");
            // TODO MEJORAR LOS MENSAJES DE ERROR INCLUYENDO LA LÍNEA Y EL ERROR
            // Imprimir la cantidad de errores
            printf("Errores sintácticos: %i\n", yynerrs);
            printf("Errores léxicos: %i\n", yylexerrs);
            break;
    }

    return 0;
}