%option noyywrap

%{
/*
* CS4158 - Practical 1 Lexer
* Student ID: 18111521
* Student Name: Naichuan Zhang
*/
	
#include "stdio.h"
#include "string.h"

%}

digit 	[0-9]
letter 	[A-Za-z]
whitespace [ ]
punctuation [^A-Za-z0-9 \n]
start (S|s)(T|t)(A|a)(R|r)(T|t)\.
end   (E|e)(N|n)(D|d)\-(N|n)(O|o)(W|w)\.
main  (M|m)(A|a)(I|i)(N|n)\.
print (P|p)(R|r)(I|i)(N|n)(T|t)
equalsto (E|e)(Q|q)(U|u)(A|a)(L|l)(S|s)\-(T|t)(O|o)
equalstovalue (E|e)(Q|q)(U|u)(A|a)(L|l)(S|s)\-(T|t)(O|o)\-(V|v)(A|a)(L|l)(U|u)(E|e)
add (A|a)(D|d)(D|d)
to (T|t)(O|o)
input (I|i)(N|n)(P|p)(U|u)(T|t)
x     (X|x)
string ({digit}|{letter}|{punctuation}|{whitespace})*
stringwithoutspace ({digit}|{letter}|{punctuation}){0,6}
double ({x}*\-?{x}+)
identifier ({letter}{stringwithoutspace})
inputbody ({identifier})(\;{identifier})*
outputbody ({identifier}\;)?(\"{string}\"\;{identifier})+
doublevalue ({digit}+)(\.{digit}+)?

%%

[\t ]+											/* ignore whitespace */;

{start}											{ printf("%s: is the start symbol\n", yytext); }
{end}											{ printf("%s: is the end symbol\n", yytext); }
{main}											{ printf("%s: is the main body symbol\n", yytext); }
{equalsto}										{ printf("%s: is the equals-to symbol\n", yytext); }
{equalstovalue}									{ printf("%s: is the equals-to-value symbol\n", yytext); }
{add}											{ printf("%s: is the add symbol\n", yytext); }
{to}											{ printf("%s: is the to symbol\n", yytext); }
{input}											{ printf("%s: is the input symbol\n", yytext); }
{print}											{ printf("%s: is the print symbol\n", yytext); }
{print}{whitespace}\"{string}\"\.				{ printf("%s: is the print statement\n", yytext); }
{double}										{ 
												  int i, frequency1, frequency2, FLAG = 0;
												  char *part1, *part2;
												  char *string = yytext;
												  printf("%s: ", string);
												  for (i = 0; yytext[i] != '\0'; ++i) {
													if (yytext[i] == '-') {
													  part1 = strtok(yytext, "-");
													  part2 = strtok(NULL, "-");
													  FLAG = 1;
													}
												  }
												  if (FLAG == 0) {
													frequency1 = 0; frequency2 = 0;
													for (i = 0; yytext[i] != '\0'; ++i) {
													  if (yytext[i] == 'x' || yytext[i] == 'X')
														++frequency1;
													}
													printf("is the double type which specifies a %d-digit number\n", frequency1);
												  } else {
													frequency1 = 0; frequency2 = 0;
													for (i = 0; part1[i] != '\0'; ++i) {
													  if (part1[i] == 'x' || part1[i] == 'X')
														++frequency1;
													}
													for (i = 0; part2[i] != '\0'; ++i) {
													  if (part2[i] == 'x' || part2[i] == 'X')
														++frequency2;
													}
													printf("is the double type which specifies a %d-digit number with %d decimal places can be held in the variable\n", frequency1, frequency2);
												  }
												}
{doublevalue}									{ printf("%s: is the double value\n", yytext); }
{identifier}									{ printf("%s: is the identifier\n", yytext); }
{double}{whitespace}{identifier}\.				{ printf("%s: is the declaration statement\n", yytext); }
{input}{whitespace}{inputbody}\.				{ printf("%s: is the input statement\n", yytext); }					
{print}{whitespace}{outputbody}\.				{ printf("%s: is the output statement\n", yytext); }
{identifier}{whitespace}{equalsto}{whitespace}{identifier}\. 			 { printf("%s: is the assignment statement\n", yytext); }
{identifier}{whitespace}{equalstovalue}{whitespace}{doublevalue}\.  	 { printf("%s: is the assignment statement\n", yytext); }
{add}{whitespace}{doublevalue}{whitespace}{to}{whitespace}{identifier}\. { printf("%s: is the add-to statement\n", yytext); }
{add}{whitespace}{identifier}{whitespace}{to}{whitespace}{identifier}\.  { printf("%s: is the add-to statement\n", yytext); }


.|\n											{ ECHO; /* normal default */ }
.*												{ printf("unknown\n"); }

%%

main()
{
	yylex();
}
