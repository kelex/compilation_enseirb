%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <glib.h>
	#include "./struct.h"
	#include "./stack.h"
	extern int yylineno;

	FILE * output;


	int yylex ();
	int yyerror ();
int exitError(char *s);
struct node_t *  construct_operation(struct node_t * n1,operator_t op, struct node_t * n2);
void *  compute_operation(struct node_t * n1,operator_t op, struct node_t * n2);
char * getVariableToken(int * c,struct node_t *);

	unsigned int N = 1;
	type_t current_type  = EMPTY;
	operator_t current_operator = NO_OP;

	int currentDepth = 0;

	Kstack_t * context = NULL;
	GHashTable *var_scope = NULL;
	GHashTable *fun_scope = NULL;

	GHashTable *const_torcs = NULL;


%}


%union
{
	int i;
	float f;
	char * s;
	struct node_t * node;
}

%token <s> IDENTIFIER
%token <f> CONSTANTF
%token <i> CONSTANTI
%token INC_OP DEC_OP LE_OP GE_OP EQ_OP NE_OP
%token SUB_ASSIGN MUL_ASSIGN ADD_ASSIGN
%token TYPE_NAME
%token INT
%token FLOAT
%token VOID
%type <node> declarator_list declarator primary_expression postfix_expression unary_expression multiplicative_expression additive_expression comparison_expression
%token IF ELSE WHILE RETURN FOR

%start program
%%

primary_expression
: IDENTIFIER									{	struct node_t * tmp = findVariable($1);
													if(!tmp){exitError("Unknown variable");};
													$$ = construct_node(STR);
													update_node($$,$1);
													//update_node_code($$,autoAlloc(""));


													//$$->reg = tmp->reg;
												}
| CONSTANTI										{	$$=construct_node(INTEGER);
													update_node($$,&$1);
													//update_node_code($$,autoAlloc(""));
												}
| CONSTANTF										{	$$=construct_node(REAL);
													update_node($$,&$1);
													//update_node_code($$,autoAlloc(""));
												}
| '(' expression ')'							{	
													//update_node_code($$,autoAlloc(""));
												}
| IDENTIFIER '(' ')'							{//update_node_code($$,autoAlloc(""));
												}
| IDENTIFIER '(' argument_expression_list ')'	{//update_node_code($$,autoAlloc(""));
												}
| IDENTIFIER INC_OP								{//update_node_code($$,autoAlloc(""));
								struct  node_t* node = NULL;

								if(!(node = findVariable($1))) exitError("Incrementation is ONLY for initialized variables");
								struct node_t* const_1	= NULL;
								struct node_t* tmp	= construct_node(STR);
								update_node(tmp,$1);
								void * p = NULL;
								if(node->type == INTEGER){
									int  i = 1;
									p = &i;
								}
								else {
									float f = 1;
									p = &f;
								}
								$$=construct_node(node->type);
								const_1 = construct_node(node->type);
								update_node(const_1,p);
								printf("%s\n",const_1->valStr );
								$$ = construct_operation(tmp,ADD,const_1);

												}
| IDENTIFIER DEC_OP								{//update_node_code($$,autoAlloc(""));								struct  node_t* node = NULL;
								struct  node_t* node = NULL;
	
								if(!(node = findVariable($1))) exitError("Incrementation is ONLY for initialized variables");
								struct node_t* const_1	= NULL;
								struct node_t* tmp	= construct_node(STR);
								update_node(tmp,$1);
								void * p = NULL;
								if(node->type == INTEGER){
									int  i = 1;
									p = &i;
								}
								else {
									float f = 1;
									p = &f;
								}
								$$=construct_node(node->type);
								const_1 = construct_node(node->type);
								update_node(const_1,p);
								printf("%s\n",const_1->valStr );
								$$ = construct_operation(tmp,SUB,const_1);
												}
;

postfix_expression
: primary_expression	{$$=$1;}
| postfix_expression '[' expression ']'	{$$=$1;}
;

