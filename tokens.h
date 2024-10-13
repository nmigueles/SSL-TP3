// Extracto del libro de munchnik
typedef enum {
    INICIO, FIN, LEER, ESCRIBIR, ID, CONSTANTE, PARENIZQUIERDO,
    PARENDERECHO, PUNTOYCOMA, COMA, ASIGNACION, SUMA, RESTA, FDT
} TOKEN;

char *debug(int token);

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