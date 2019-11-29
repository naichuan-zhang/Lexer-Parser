%option caseless
%option yylineno

%{
/*
* CS4158 - Practical 1 Lexer
* Student ID: 18111521
* Student Name: Naichuan Zhang
*/
	
#include <stdio.h>
#include <string.h>

#include "parser.tab.h"
%}
 
digit [0-9]
letter [a-zA-Z]
whitespace [ ]
punctuation [^A-Za-z0-9 \n]

%%

[\t\n ]+			/* ignore whitespace */;

"."                             {return DOT;}
";"								{return SEMICOLON;}
start\.				            {return START;}
end-now\.				        {return END;}
main\.			                {return MAIN;}
print				            {return PRINT;}
add			                    {return ADD;}
to				                {return TO;}
equals-to				        {return EQUALSTO;}
equals-to-value					{return EQUALSTOVALUE;}
input				        {return INPUT;}
move						{return MOVE;}
[x]+\-?[x]*			                {yylval.sval = yytext; return DOUBLE;}
[a-zA-Z]{1}(-|[0-9]|[a-zA-Z]){0,6}		{yylval.sval = yytext; return IDENTIFIER;}
\"[^\"\n]*["\n]				{yylval.sval = yytext; return STRING;}
-?({digit}+)(\.{digit}+)?	{yylval.sval = yytext; return DOUBLEVALUE;}

.						{printf("unknown.\n");}

%%

int yywrap()
{
	return 1;
}