argument_expression_list
: expression
| argument_expression_list ',' expression
;

unary_expression
: postfix_expression	{$$=$1;}
| INC_OP unary_expression 	{
								struct  node_t* node = NULL;
								if($2->type != STR || !(node = findVariable($2->valStr))) exitError("Incrementation is ONLY for initialized variables");
								struct node_t* const_1	= NULL;
								void * p = NULL;
								if(node->type == INTEGER){
									int  i = 1;
									p = &i;
								}
								else {
									float f = 1;
									p = &f;
								}
								$$=construct_node(node->type);
								const_1 = construct_node(node->type);
								update_node(const_1,p);
								printf("%s\n",const_1->valStr );
								$$ = construct_operation($2,ADD,const_1);


							}
| DEC_OP unary_expression	{
								struct  node_t* node = NULL;
								if($2->type != STR || !(node = findVariable($2->valStr))) exitError("Incrementation is ONLY for initialized variables");
								struct node_t* const_1	= NULL;
								void * p = NULL;
								if(node->type == INTEGER){
									int  i = 1;
									p = &i;
								}
								else {
									float f = 1;
									p = &f;
								}
								$$=construct_node(node->type);
								const_1 = construct_node(node->type);
								update_node(const_1,p);
								printf("%s\n",const_1->valStr );
								$$ = construct_operation($2,SUB,const_1);}
| unary_operator unary_expression	{								struct  node_t* node = NULL;
								if($2->type != STR || !(node = findVariable($2->valStr))) exitError("Incrementation is ONLY for initialized variables");
								struct node_t* const_1	= NULL;
								void * p = NULL;
								if(node->type == INTEGER){
									int  i = -1;
									p = &i;
								}
								else {
									float f = -1;
									p = &f;
								}
								$$=construct_node(node->type);
								const_1 = construct_node(node->type);
								update_node(const_1,p);
								printf("%s\n",const_1->valStr );
								$$ = construct_operation($2,MUL,const_1);}
;

unary_operator
: '-'
;

multiplicative_expression
: unary_expression	{$$=$1;}
| multiplicative_expression '*' unary_expression	{
			$$ = construct_operation($1,MUL,$3);
		}
| multiplicative_expression '/' unary_expression	{$$=construct_operation($1,DIV,$3);}
;

additive_expression
: multiplicative_expression {$$=$1;}
| additive_expression '+' multiplicative_expression	{$$=construct_operation($1,ADD,$3);}
| additive_expression '-' multiplicative_expression	{$$=construct_operation($1,SUB,$3);}
;

comparison_expression
: additive_expression	{$$=$1;}
| additive_expression '<' additive_expression	{$$ = construct_operation($1,INF,$3);}
| additive_expression '>' additive_expression	{$$ = construct_operation($1,SUP,$3);}
| additive_expression LE_OP additive_expression	{$$ = construct_operation($1,INF_EQ_TO,$3);}
| additive_expression GE_OP additive_expression	{$$ = construct_operation($1,SUP_EQ_TO,$3);}
| additive_expression EQ_OP additive_expression	{$$ = construct_operation($1,EQUAL_TO,$3);}
| additive_expression NE_OP additive_expression	{$$ = construct_operation($1,DIFFERENT_OP,$3);}
;
//                                                                    store double  0x%8.8X, double* %%accelCmd\n
expression
: unary_expression assignment_operator comparison_expression {
				struct node_t * node = NULL;
				char * val = NULL;
				int contextDepth = -1;
				switch($1->type){
					case STR:
						node = findVariable($1->valStr);
						val = getVariableToken(&contextDepth,$1);
						break;
					default:
						exitError("Variable token expected.");	
				}
				if(!node) exitError("Variable doesn't exist");
				//printf("%s\n",$3->code );
				switch(current_operator){
					case EQUAL:
						//update_node_from_node(node,$3);
					if(contextDepth != -1){
						if($3->reg == -1){
							fprintf(output,"store %s %s, %s* %%%s%d\n",typeString[node->type],$3->valStr,typeString[node->type],val,contextDepth);
						}
						else
							fprintf(output,"%s%sstore %s %%%d, %s* %%%s%d\n",$1->code,$3->code,typeString[node->type],$3->reg,typeString[node->type],val,contextDepth);
					}
					else
						if($3->reg == -1){
							fprintf(output,"store %s %s, %s* %%%s\n",typeString[node->type],$3->valStr,typeString[node->type],val);
						}
						else
							fprintf(output,"%s%sstore %s %%%d, %s* %%%s\n",$1->code,$3->code,typeString[node->type],$3->reg,typeString[node->type],val);

						break;
					default:
						exitError("Operator not supported");
				}
				//$$ = construct_node(node->type);
				delete_node($1);
				delete_node($3);


			}
