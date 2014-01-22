%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <glib.h>
	#include "./struct.h"
	extern int yylineno;

	FILE * output;


	int yylex ();
	int yyerror ();
int exitError(char *s);


	unsigned int N = 0;
	type_t current_type  = VOID;

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
%type <node> primary_expression postfix_expression unary_expression multiplicative_expression additive_expression comparison_expression
%token IF ELSE WHILE RETURN FOR

%start program
%%

primary_expression
: IDENTIFIER									{	struct node_t * tmp = g_hash_table_lookup(var_scope,$1);
													if(!tmp){exitError("Unknown variable");};
													$$ = construct_node(STR);
													update_node($$,$1);


													//$$->reg = tmp->reg;
												}
| CONSTANTI										{	$$=construct_node(INTEGER);
													update_node($$,&$1);
													$$->reg = N++;
												}
| CONSTANTF										{	$$=construct_node(REAL);
													update_node($$,&$1);
													$$->reg = N++;
												}
| '(' expression ')'							{	$$->code = autoAlloc("");
												}
| IDENTIFIER '(' ')'							{$$->code = autoAlloc("");
												}
| IDENTIFIER '(' argument_expression_list ')'	{$$->code = autoAlloc("");
												}
| IDENTIFIER INC_OP								{$$->code = autoAlloc("");
												}
| IDENTIFIER DEC_OP								{$$->code = autoAlloc("");
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
| INC_OP unary_expression	{$$=$2;}
| DEC_OP unary_expression	{$$=$2;}
| unary_operator unary_expression	{$$=$2;}
;

unary_operator
: '-'
;

multiplicative_expression
: unary_expression	{$$=$1;}
| multiplicative_expression '*' unary_expression	{$$=$3;}
| multiplicative_expression '/' unary_expression	{$$=$3;}
;

additive_expression
: multiplicative_expression {$$=$1;}
| additive_expression '+' multiplicative_expression	{$$=$1;}
| additive_expression '-' multiplicative_expression	{$$=$1;}
;

comparison_expression
: additive_expression	{$$=$1;}
| additive_expression '<' additive_expression	{$$ = $1;}
| additive_expression '>' additive_expression	{$$ = $1;}
| additive_expression LE_OP additive_expression	{$$ = $1;}
| additive_expression GE_OP additive_expression	{$$ = $1;}
| additive_expression EQ_OP additive_expression	{$$ = $1;}
| additive_expression NE_OP additive_expression	{$$ = $1;}
;
//                                                                    store double  0x%8.8X, double* %%accelCmd\n
expression
: unary_expression assignment_operator comparison_expression {
				struct node_t * node = NULL;
				char * val = NULL;
				switch($1->type){
					case STR:
						node = g_hash_table_lookup(var_scope,$1->valStr);
						val = g_hash_table_lookup(const_torcs,$1->valStr);
						break;
					case REAL:
					case INTEGER:
						node = $1;
						val = $1->valStr;
				}

				if(!node) exitError("Variable doesn't exist");
				fprintf(output,"store %s %s, %s* %s\n",typeString[node->type],$3->valStr,typeString[node->type],val);

			}
| comparison_expression {}
;

assignment_operator
: '='
| MUL_ASSIGN
| ADD_ASSIGN
| SUB_ASSIGN
;

declaration
: type_name declarator_list ';' {
									//struct node_t * n = g_hash_table_lookup();
								}
;

declarator_list
: declarator  {}
| declarator_list ',' declarator
;

type_name
: VOID  {}
| INT   
| FLOAT
;

declarator
: IDENTIFIER  
| '(' declarator ')'
| declarator '[' CONSTANTI ']'
| declarator '[' ']'
| declarator '(' parameter_list ')'
| declarator '(' ')'
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
| '{' declaration_list statement_list '}'
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
: IF '(' expression ')' statement
| IF '(' expression ')' statement ELSE statement
| FOR '(' expression_statement expression_statement expression ')' statement
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

extern int column;
extern int yylineno;
extern FILE *yyin;

char *file_name = NULL;

int yyerror (char *s) {
	fflush (stdout);
	fprintf (stderr, "%s:%d:%d: %s\n", file_name, yylineno, column, s);
	return 0;
}

int exitError(char *s) {
	yyerror(s);
	exit(-1);
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
g_hash_table_insert(const_torcs,"$accel","%accelCmd");


	header();
	yyparse ();
	footer();
	free (file_name);
	return 0;
}
