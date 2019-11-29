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

%}
 
digit [0-9]
letter [a-zA-Z]
whitespace [ ]
punctuation [^A-Za-z0-9 \n]

%%

[\t\n ]+			/* ignore whitespace */;

"."                             {printf("dot\n");}
";"								{printf("semicolon\n");}
start\.				            {printf("start\n");}
end-now\.				        {printf("end\n");}
main\.			                {printf("main\n");}
print				            {printf("print\n");}
add			                    {printf("add\n");}
to				                {printf("to\n");}
equals-to				        {printf("equals=to\n");}
input				        {printf("input\n");}
move						{printf("move\n");}
[x]+\-?[x]*			                {printf("double\n");}
[a-zA-Z]{1}(-|[0-9]|[a-zA-Z]){0,6}		{printf("identifier\n");}
\"[^\"\n]*["\n]				{printf("string\n");}
-?({digit}+)(\.{digit}+)?	{printf("double value\n");}

.						{printf("unknown.\n");}

%%

int main()
{
	yylex();
}

int yywrap()
{
	return 1;
}