| comparison_expression {fprintf(output, "%s\n",$1->code);}
;

assignment_operator
: '='   {current_operator = EQUAL;}
| MUL_ASSIGN {current_operator = MUL;}
| ADD_ASSIGN {current_operator = ADD;}
| SUB_ASSIGN {current_operator = SUB;}
;

declaration
: type_name declarator_list ';' {
									fprintf(output,"%s",$2->code);delete_node($2);//struct node_t * n = g_hash_table_lookup();
								}
;

declarator_list
: declarator    {
					if (current_type==EMPTY) exitError("Void variable does not exist");
					$$ = $1;
				}
					
| declarator_list ',' declarator
			{
				if (current_type==EMPTY)	exitError("Void variable does not exist");
				$$ = construct_node(NODE);
				/* Doesn't work
				GHashTable * aa= g_hash_table_new_full(g_str_hash,  // Hash function 
                           g_str_equal, // Comparator    
                           free,   // Key destructor 
                           delete_node); // Val destructor 
				stack_push(context,aa);
				currentDepth++;
				*/
				update_node_code($$,autoAlloc("%s%s",$1->code,$3->code));
					//%%%s = alloca %s\n",$3->valStr,typeString[current_type] );g_hash_table_insert(var_scope,$3->valStr,construct_node(current_type));}
			}
;

type_name
: VOID  {current_type = EMPTY;}
| INT   {current_type = INTEGER;}
| FLOAT {current_type = REAL;}
;

declarator
: IDENTIFIER  	{
					$$ = construct_node(STR);
					update_node($$,$1);
					update_node_code($$, autoAlloc("%%%s%d = alloca %s\n",$1,currentDepth,typeString[current_type] ));
					g_hash_table_insert(var_scope,$1,construct_node(current_type));
				}
| '(' declarator ')'				{$$ = construct_node(STR);update_node($$,$2);}
| declarator '[' CONSTANTI ']'		{$$ = construct_node(STR);update_node($$,$1);}
| declarator '[' ']'		{
								$$ = construct_node(STR);update_node($$,$1);
							}
| declarator '(' parameter_list ')'	{ // function declaration or call
										$$ = construct_node(STR);update_node($$,$1);
									}
| declarator '(' ')'				{$$ = construct_node(STR);update_node($$,$1);}
;

parameter_list
: parameter_declaration
| parameter_list ',' parameter_declaration
;

parameter_declaration
: type_name declarator
;

statement
: compound_statement
| expression_statement 
| selection_statement
| iteration_statement
| jump_statement
;

compound_statement
: '{' '}'
| '{' statement_list '}'
| '{' declaration_list statement_list '}' {
	//currentDepth--;stack_pop(context); // ISSUE MALLOC
}
;

declaration_list
: declaration
| declaration_list declaration
;

statement_list
: statement
| statement_list statement
;

expression_statement
: ';'
| expression ';'
;

selection_statement
: IF '(' expression ')' statement {}//{if ($3) {$$ = construct_node(STR); update_node($$,$5);}}
| IF '(' expression ')' statement ELSE statement {}
| FOR '(' expression_statement expression_statement expression ')' statement {}
;

