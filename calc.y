%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <stdarg.h>
    #include <string.h>
	#include <math.h>
	#include <ctype.h>
    
    /* prototypes 
    nodeType *opr(int oper, int nops, ...);
    nodeType *id(int i);
    nodeType *con(int value);
    void freeNode(nodeType *p);
    int ex(nodeType *p);
    int yylex(void);
    
    void yyerror(char *s);
    int sym[26];            */        /* symbol table */

//typedef enum { typeInt, typeFloat, typeOpr, typeVar } nodeEnum;

typedef struct Variable_Storage
{
	char varname[30];
	double value;
}VarStore;

//typedef struct Complex_Statement_Node
//{
//	nodeEnum type;
//	union
//	{
//		int integer_value;
//		float float_value;
//		char operator;
//		char varname[30];
//	};
//}Node;

char *temp;
int complex_pointer=0;
int var_count=0;		//no of variables
int count_loops_nested=0;
int count_loops=0;		//no of nested loops	
int typevar=0;	
int flag=0;
int prev_flag=0;
FILE *fp;

		//float and int
VarStore storage[100];
void print_float(float val);
char * float_to_string(float value);
char * int_to_string(int value);
char * evaluate(char *expr1,char operator,char *expr2);
void findVal(char name[]);

%}

%union {
    	int ival;
	double dval;
	char * id;
	char ch;           
};

%token <ival> INTEGER
%token <dval> FLOAT
%token <id> VARIABLE
%token WHILE IF PRINT QUIT
%type <id> assign complex complex_expr
%type <ch> SC
%nonassoc IFX
%nonassoc ELSE

%left GE LE EQ NE '>' '<'
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

//%type stmt expr stmt_list

%%

program:
        function                
        ;

function:
          function stmt         
        | /* NULL */
        ;

stmt:
          ';' 
	| assign ';'                      	
        | expr ';'                       			{fprintf(fp,";\n");}
        | PRINT VARIABLE ';'       				{fprintf(fp,"cout<<");findVal($2);fprintf(fp,"<<endl;\n");}
        | WHILE							{fprintf(fp,"L%dN%d:\nif(",count_loops,count_loops_nested);count_loops_nested++;}
        '(' expr 
        ')'							{fprintf(fp,")\n");} 
        '{' 							{fprintf(fp,"{\n");}
        stmt_list 
        '}'  							{fprintf(fp,"goto L%dN%d;\n}\n",count_loops,count_loops_nested-1);count_loops_nested--;if(count_loops_nested==0)count_loops++;}  
        | IF '('						{fprintf(fp,"if(");}
         expr ')' 						{fprintf(fp,")");}
         brac %prec IFX					 
        | ELSE							{fprintf(fp,"else ");}
        brac
        | QUIT							{fprintf(fp,"\nreturn 0;\n}\n");exit(0);}            
        ;

brac: 	'{' 							{fprintf(fp,"{\n");}
        stmt_list 
        '}'  							{fprintf(fp,"\n}\n");}     
        | stmt


        |
        ;
        
        
stmt_list:
          stmt                  
        | stmt_list stmt        
        ;

assign :
	  VARIABLE '=' FLOAT 	{findVal($1);fprintf(fp,";\n%s=",$1); print_float($3); fprintf(fp,";\n");}
	| VARIABLE '=' INTEGER 	{findVal($1);fprintf(fp,";\n%s=%d;\n",$1,$3);}
       	| VARIABLE '=' complex	{findVal($1); fprintf(fp," = %s;\n",$3); }
	;

complex :
	  complex_expr
	| complex_expr SC complex_expr		{ {$$=evaluate($1,$2,$3);}; flag++;}
	;

complex_expr :
	  FLOAT              			{ {$$=float_to_string($1);};}
	| INTEGER              			{ {$$=int_to_string($1);};}
        | VARIABLE              		{ {$$=$1;}; }
	| complex_expr SC complex_expr		{ {$$=evaluate($1,$2,$3);}; flag++;}
	| complex_expr '*' complex_expr		{ {$$=evaluate($1,'*',$3);}; flag++;}
	| FLOAT '*' complex_expr		{ temp = float_to_string($1); {$$=evaluate(temp,'*',$3);}; flag++;}
	| complex_expr '/' complex_expr		{ {$$=evaluate($1,'/',$3);}; flag++;}
	| FLOAT '/' complex_expr		{ temp = float_to_string($1); {$$=evaluate(temp,'/',$3);}; flag++;}
        ; 


SC:
		'+'					{ {$$='+';}; }
		|'-'					{ {$$='-';}; }
		;



expr:
          FLOAT              	{ print_float($1); }
        | INTEGER               { fprintf(fp,"%d",$1); }
        | VARIABLE              { findVal($1); }
        | expr S expr		
        ;

S:
		'+'					{ fprintf(fp,"+"); }
		|'-'					{ fprintf(fp,"-"); }
		|'*'					{ fprintf(fp,"*"); }
		|'/'					{ fprintf(fp,"/"); }
		|'<'					{ fprintf(fp,"<"); }
		|'>'					{ fprintf(fp,">"); }
		|GE					{ fprintf(fp,">="); }
		|LE					{ fprintf(fp,"<="); }
		|NE					{ fprintf(fp,"!="); }
		|EQ					{ fprintf(fp,"=="); }
		;

%%

void print_float(float val)
{
	if(ceil(val)==floor(val))
	{
		fprintf(fp,"%d",(int)val);
	}
	else
	{
		fprintf(fp,"%0.2f",val);
	}
}

char * float_to_string(float value)
{
	char var[30];
	sprintf(var, "%0.2f", value);
	char *p = malloc( sizeof(char) * ( 30 + 1 ) );
	strcpy(p,var);
	return p;
}

char * int_to_string(int value)
{
	char var[30];
	sprintf(var, "%d", value);
	char *p = malloc( sizeof(char) * ( 30 + 1 ) );
	strcpy(p,var);
	return p;
}

char * evaluate(char *expr1,char operator,char *expr2)
{
	char var[30]="var";
	char var1[30];

	sprintf(var1, "%d", flag);
	strcat(var,var1);
	fprintf(fp,"\n float %s;\n %s = ",var,var);
	fprintf(fp,"%s %c %s;\n",expr1,operator,expr2);

//float var0;
//var0 = c*d;

	
	char *p = malloc( sizeof(char) * ( 30 + 1 ) );
	strcpy(p,var);
	return p;
}

void findVal(char name[])
{
	int i=0,j=0,flag=0;
	flag=0;
	for(i=0;i<var_count && flag==0;i++)
	{
		if(strcmp(storage[i].varname,name)==0)
		{
			flag=1;
			fprintf(fp,"\n%s",name);
		}
	}
	if(flag==0)
	{
		if(typevar==0)
		{
			fprintf(fp,"float %s ",name);
		}
		else
		{
			fprintf(fp,"int %s ",name);
		}
		strcpy(storage[var_count].varname,name);
		var_count++;
	}
}

void yyerror(char *s) {
    fprintf(fp,stdout, "%s\n", s);
}

int main(void) {
	fp=fopen("inter.cpp","w");
	fprintf(fp,"#include<stdio.h>\n#include<bits/stdc++.h>\nusing namespace std;\n");
	fprintf(fp,"int main(){\n");
    yyparse();
    return 0;
}
