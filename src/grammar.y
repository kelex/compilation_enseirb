%{
	#include <stdio.h>
#include "constants.c"
	extern int yylineno;
	int yylex ();
	int yyerror ();

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
: IDENTIFIER									{$$=construct_node(STR);update_node($$,$1);}
| CONSTANTI										{$$=construct_node(INTEGER);update_node($$,&$1);}
| CONSTANTF	{$$=construct_node(REAL);update_node($$,&$1);}
| '(' expression ')'	{$$=construct_node(STR);}
| IDENTIFIER '(' ')'	{$$=construct_node(STR);}
| IDENTIFIER '(' argument_expression_list ')'	{$$=construct_node(STR);}
| IDENTIFIER INC_OP	{$$=construct_node(STR);}
| IDENTIFIER DEC_OP	{$$=construct_node(STR);}
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

expression
: unary_expression assignment_operator comparison_expression {printNode($1,$3);}
| comparison_expression
;

assignment_operator
: '='
| MUL_ASSIGN
| ADD_ASSIGN
| SUB_ASSIGN
;

declaration
: type_name declarator_list ';'
;

declarator_list
: declarator
| declarator_list ',' declarator
;

type_name
: VOID  
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

extern int column;
extern int yylineno;
extern FILE *yyin;

char *file_name = NULL;

int yyerror (char *s) {
	fflush (stdout);
	fprintf (stderr, "%s:%d:%d: %s\n", file_name, yylineno, column, s);
	return 0;
}

void header()
{
	printf("target triple = \"x86_64-unknown-linux-gnu\"");

	printf("%%struct.CarElt = type {\n");
	printf("     i32,\n");
	printf("     %%struct.tInitCar,\n");
	printf("     %%struct.tPublicCar,\n");
	printf("     %%struct.tCarRaceInfo,\n");
	printf("     %%struct.tPrivCar,\n");
	printf("     %%struct.tCarCtrl,\n");
	printf("     %%struct.tCarPitCmd,\n");
	printf("     %%struct.RobotItf*,\n");
	printf("     %%struct.CarElt*\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.tInitCar = type {\n");
	printf("     [32 x i8],\n");
	printf("     [32 x i8],\n");
	printf("     [32 x i8],\n");
	printf("     [32 x i8],\n");
	printf("     i32,\n");
	printf("     i32,\n");
	printf("     i32,\n");
	printf("     i32,\n");
	printf("     [3 x float],\n");
	printf("     %%struct.t3Dd,\n");
	printf("     %%struct.t3Dd,\n");
	printf("     %%struct.t3Dd,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     %%struct.t3Dd,\n");
	printf("     [4 x %%struct.tWheelSpec],\n");
	printf("     %%struct.tVisualAttributes\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.t3Dd = type {\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.tWheelSpec = type {\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.tVisualAttributes = type {\n");
	printf("     i32,\n");
	printf("     [2 x %%struct.t3Dd],\n");
	printf("     float\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.tPublicCar = type {\n");
	printf("     %%struct.tDynPt,\n");
	printf("     %%struct.tDynPt,\n");
	printf("     [4 x [4 x float]],\n");
	printf("     %%struct.tTrkLocPos,\n");
	printf("     i32,\n");
	printf("     [4 x %%struct.tPosd]\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.tDynPt = type {\n");
	printf("     %%struct.tPosd,\n");
	printf("     %%struct.tPosd,\n");
	printf("     %%struct.tPosd\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.tPosd = type {\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.tTrkLocPos = type {\n");
	printf("     %%struct.trackSeg*,\n");
	printf("     i32,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.trackSeg = type {\n");
	printf("     i8*,\n");
	printf("     i32,\n");
	printf("     i32,\n");
	printf("     i32,\n");
	printf("     i32,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     %%struct.t3Dd,\n");
	printf("     [4 x %%struct.t3Dd],\n");
	printf("     [7 x float],\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     %%struct.t3Dd,\n");
	printf("     i32,\n");
	printf("     float,\n");
	printf("     i32,\n");
	printf("     float,\n");
	printf("     %%struct.SegExt*,\n");
	printf("     %%struct.trackSurface*,\n");
	printf("     [2 x %%struct.trackBarrier*],\n");
	printf("     %%struct.RoadCam*,\n");
	printf("     %%struct.trackSeg*,\n");
	printf("     %%struct.trackSeg*,\n");
	printf("     %%union.anon.0\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.SegExt = type {\n");
	printf("     i32,\n");
	printf("     i32*\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.trackSurface = type {\n");
	printf("     %%struct.trackSurface*,\n");
	printf("     i8*,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.trackBarrier = type {\n");
	printf("     i32,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     %%struct.trackSurface*,\n");
	printf("     %%class.v2t\n");
	printf("}\n");
	printf("\n");
	printf("%%class.v2t = type {\n");
	printf("     %%union.anon\n");
	printf("}\n");
	printf("\n");
	printf("%%union.anon = type {\n");
	printf("     %%struct.anon\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.anon = type {\n");
	printf("     float,\n");
	printf("     float\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.RoadCam = type {\n");
	printf("     i8*,\n");
	printf("     %%struct.t3Dd,\n");
	printf("     %%struct.RoadCam*\n");
	printf("}\n");
	printf("\n");
	printf("%%union.anon.0 = type {\n");
	printf("     %%struct.anon.1\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.anon.1 = type {\n");
	printf("     %%struct.trackSeg*,\n");
	printf("     %%struct.trackSeg*\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.tCarRaceInfo = type {\n");
	printf("     double,\n");
	printf("     i8,\n");
	printf("     double,\n");
	printf("     double,\n");
	printf("     double,\n");
	printf("     double,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     i32,\n");
	printf("     i32,\n");
	printf("     i32,\n");
	printf("     i32,\n");
	printf("     double,\n");
	printf("     i32,\n");
	printf("     double,\n");
	printf("     double,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     double,\n");
	printf("     %%struct.TrackOwnPit*,\n");
	printf("     i32,\n");
	printf("     %%struct.CarPenaltyHead\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.TrackOwnPit = type {\n");
	printf("     %%struct.tTrkLocPos,\n");
	printf("     i32,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     i32,\n");
	printf("     [4 x %%struct.CarElt*]\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.CarPenaltyHead = type {\n");
	printf("     %%struct.CarPenalty*,\n");
	printf("     %%struct.CarPenalty**\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.CarPenalty = type {\n");
	printf("     i32,\n");
	printf("     i32,\n");
	printf("     %%struct.anon.2\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.anon.2 = type {\n");
	printf("     %%struct.CarPenalty*,\n");
	printf("     %%struct.CarPenalty**\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.tPrivCar = type {\n");
	printf("     i8*,\n");
	printf("     i8*,\n");
	printf("     i32,\n");
	printf("     [32 x i8],\n");
	printf("     [4 x %%struct.tWheelState],\n");
	printf("     [4 x %%struct.tPosd],\n");
	printf("     i32,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     [10 x float],\n");
	printf("     i32,\n");
	printf("     i32,\n");
	printf("     [4 x float],\n");
	printf("     [4 x float],\n");
	printf("     i32,\n");
	printf("     i32,\n");
	printf("     float,\n");
	printf("     %%struct.t3Dd,\n");
	printf("     %%struct.t3Dd,\n");
	printf("     i32,\n");
	printf("     i32,\n");
	printf("     %%struct.tCollisionState_\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.tWheelState = type {\n");
	printf("     %%struct.tPosd,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     i32,\n");
	printf("     %%struct.trackSeg*,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.tCollisionState_ = type {\n");
	printf("     i32,\n");
	printf("     [3 x float],\n");
	printf("     [3 x float]\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.tCarCtrl = type {\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     i32,\n");
	printf("     i32,\n");
	printf("     [4 x [32 x i8]],\n");
	printf("     [4 x float],\n");
	printf("     i32\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.tCarPitCmd = type {\n");
	printf("     float,\n");
	printf("     i32,\n");
	printf("     i32,\n");
	printf("     %%struct.tCarPitSetup\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.tCarPitSetup = type {\n");
	printf("     %%struct.tCarPitSetupValue,\n");
	printf("     [4 x %%struct.tCarPitSetupValue],\n");
	printf("     [4 x %%struct.tCarPitSetupValue],\n");
	printf("     [4 x %%struct.tCarPitSetupValue],\n");
	printf("     %%struct.tCarPitSetupValue,\n");
	printf("     %%struct.tCarPitSetupValue,\n");
	printf("     [4 x %%struct.tCarPitSetupValue],\n");
	printf("     [4 x %%struct.tCarPitSetupValue],\n");
	printf("     [4 x %%struct.tCarPitSetupValue],\n");
	printf("     [4 x %%struct.tCarPitSetupValue],\n");
	printf("     [4 x %%struct.tCarPitSetupValue],\n");
	printf("     [4 x %%struct.tCarPitSetupValue],\n");
	printf("     [2 x %%struct.tCarPitSetupValue],\n");
	printf("     [2 x %%struct.tCarPitSetupValue],\n");
	printf("     [2 x %%struct.tCarPitSetupValue],\n");
	printf("     [2 x %%struct.tCarPitSetupValue],\n");
	printf("     [2 x %%struct.tCarPitSetupValue],\n");
	printf("     [8 x %%struct.tCarPitSetupValue],\n");
	printf("     [2 x %%struct.tCarPitSetupValue],\n");
	printf("     [3 x %%struct.tCarPitSetupValue],\n");
	printf("     [3 x %%struct.tCarPitSetupValue],\n");
	printf("     [3 x %%struct.tCarPitSetupValue],\n");
	printf("     [3 x %%struct.tCarPitSetupValue],\n");
	printf("     [3 x %%struct.tCarPitSetupValue],\n");
	printf("     [3 x %%struct.tCarPitSetupValue],\n");
	printf("     [3 x i32]\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.tCarPitSetupValue = type {\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.RobotItf = type {\n");
	printf("     void (i32, %%struct.tTrack*, i8*, i8**, %%struct.Situation*)*,\n");
	printf("      {}*,\n");
	printf("      {}*,\n");
	printf("      {}*,\n");
	printf("      i32 (i32, %%struct.CarElt*, %%struct.Situation*)*,\n");
	printf("      void (i32)*,\n");
	printf("      i32\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.tTrack = type {\n");
	printf("     i8*,\n");
	printf("     i8*,\n");
	printf("     i8*,\n");
	printf("     i8*,\n");
	printf("     i8*,\n");
	printf("     i8*,\n");
	printf("     i32,\n");
	printf("     i32,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     %%struct.tTrackPitInfo,\n");
	printf("     %%struct.trackSeg*,\n");
	printf("     %%struct.trackSurface*,\n");
	printf("     %%struct.t3Dd,\n");
	printf("     %%struct.t3Dd,\n");
	printf("     %%struct.tTrackGraphicInfo\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.tTrackPitInfo = type {\n");
	printf("     i32,\n");
	printf("     i32,\n");
	printf("     i32,\n");
	printf("     i32,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     %%struct.trackSeg*,\n");
	printf("     %%struct.trackSeg*,\n");
	printf("     %%struct.trackSeg*,\n");
	printf("     %%struct.trackSeg*,\n");
	printf("     %%struct.TrackOwnPit*,\n");
	printf("     i32,\n");
	printf("     i32\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.tTrackGraphicInfo = type {\n");
	printf("     i8*,\n");
	printf("     i8*,\n");
	printf("     i32,\n");
	printf("     [3 x float],\n");
	printf("     i32,\n");
	printf("     i8**,\n");
	printf("     %%struct.tTurnMarksInfo\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.tTurnMarksInfo = type {\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float,\n");
	printf("     float\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.Situation = type {\n");
	printf("     %%struct.tRaceAdmInfo,\n");
	printf("     double,\n");
	printf("     double,\n");
	printf("     i32,\n");
	printf("     %%struct.CarElt**\n");
	printf("}\n");
	printf("\n");
	printf("%%struct.tRaceAdmInfo = type {\n");
	printf("     i32,\n");
	printf("     i32,\n");
	printf("     i32,\n");
	printf("     i32,\n");
	printf("     i32,\n");
	printf("     i64\n");
	printf("}\n");
	printf("\n");
	printf("define void @drive(i32 %%index, %%struct.CarElt* %%car, %%struct.Situation* %%s) {\n");
	printf("     %%ctrl       = getelementptr %%struct.CarElt* %%car, i32 0, i32 5\n");
	printf("     %%public_car = getelementptr %%struct.CarElt* %%car, i32 0, i32 2\n");
	printf("     %%pos        = getelementptr %%struct.tPublicCar* %%public_car, i32 0, i32 3\n");
	printf("     %%seg.addr   = getelementptr %%struct.tTrkLocPos* %%pos, i32 0, i32 0\n");
	printf("     %%seg        = load %%struct.trackSeg** %%seg.addr\n");
	printf("\n");
	printf("     %%steer      = getelementptr %%struct.tCarCtrl* %%ctrl, i32 0, i32 0\n");
	printf("     %%accelCmd   = getelementptr %%struct.tCarCtrl* %%ctrl, i32 0, i32 1\n");
	printf("     %%brakeCmd   = getelementptr %%struct.tCarCtrl* %%ctrl, i32 0, i32 2\n");
	printf("     %%clutchCmd  = getelementptr %%struct.tCarCtrl* %%ctrl, i32 0, i32 3\n");
	printf("     %%gear       = getelementptr %%struct.tCarCtrl* %%ctrl, i32 0, i32 4\n");
	printf("\n");
	printf("     %%road_angle = call float @get_track_angle(%%struct.tTrkLocPos* %%pos)\n");
	printf("     %%car_angle  = call float @get_car_yaw(%%struct.CarElt* %%car)\n");
	printf("     %%angle      = fsub float %%road_angle, %%car_angle\n");
	printf("     %%nangle     = call float @norm_pi_pi(float %%angle)\n");
	printf("\n");
	printf("     %%posmid     = call float @get_pos_to_middle(%%struct.tTrkLocPos* %%pos)\n");
	printf("     %%width      = call float @get_track_seg_width(%%struct.trackSeg* %%seg)\n");
	printf("     %%corr       = fdiv float %%posmid, %%width\n");
	printf("     %%cangle     = fsub float %%nangle, %%corr\n");
}



void footer(){


		printf("     ret void;\n");
		printf(" }\n");
		printf(" \n");
		printf(" declare float @norm_pi_pi(float %%a)\n");
		printf(" declare float @get_track_angle(%%struct.tTrkLocPos*)\n");
		printf(" declare float @get_pos_to_right(%%struct.tTrkLocPos*)\n");
		printf(" declare float @get_pos_to_middle(%%struct.tTrkLocPos*)\n");
		printf(" declare float @get_pos_to_left(%%struct.tTrkLocPos*)\n");
		printf(" declare float @get_pos_to_start(%%struct.tTrkLocPos*)\n");
		printf(" declare float @get_track_seg_length(%%struct.trackSeg*)\n");
		printf(" declare float @get_track_seg_width(%%struct.trackSeg*)\n");
		printf(" declare float @get_track_seg_start_width(%%struct.trackSeg*)\n");
		printf(" declare float @get_track_seg_end_width(%%struct.trackSeg*)\n");
		printf(" declare float @get_track_seg_radius(%%struct.trackSeg*)\n");
		printf(" declare float @get_track_seg_right_radius(%%struct.trackSeg*)\n");
		printf(" declare float @get_track_seg_left_radius(%%struct.trackSeg*)\n");
		printf(" declare float @get_track_seg_arc(%%struct.trackSeg*)\n");
		printf(" declare %%struct.trackSeg* @get_track_seg_next(%%struct.trackSeg*)\n");
		printf(" declare float @get_car_yaw(%%struct.CarElt*)\n");
		printf(" \n");
		printf(" }\n");
	}


/*
	store float %%cangle, float* %%steer
	store float 0.750000e+00, float* %%accelCmd
	store float 0.000000e+00, float* %%brakeCmd
	store float 0.000000e+00, float* %%clutchCmd
	store i32 1, i32* %%gear
*/


int main (int argc, char *argv[]) {
	FILE *input = NULL;
	if (argc==2) {
	input = fopen (argv[1], "r");
	file_name = strdup (argv[1]);
	if (input) {
		yyin = input;
	}
	else {
	  fprintf (stderr, "%s: Could not open %s\n", *argv, argv[1]);
		return 1;
	}
	}
	else {
	fprintf (stderr, "%s: error: no input file\n", *argv);
	return 1;
	}
	header();
	yyparse ();
	footer();
	free (file_name);
	return 0;
}