iteration_statement
: WHILE '(' expression ')' statement
;

jump_statement
: RETURN ';'
| RETURN expression ';'
;

program
: external_declaration
| program external_declaration
;

external_declaration
: function_definition
| declaration
;

function_definition
: type_name declarator compound_statement
;

%%
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
	#include "./stack.h"

extern int column;
extern int yylineno;
extern FILE *yyin;

char *file_name = NULL;




char * getVariableToken(int * c, struct node_t * n){
	if(n->type != STR) return NULL;
	
	char * val = NULL;
	*c = 0;


	if(n->valStr[0] == '$'){
		val = g_hash_table_lookup(const_torcs,n->valStr);
		if(!val) exitError("$ token is only for torcs variables");
		*c = -1;
	}
	else{
		struct list_t * currentC = context->current;
		while(currentC && !g_hash_table_lookup(currentC->data,n->valStr)){currentC = currentC->prev;*c = *c +1;}
		if(!currentC) return NULL;
		val = n->valStr;
	}

	return val;

}

struct  node_t * findVariable(char * n){
	struct list_t * currentC = context->current;
	struct node_t * node = NULL;

	while(currentC && !(node = g_hash_table_lookup(currentC->data,n))){
		currentC = currentC->prev;
	}
	return node;

}

 int castedValue(char ** n,struct node_t * n1, type_t t){
 	// char * castStr[TYPE_SIZE][TYPE_SIZE];
 	// castStr[INT][REAL] = "sitofp";
 	// castStr[REAL][INT] = "sitofp";
 	type_t type = n1->type;
 	struct node_t * node = NULL;
	if(type != INTEGER && type != STR && type != REAL) return -1;
	if(type == STR){
		node = findVariable(n1->valStr);
		if(! node) exitError("Undefined variable during cast");
		if(t == REAL && node->type == INTEGER){

				int i = N++;
				int j = N++;
				int contextDepth = 0;
				char * v1 = getVariableToken(&contextDepth,n1);
				*n = autoAlloc("%%%d = load %s * %%%s%d\n%%%d = sitofp %s %%%d to %s\n",i,typeString[node->type], v1,contextDepth,j,typeString[INTEGER],i,typeString[REAL]);
				return j;
			}
	}
	else
		node = n1;

	if(t == REAL && type == INTEGER){
		int i = N++;
		*n = autoAlloc("%%%d = sitofp %s %s to %s\n",i,typeString[INTEGER],n1->valStr,typeString[REAL]);
		return i;
	}
	else if(type == STR){
		int i = N++;
		int contextDepth;
		char * v1 = getVariableToken(&contextDepth,n1);

		*n = autoAlloc("%%%d = load %s * %%%s%d\n",i,typeString[node->type],v1,contextDepth);
		return i;
	}
	else
		return -1;

}


struct node_t *  construct_operation(struct node_t * n1,operator_t op, struct node_t * n2)
{
			void * val = NULL;
			struct node_t * res = NULL;
			struct node_t * node_1 = NULL;
			struct node_t * node_2 = NULL;

			char * v1 = NULL;
			char * v2 = NULL;
			int context1 = -1;
			int context2 = -1;

			if(n1->type == STR){
				node_1= findVariable(n1->valStr);
				if(node_1)
					v1 = getVariableToken(&context1,n1);
				

			}
			else
				node_1 = n1;
				
			if(n2->type == STR){
				node_2 =  findVariable(n2->valStr);
				if(node_2)
					v2 = getVariableToken(&context2,n2);
			}
			else
					node_2 = n2;
			
			if(!node_1 || !node_2)
				exitError("Operation Mul : undefined var");

			operator_t type = getTypeResult(node_1,op,node_2);
			res =  construct_node(type);



			char * castV1 = NULL;
			char * castV2 = NULL;

