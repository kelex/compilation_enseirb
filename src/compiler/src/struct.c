#include "struct.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>


extern FILE * output;

char * typeString[TYPE_SIZE];
char * operationString[TYPE_SIZE][OPERATOR_SIZE];

void node_free_code(struct node_t * n){

	if(!n->code) return;
	free(n->code);
	n->code = NULL;
}

char * autoAlloc(const char * fmt, ...) {
	char * err = NULL;
	va_list args;
	va_start(args,fmt);
	size_t size = vsnprintf(NULL,0,fmt,args) + 1; // Put in NULL Pointer a max of 0 bytes, so vsnprintf returns the size needed.
	err = calloc(1,size);
	if(!err) return NULL; // error
	vsnprintf(err,size,fmt,args);
	va_end(args);

	return err;
	
}

void _node_const_init(){
typeString[INTEGER] = "i32";
typeString[REAL] = "double";
typeString[EMPTY] = "void";

operationString[INTEGER][MUL] = "mul";
operationString[REAL][MUL] = "fmul";
operationString[EMPTY][MUL] = "";


operationString[INTEGER][DIV] = "sdiv";
operationString[REAL][DIV] = "fdiv";
operationString[EMPTY][DIV] = "";


operationString[INTEGER][ADD] = "add";
operationString[REAL][ADD] = "fadd";
operationString[EMPTY][ADD] = "";

operationString[INTEGER][SUB] = "sub";
operationString[REAL][SUB] = "fsub";
operationString[EMPTY][SUB] = "";


}

void debugNode(struct node_t * n){
		switch(n->type){
		case NODE:
		printf("NODE(%s)\n",n->x.s);
		break;
		case INTEGER:
		printf("INT(%d)\n",n->x.i);
		break;
		case REAL:
		printf("FLOAT(%f)\n",n->x.f);
		break;
		case STR:
		printf("STR(%s)\n",n->x.s);
		break;
		case EMPTY:
		printf("EMPTY\n");
		default:
		printf("BUGGY\n");
	}
}

void printNode(struct node_t * n1, struct node_t * n2){
	if(n1->type == STR){
		char accel[] = "$accel";
		char * curr = n1->x.s;
		if(!strcmp(accel,curr)){
			float tmp = 0.0;
			if(n2->type == INTEGER){
				tmp = n2->x.i;
			}
			else if(n2->type == REAL){
				tmp = n2->x.f;
			}
			else {
				yyerror("float or int value expected.\n");
				exit(-1);
			}
			if(tmp >= 0 && tmp <= 1)
				fprintf(output,"store double  0x%8.8X, double* %%accelCmd\n",*((long*)&tmp));
			else{
				fprintf(output,"---------ERROR----------\n");
				yyerror("$accel : Value between 0 and 1 expected.");
				exit(-1);
			}
		}
	}
}



void update_node(struct node_t * n, void * val){
	if(n->valStr)
		free(n->valStr);

	if(!val)
		printf("NULL POINTEUR UPDATE !!!!!!!!!!!!!\n");

	switch(n->type){
	case NODE:
		n->x.s = (char * )val;
		break;
	case INTEGER:
		n->x.i = *((int *)val);	
		n->valStr = autoAlloc("%d",n->x.i);
	break;
		case REAL:
		
		n->x.f = *((float *)val);
		n->valStr = autoAlloc("0x%8.8X",*((long*)&n->x.f));
		break;
	case STR:
		n->x.s = (char *) val;
		n->valStr = n->x.s;
		break;
	default:
		exit(-1);
	}
}

void update_node_from_node(struct node_t * n1, struct node_t * n2){
	switch(n2->type){
	case INTEGER:
		update_node(n1, &(n2->x.i));
		break;
	case REAL:
		update_node(n1, &(n2->x.f));
		break;
	default:
		exit(-1);
	}
}

type_t getTypeResult(struct node_t * n1,operator_t ope, struct node_t * n2){
	type_t t1 = n1->type;
	type_t t2 = n2->type;
	switch(ope){
		case ADD:
		case SUB:
		case MUL:
			if(t1 == t2)
				return t1;
			else if(t1 == REAL || t2 == REAL){
				printf("COUCOU\n");
				return REAL;}
			else
				return EMPTY;
			break;
		case DIV:
			if((t1 == REAL || t1 == INTEGER) && (t2 == REAL || t2 == INTEGER))
				return REAL;
			return EMPTY;
			break;
	}
	return EMPTY;
}


void delete_node(struct node_t * n){
	if(n->valStr)
		free(n->valStr);
	node_free_code(n);
	free(n);
}


struct node_t * construct_node(type_t t){
	// printf("CONSTRUCT NODE : %d\n",t );
	struct node_t * new_node = malloc(sizeof(node_t));
	new_node->type = t;
	new_node->valStr = NULL;
	new_node->code = NULL;
	return new_node;

}

