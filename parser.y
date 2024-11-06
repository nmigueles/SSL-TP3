%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <time.h>

extern void yyerror(char*);
extern FILE* yyin;
extern int yynerrs;
extern int yylineno;
extern int yylexerrs;
extern char *yytext;
extern int yyleng;
extern int yylex(void);


#define SIZE_TABLA_SIMBOLOS 100 // Cantidad máxima de símbolos soportada
#define SIZE_IDENTIFICADOR 32 // Tamaño máximo de un identificador

typedef struct {
    char id[SIZE_IDENTIFICADOR]; // Limitación de 32 caracteres para el identificador
    int cte;
} SIMBOLO; // Estructura de un símbolo, que es un identificador con su valor

int obtenerValorIdentificador(char* id);
void guardarIdentificador(char* id, int valor);
void ingresarIdentificador(char* id);

%}

%token INICIO FIN LEER ESCRIBIR COMA PUNTOYCOMA PARENIZ PARENDER RANDOM COMILLADOBLE ASIGNACION
%left SUMA RESTA

%token <id> ID
%token <cte> CONSTANTE
%token <cadena> CADENA

%union {
    char* id;
    int cte;
    char* cadena;
}

%type <cte> expresion termino
%type <cadena> cadena

%%

programa:
    INICIO listaSentencias FIN              {if (yynerrs || yylexerrs) YYABORT; return 0;}
;

listaSentencias:
      sentencia
    | listaSentencias sentencia
;

sentencia:
      asignacion
    | leer
    | escribir
    | error PUNTOYCOMA                      {yyerror("Error de sintaxis, sentencia invalida"); YYABORT;}
;

asignacion:
      ID ASIGNACION expresion PUNTOYCOMA    {guardarIdentificador($1, $3);}
    | ID error PUNTOYCOMA                   {yyerror("Error de sintaxis, se esperaba ':='"); YYABORT;}
    | ID ASIGNACION expresion error         {yyerror("Error de sintaxis, se esperaba ';'"); YYABORT;}
    | ID ASIGNACION error PUNTOYCOMA        {yyerror("Error de sintaxis, se esperaba una expresion"); YYABORT;}
;

leer:
      LEER PARENIZ listaIdentificadores PARENDER PUNTOYCOMA
    | LEER error PUNTOYCOMA                                 {yyerror("Error de sintaxis, se esperaba '('"); YYABORT;}
    | LEER PARENIZ error PARENDER PUNTOYCOMA                {yyerror("Error de sintaxis, se esperaba una lista de identificadores"); YYABORT;}
    | LEER PARENIZ listaIdentificadores error PUNTOYCOMA    {yyerror("Error de sintaxis, se esperaba ')'"); YYABORT;}
    | LEER PARENIZ listaIdentificadores PARENDER error      {yyerror("Error de sintaxis, se esperaba ';'"); YYABORT;}

;

listaIdentificadores:
       identificador
    |  listaIdentificadores COMA identificador
    |  listaIdentificadores COMA error                      {yyerror("Error de sintaxis, se esperaba un identificador"); YYABORT;}
;

identificador:
    ID                                                      {if(yyleng > SIZE_IDENTIFICADOR) yyerror("Error de sintaxis, se supero el tamaño máximo para el identificador"); ingresarIdentificador($1);}
;

escribir:
      ESCRIBIR PARENIZ listaExpresiones PARENDER PUNTOYCOMA
    | ESCRIBIR error listaExpresiones PARENDER PUNTOYCOMA           {yyerror("Error de sintaxis, se esperaba '('"); YYABORT;}
    | ESCRIBIR PARENIZ error PARENDER PUNTOYCOMA                    {yyerror("Error de sintaxis, se esperaba una lista de expresiones"); YYABORT;}
    | ESCRIBIR PARENIZ listaExpresiones error PARENDER PUNTOYCOMA   {yyerror("Error de sintaxis, se esperaba ','"); YYABORT;}
    | ESCRIBIR PARENIZ listaExpresiones error PUNTOYCOMA            {yyerror("Error de sintaxis, se esperaba ')'"); YYABORT;}
    | ESCRIBIR PARENIZ listaExpresiones PARENDER error              {yyerror("Error de sintaxis, se esperaba ';'"); YYABORT;}
;

listaExpresiones:
       expresion                            {printf("%d\n", $1);}
    |  cadena                               {printf("%s\n", $1);}
    |  listaExpresiones COMA expresion      {printf("%d\n", $3);}
    |  listaExpresiones COMA cadena         {printf("%s\n", $3);}
    |  listaExpresiones COMA error          {yyerror("Error de sintaxis, se esperaba una expresion"); YYABORT;}
;

expresion:
       termino                                      {$$ = $1;}
    |  expresion SUMA termino                       {$$ = $1 + $3;}
    |  expresion RESTA termino                      {$$ = $1 - $3;}
    |  RANDOM PARENIZ termino COMA termino PARENDER {$$ = $3 + rand() % ($5 - $3 + 1);}
    |  error SUMA termino                           {yyerror("Error de sintaxis, se esperaba una expresion"); YYABORT;}
    |  expresion SUMA error                         {yyerror("Error de sintaxis, se esperaba una expresion"); YYABORT;}
    |  error RESTA termino                          {yyerror("Error de sintaxis, se esperaba una expresion"); YYABORT;}
    |  expresion RESTA error                        {yyerror("Error de sintaxis, se esperaba una expresion"); YYABORT;}   
;

termino:
       ID                                   {$$ = obtenerValorIdentificador($1);}
    |  CONSTANTE                            {$$ = $1;}
    |  PARENIZ expresion PARENDER           {$$ = $2;}
;

cadena:
    CADENA                                  {$$ = $1;}
;
%%


void yyerror(char* msg) {
    fprintf(stderr, "%s en linea %d.\n", msg, yylineno);
}

int yywrap()  {
  return 1;  
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

    // Si no se encuentra el identificador, imprimir un error
    yyerror("Uso de identificador no inicializado");
    exit(1);
}

int noEsNumero(char* str) {
    for (int i = 0; i < strlen(str); i++) {
        if (!isdigit(str[i])) {
            return 1;
        }
    }
    return 0;
}

// Ingresar por STDIN un valor para un identificador
void ingresarIdentificador(char* id) {
    char userInput[32];

    printf("Ingresa el valor de %s: ", id);
    fscanf(stdin, "%s", userInput);

    if (noEsNumero(userInput)) {
        char* msg;
        sprintf(msg, "Runtime Error: el valor ingresado para %s no es un número", id);
        yyerror(msg);
        exit(1);
    }
    guardarIdentificador(id, atoi(userInput));
}

int yylexerrs = 0;

int main(int argc, char** argv) {
    // Inicializar la semilla para la función rand() en base al tiempo
    srand(time(0));

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
        // Ej: echo "inicio leer a, b; escribir a + b;" | ./micro
        yyin = stdin;
    }

    inicializarTablaSimbolos();

    return yyparse();
}