			int r1,r2,r3;
			r1 = castedValue(&castV1,n1,type);
			r2 = castedValue(&castV2,n2,type);
			if(castV1 && castV2) { // Double cast
				r3 = N++;
				update_node_code(res,autoAlloc("%s%s%s%s\n%%%d = %s %s %%%d,%%%d\n" //%%%d = load %s * %%%s \n%%%d = load %s * %%%s 
										,n1->code,n2->code
										,castV1,castV2
										,r3,operationString[type][op],typeString[type],r1,r2));
				res->reg = r3;
			}
			else if(castV1){
				r2=N++;
				update_node_code(res,autoAlloc("%s%s%s\n%%%d = %s %s %%%d,%s\n" //%%%d = load %s * %%%s \n%%%d = load %s * %%%s 
										,n1->code,n2->code
										,castV1
										,r2,operationString[type][op],typeString[type],r1,node_2->valStr));
				res->reg = r2;
			}
			else if(castV2){
				int r1,r2;
				r1=N++;
				update_node_code(res,autoAlloc("%s%s%s\n%%%d = %s %s %s,%%%d\n" //%%%d = load %s * %%%s \n%%%d = load %s * %%%s 
										,n1->code,n2->code
										,castV2
										,r1,operationString[type][op],typeString[type],node_1->valStr,r2));
				res->reg = r1;

			}
			else{
				val = compute_operation(n1,op,n2);
				update_node(res,val);

				int r1;
				r1 = N++;
				update_node_code(res,autoAlloc("%s%s%%%d = %s %s %s,0.0\n"
									,n1->code,n2->code
									,r1,operationString[type][ADD],typeString[type],res->valStr));
				res->reg = r1;

			}
			if(castV1) free(castV1);
			if(castV2) free(castV2);
			delete_node(n1);
			delete_node(n2);
			return res;
}

int yyerror (char *s) {
	fflush (stdout);
	fprintf (stderr, "%s:%d:%d: %s\n", file_name, yylineno, column, s);
	return 0;
}

int exitError(char *s) {
	yyerror(s);
	exit(-1);
}

