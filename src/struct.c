#include "struct.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>


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
		default:
		printf("BUGGY\n");
	}
}

void printNode(struct node_t * n1, struct node_t * n2){
	if(n1->type == STR){
		char accel[] = "$accel";
		if(!strcmp(accel,n1->x.s)){
			float tmp = 0.0;
			if(n2->type == INTEGER){
				tmp = n2->x.i;
			}
			else if(n2->type == REAL){
				tmp = n2->x.f;
			}
			else {
				yyerror("float or int value expected.");
				exit(-1);
			}
			printf("store float %f, float* %%accelCmd\n",tmp);
		}
	}
}

void update_node(struct node_t * n, void * val){
	switch(n->type){
		case NODE:
		n->x.s = (char * )val;
		break;
		case INTEGER:
		n->x.i = *((int *)val);
		break;
		case REAL:
		n->x.f = *((float *)val);
		break;
		case STR:
		n->x.s = (char *) val;
		break;
		default:;
	}
}

void delete_node(struct node_t * n){
	if(n->type == STR && n->type == NODE )
		free(n->x.s);
	free(n);
}

struct node_t * construct_node(type_t t){
	printf("CONSTRUCT NODE : %d\n",t );
	struct node_t * new_node = malloc(sizeof(node_t));
	new_node->type = t;
	return new_node;

}


void testaaaa(const char * s)
{
	char accel[] = "$accel";
	if(!strcmp(accel,s))
		printf("store float 0.750000e+00, float* %%accelCmd");
	else{
		yyerror("Undefined token (!= $accel) EXIT");
		exit(2);
	}
}
