#ifndef _STRUCT_C_
#define _STRUCT_C_

typedef enum {
	NODE,
	INTEGER,
	REAL,
	STR
}type_t;

struct node_t{
	type_t type;
	union {
		int i;
		float f;
		char * s;
	} x;
	char * code;

} node_t;


void debugNode(struct node_t * n);

void printNode(struct node_t * n1, struct node_t * n2);
void update_node(struct node_t * n, void * val);
void delete_node(struct node_t * n);
struct node_t * construct_node(type_t t);

#endif