void * compute_operation(struct node_t * n1,operator_t op, struct node_t * n2){
	int r;
	float f;
	void * val = NULL;

	if(n1->type > REAL || n2->type > REAL) exitError("Invalid type for this operation");
	operator_t type = getTypeResult(n1,op,n2);
	switch(op){
		case MUL:
			switch(type){
				case INTEGER:
					r = n1->x.i * n2->x.i;
					val = &r;
					break;
				case REAL:
					if(n1->type == n2->type)
						f = (n1->x.f * n2->x.f);
					else if(n1->type == REAL)
						f = n1->x.f * n2->x.i;
					else
						f = n1->x.i * n2->x.f;
					val = &f;
					break;
				default:
					exitError("Multiplication of these types is prohibited.");
			}
			break;
		case ADD:
			switch(type){
				case INTEGER:
					r = n1->x.i + n2->x.i;
					val = &r;
					break;
				case REAL:
					if(n1->type == n2->type)
						f = n1->x.f + n2->x.f;
					else if(n1->type == REAL)
						f = n1->x.f + n2->x.i;
					else
						f = n1->x.i + n2->x.f;
					val = &f;
					break;
				default:
					exitError("Multiplication of these types is prohibited.");
			}
			break;
		case SUB:
			switch(type){
				case INTEGER:
					r = n1->x.i - n2->x.i;
					val = &r;
					break;
				case REAL:
					if(n1->type == n2->type)
						f = n1->x.f - n2->x.f;
					else if(n1->type == REAL)
						f = n1->x.f - n2->x.i;
					else
						f = n1->x.i - n2->x.f;
					val = &f;
					break;
				default:
					exitError("Multiplication of these types is prohibited.");
			}
			break;
		case DIV:
			if(n1->type == n2->type){
				if(n1->type == INTEGER && n2->x.i != 0)
					f = n1->x.i / n2->x.i;
				else if(n1->type == REAL && n2->x.f != 0.0)
					f = n1->x.f / n2->x.f;
			}
			else if(n1->type == INTEGER && n2->x.f != 0.0)
				f = n1->x.i / n2->x.f;
			else if(n2->type == REAL && n2->x.i != 0)
				f = n1->x.f / n2->x.i;
			else
				exitError("Issue during operation");
			val = &f;
			break;
		case EQUAL_TO:
			switch(type){
				case INTEGER:
					if (n1->x.i == n2->x.i)
						r = 1;
					else 
						r = 0;
					val = &r;
					break;
				case REAL:
					if(n1->type == n2->type){
						if (n1->x.f == n2->x.f)
							f = 1;
						else
							f = 0;
					}
					else if(n1->type == REAL){
						if (n1->x.f == n2->x.i)
							f = 1;
						else 
							f = 0;
					}
					else {
						if (n1->x.i == n2->x.f)
							f = 1;
						else 
							f = 0;
					}
					val = &f;
					break;
				default:
					exitError("Issue during comparison ('equal to' op)");
					
			break;
			}
		case DIFFERENT_OP:
			switch(type){
				case INTEGER:
					if (n1->x.i != n2->x.i)
						r = 1;
					else 
						r = 0;
					val = &r;
					break;
				case REAL:
					if(n1->type == n2->type){
						if (n1->x.f != n2->x.f)
							f = 1;
						else
							f = 0;
					}
					else if(n1->type == REAL){
						if (n1->x.f != n2->x.i)
							f = 1;
						else 
							f = 0;
					}
					else {
						if (n1->x.i != n2->x.f)
							f = 1;
						else 
							f = 0;
					}
					val = &f;
					break;
				default:
					exitError("Issue during comparison ('different from' op)");
					
			break;
			}
		case SUP_EQ_TO:	
			switch(type){
				case INTEGER:
					if (n1->x.i >= n2->x.i)
						r = 1;
					else 
						r = 0;
					val = &r;
					break;
				case REAL:
					if(n1->type == n2->type){
						if (n1->x.f >= n2->x.f)
							f = 1;
						else
							f = 0;
					}
					else if(n1->type == REAL){
						if (n1->x.f >= n2->x.i)
							f = 1;
						else 
							f = 0;
					}
					else {
						if (n1->x.i >= n2->x.f)
							f = 1;
						else 
							f = 0;
					}
					val = &f;
					break;
				default:
					exitError("Issue during comparison ('superior or equal to' op)");
					
			break;
			}
		case INF_EQ_TO:
			switch(type){
				case INTEGER:
					if (n1->x.i <= n2->x.i)
						r = 1;
					else 
						r = 0;
					val = &r;
					break;
				case REAL:
					if(n1->type == n2->type){
						if (n1->x.f <= n2->x.f)
							f = 1;
						else
							f = 0;
					}
					else if(n1->type == REAL){
						if (n1->x.f <= n2->x.i)
							f = 1;
						else 
							f = 0;
					}
					else {
						if (n1->x.i <= n2->x.f)
							f = 1;
						else 
							f = 0;
					}
					val = &f;
					break;
				default:
					exitError("Issue during comparison ('inferior or equal to' op)");
					
			break;
			}
		case SUP:
			switch(type){
				case INTEGER:
					if (n1->x.i > n2->x.i)
						r = 1;
					else 
						r = 0;
					val = &r;
					break;
				case REAL:
					if(n1->type == n2->type){
						if (n1->x.f > n2->x.f)
							f = 1;
						else
							f = 0;
					}
					else if(n1->type == REAL){
						if (n1->x.f > n2->x.i)
							f = 1;
						else 
							f = 0;
					}
					else {
						if (n1->x.i > n2->x.f)
							f = 1;
						else 
							f = 0;
					}
					val = &f;
					break;
				default:
					exitError("Issue during comparison ('superior to' op)");
			break;
			}
		case INF:
			switch(type){
				case INTEGER:
					if (n1->x.i < n2->x.i)
						r = 1;
					else 
						r = 0;
					val = &r;
					break;
				case REAL:
					if(n1->type == n2->type){
						if (n1->x.f < n2->x.f)
							f = 1;
						else
							f = 0;
					}
					else if(n1->type == REAL){
						if (n1->x.f < n2->x.i)
							f = 1;
						else 
							f = 0;
					}
					else {
						if (n1->x.i < n2->x.f)
							f = 1;
						else 
							f = 0;
					}
					val = &f;
					break;
				default:
					exitError("Issue during comparison ('inferior to' op)");
			break;
			}

		}
	return val;
}
	
