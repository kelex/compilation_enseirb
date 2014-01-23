#ifndef _STRUCT_C_
#define _STRUCT_C_

#define TYPE_SIZE 3
#define OPERATOR_SIZE 4

extern char* typeString[TYPE_SIZE];
extern char* operationString[TYPE_SIZE][OPERATOR_SIZE];


char * autoAlloc(const char * fmt, ...);

typedef enum {
	INTEGER = 0,
	REAL = 1,
	EMPTY = 3,
	STR = 4,
	NODE = 5,
}type_t;

typedef enum {
	MUL = 0,
	DIV = 1,
	ADD = 2,
	SUB = 3,
	NO_OP = 4,
	EQUAL = 5,
}operator_t;

struct node_t{
	type_t type;
	union {
		int i;
		float f;
		char * s;
	} x;
	char * code;
	char * valStr;
	unsigned int reg;
} node_t;




type_t getTypeResult(struct node_t * n1,operator_t op, struct node_t * n2);
void debugNode(struct node_t * n);

void printNode(struct node_t * n1, struct node_t * n2);
void update_node_from_node(struct node_t * n1, struct node_t * n2);
void update_node(struct node_t * n, void * val);
void delete_node(struct node_t * n);
struct node_t * construct_node(type_t t);
void node_free_code(struct node_t * n);


#endif