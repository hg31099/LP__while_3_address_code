%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "y.tab.h"
char *str;
void yyerror(char *);
%}

%%

"quit"		return QUIT;

^[-+]?\d+$	{ 
		  yylval.ival=atoi(yytext); 
		  return INTEGER;
} 		

[0-9]+\.?|[0-9]*\.[0-9]+ { 
          yylval.dval=atof(yytext); 
          return FLOAT;
} 		
[a-zA-Z]+[_|[0-9]|[a-zA-Z]]* {
			str=(char*)calloc((strlen(yytext)+1),sizeof(char));
			strcpy(str,yytext);
			yylval.id=str;
			return VARIABLE;
}


[-()<>=+*/;{}.] {
                return *yytext;
             }

">="            return GE;
"<="            return LE;
"=="            return EQ;
"!="            return NE;
"while"         return WHILE;
"if"            return IF;
"else"          return ELSE;
"print"         return PRINT;

[ \t\n]+        ;       /* ignore whitespace */

.               yyerror("Unknown character");
%%
int yywrap(void) {
    return 1;
}