void header()
{
	fprintf(output,"define void @drive(i32 %%index, %%struct.CarElt* %%car, %%struct.Situation* %%s) {\n");
	fprintf(output,"     %%ctrl       = getelementptr %%struct.CarElt* %%car, i32 0, i32 5\n");
	fprintf(output,"     %%public_car = getelementptr %%struct.CarElt* %%car, i32 0, i32 2\n");
	fprintf(output,"     %%pos        = getelementptr %%struct.tPublicCar* %%public_car, i32 0, i32 3\n");
	fprintf(output,"     %%seg.addr   = getelementptr %%struct.tTrkLocPos* %%pos, i32 0, i32 0\n");
	fprintf(output,"     %%seg        = load %%struct.trackSeg** %%seg.addr\n");
	fprintf(output,"\n");
	fprintf(output,"     %%steer      = getelementptr %%struct.tCarCtrl* %%ctrl, i32 0, i32 0\n");
	fprintf(output,"     %%accelCmd   = getelementptr %%struct.tCarCtrl* %%ctrl, i32 0, i32 1\n");
	fprintf(output,"     %%brakeCmd   = getelementptr %%struct.tCarCtrl* %%ctrl, i32 0, i32 2\n");
	fprintf(output,"     %%clutchCmd  = getelementptr %%struct.tCarCtrl* %%ctrl, i32 0, i32 3\n");
	fprintf(output,"     %%gear       = getelementptr %%struct.tCarCtrl* %%ctrl, i32 0, i32 4\n");
	fprintf(output,"\n");
	fprintf(output,"     %%road_angle = call float @get_track_angle(%%struct.tTrkLocPos* %%pos)\n");
	fprintf(output,"     %%car_angle  = call float @get_car_yaw(%%struct.CarElt* %%car)\n");
	fprintf(output,"     %%angle      = fsub float %%road_angle, %%car_angle\n");
	fprintf(output,"     %%nangle     = call float @norm_pi_pi(float %%angle)\n");
	fprintf(output,"\n");
	fprintf(output,"     %%posmid     = call float @get_pos_to_middle(%%struct.tTrkLocPos* %%pos)\n");
	fprintf(output,"     %%width      = call float @get_track_seg_width(%%struct.trackSeg* %%seg)\n");
	fprintf(output,"     %%corr       = fdiv float %%posmid, %%width\n");
	fprintf(output,"     %%cangle     = fsub float %%nangle, %%corr\n");
}



void footer(){


		fprintf(output,"     ret void;\n");
		fprintf(output," }\n");
		fprintf(output," \n");
		fprintf(output," declare float @norm_pi_pi(float %%a)\n");
		fprintf(output," declare float @get_track_angle(%%struct.tTrkLocPos*)\n");
		fprintf(output," declare float @get_pos_to_right(%%struct.tTrkLocPos*)\n");
		fprintf(output," declare float @get_pos_to_middle(%%struct.tTrkLocPos*)\n");
		fprintf(output," declare float @get_pos_to_left(%%struct.tTrkLocPos*)\n");
		fprintf(output," declare float @get_pos_to_start(%%struct.tTrkLocPos*)\n");
		fprintf(output," declare float @get_track_seg_length(%%struct.trackSeg*)\n");
		fprintf(output," declare float @get_track_seg_width(%%struct.trackSeg*)\n");
		fprintf(output," declare float @get_track_seg_start_width(%%struct.trackSeg*)\n");
		fprintf(output," declare float @get_track_seg_end_width(%%struct.trackSeg*)\n");
		fprintf(output," declare float @get_track_seg_radius(%%struct.trackSeg*)\n");
		fprintf(output," declare float @get_track_seg_right_radius(%%struct.trackSeg*)\n");
		fprintf(output," declare float @get_track_seg_left_radius(%%struct.trackSeg*)\n");
		fprintf(output," declare float @get_track_seg_arc(%%struct.trackSeg*)\n");
		fprintf(output," declare %%struct.trackSeg* @get_track_seg_next(%%struct.trackSeg*)\n");
		fprintf(output," declare float @get_car_yaw(%%struct.CarElt*)\n");
		fprintf(output," \n");
	}

/*
	store float %%cangle, float* %%steer
	store float 0.750000e+00, float* %%accelCmd
	store float 0.000000e+00, float* %%brakeCmd
	store float 0.000000e+00, float* %%clutchCmd
	store i32 1, i32* %%gear
*/

void usage(char * name){
	fprintf(stderr,"Usage : %s <input> <output>\n",name);
}

int main (int argc, char *argv[]) {
	FILE *input = NULL;
	_node_const_init();
	output = NULL;
	if (argc==3) {
		input = fopen (argv[1], "r");
		file_name = strdup (argv[1]);
		if (input) {
			yyin = input;
		}
		else {
			fprintf (stderr, "%s: Could not open %s\n", *argv, argv[1]);
			return 1;
		}
		output = fopen(argv[2],"w");
		if(!output){
			fprintf (stderr, "%s: issue with output file %s\n", *argv, argv[2]);
			return 1;
		}
	}
	else {
		usage(*argv);
		return 1;
	}

var_scope = g_hash_table_new_full (g_str_hash,  /* Hash function  */
                           g_str_equal, /* Comparator     */
                           free,   /* Key destructor */
                           delete_node);  /* Val destructor */
fun_scope = g_hash_table_new_full (g_str_hash,  /* Hash function  */
                           g_str_equal, /* Comparator     */
                           free,   /* Key destructor */
                           delete_node);  /* Val destructor */


const_torcs = g_hash_table_new (g_str_hash,  /* Hash function  */
                           g_str_equal); /* Val destructor */


g_hash_table_insert(var_scope,autoAlloc("$accel"),construct_node(REAL));
g_hash_table_insert(var_scope,autoAlloc("$x"),construct_node(REAL));
g_hash_table_insert(var_scope,autoAlloc("$y"),construct_node(REAL));
g_hash_table_insert(var_scope,autoAlloc("$z"),construct_node(REAL));
g_hash_table_insert(var_scope,autoAlloc("$rmp"),construct_node(REAL));
g_hash_table_insert(var_scope,autoAlloc("$gear"),construct_node(REAL));
g_hash_table_insert(var_scope,autoAlloc("$speedx"),construct_node(REAL));
g_hash_table_insert(var_scope,autoAlloc("$speedy"),construct_node(REAL));
g_hash_table_insert(var_scope,autoAlloc("$speedz"),construct_node(REAL));
g_hash_table_insert(var_scope,autoAlloc("$steer"),construct_node(REAL));
g_hash_table_insert(var_scope,autoAlloc("$brake"),construct_node(REAL));
g_hash_table_insert(var_scope,autoAlloc("$clutch"),construct_node(REAL));
g_hash_table_insert(const_torcs,"$accel","accelCmd");

context = stack_init(g_hash_table_destroy);
stack_push(context,var_scope);
stack_release(context);
	header();
	yyparse ();
	footer();
	free (file_name);
	return 0;
}
