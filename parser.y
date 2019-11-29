%{
/*
* CS4158 - Practical 2 Parser
* Student ID: 18111521
* Student Name: Naichuan Zhang
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern int yylineno;
void yyerror(const char *s);

int i = 0;
int count = 0;
int countWarning = 0;
char capacities[100][10];
char identifiers[100][7];

void addDeclaration(char* doubleType, char* identifier);
void calCapacity(char* doubleType, char* identifier, char* result);
void addIdentifierToArray(char* doubleType, char* identifier);
void checkIdentifier(char* identifier);
void checkDoubleIdCapacity(char* doubleValue, char* identifier);
void checkIdIdCapacity(char* identifier1, char* identifier2);
void checkIdIdCapacityEqualsTo(char* identifier1, char* identifier2);

char* removeDot(char* c);
char* getDoubleType(char* c);
%}

%start program
%union {
	char *sval; 
	float dval; 
}

%token DOT SEMICOLON START END MAIN PRINT ADD TO INPUT EQUALSTO EQUALSTOVALUE MOVE
%token <sval> IDENTIFIER DOUBLE STRING DOUBLEVALUE

%%

program:
	START declarations MAIN stmts END { 
		printf("The whole program has been matched successfully!\n");
	}
	;

declarations: 	/* can be empty */
	| declaration declarations	{ 
		printf("Declarations part.\n"); 
	}
    ;

declaration:
	DOUBLE IDENTIFIER DOT {
		addDeclaration($1, $2);
	}
	;

stmts:		/* can be empty */
	| stmt stmts {
		printf("Statements part.\n");
	}
	;

stmt:
	printstmt {
		printf("Print statement.\n");
	}
	| inputstmt {
		printf("Input statement.\n");
	}
	| addstmt {
		printf("Add statement.\n");
	}
	| movestmt {
		printf("Move statement.\n");
	}
	| equalstostmt {
		printf("Equals-to statement.\n");
	}
	| equalstovaluestmt {
		printf("Equals-to-value statement.\n");
	}
	;
	
printstmt:
	PRINT printcontent
	;
	
printcontent:
	STRING DOT
	| STRING SEMICOLON printcontent
	| IDENTIFIER DOT {
		checkIdentifier($1);
	}
	| IDENTIFIER SEMICOLON printcontent {
		checkIdentifier($1);
	}
	;
	
inputstmt:
	INPUT inputcontent
	;
	
inputcontent:
	IDENTIFIER DOT {
		checkIdentifier($1);
	}
	| IDENTIFIER SEMICOLON inputcontent	{
		checkIdentifier($1);
	}
	;

addstmt:
	ADD DOUBLEVALUE TO IDENTIFIER DOT {
		checkIdentifier($4);
		checkDoubleIdCapacity($2, $4);
	}
	| ADD IDENTIFIER TO IDENTIFIER DOT {
		checkIdentifier($2);
		checkIdentifier($4);
		checkIdIdCapacity($2, $4);
	}
	;

movestmt:
	MOVE DOUBLEVALUE TO IDENTIFIER DOT {
		checkIdentifier($4);
		checkDoubleIdCapacity($2, $4);
	}
	| MOVE IDENTIFIER TO IDENTIFIER DOT {
		checkIdentifier($2);
		checkIdentifier($4);
		checkIdIdCapacity($2, $4);
	}
	;
	
equalstostmt:
	IDENTIFIER EQUALSTO IDENTIFIER DOT {
		checkIdentifier($1);
		checkIdentifier($3);
		checkIdIdCapacityEqualsTo($1, $3);
	}
	;
	
equalstovaluestmt:
	IDENTIFIER EQUALSTOVALUE DOUBLEVALUE DOT {
		checkIdentifier($1);
	}
	;

%%

void addDeclaration(char* doubleType, char* identifier) {
	
	removeDot(identifier);
	printf("Identifier is: %s\n", identifier);
	
	getDoubleType(doubleType);
	printf("Double type is: %s\n", doubleType);
	
	addIdentifierToArray(doubleType, identifier);
}

void addIdentifierToArray(char* doubleType, char* identifier) {
	
	bool duplicated = false;
	for (i = 0; i < count && !duplicated; i++) {
		if (strcmp(identifiers[i], identifier) == 0) {
			duplicated = true;
		}
	}
	if (duplicated) {
		printf("Error - Line %d: %s has been declared already.\n", yylineno, identifier);
		exit(-1);
	}
	
	strcpy(identifiers[count], identifier);
	
	char* capacityResult;
	calCapacity(doubleType, identifier, capacityResult);
	
	strcpy(capacities[count], capacityResult);
	
	count++;
}

void checkIdentifier(char* identifier) {

	removeDot(identifier);
	
	// need to do more manipulations to get the correct identifier ...
	bool FLAG = false;
	for (i = 0; i < strlen(identifier) && !FLAG; i++) {
		if (identifier[i] == ' ' || identifier[i] == ';') {
			identifier[i] = '\0';
			FLAG = true;
		}
	}
	
	bool ifExist = false;
	for (i = 0; i < count && !ifExist; i++) {
		if (strcmp(identifiers[i], identifier) == 0) {
			ifExist = true;
		}
	}
	
	if (!ifExist) {
		printf("Error - Line %d: Identifier %s is not declared in the declarations part.\n", yylineno, identifier);
		exit(-1);
	}
}

void checkIdIdCapacity(char* identifier1, char* identifier2) {
	
	// check if capacity matched between identifiers
	removeDot(identifier1);
	removeDot(identifier2);
	bool FLAG = false;
	for (i = 0; i < strlen(identifier1) && !FLAG; i++) {
		if (identifier1[i] == ' ' || identifier1[i] == ';') {
			identifier1[i] = '\0';
			FLAG = true;
		}
	}
	
	bool FLAG2 = false;
	for (i = 0; i < strlen(identifier2) && !FLAG2; i++) {
		if (identifier2[i] == ' ' || identifier2[i] == ';') {
			identifier2[i] = '\0';
			FLAG2 = true;
		}
	}
	
	char* capacityOfIdentifier1;
	char* capacityOfIdentifier2;
	bool isFound = false;
	
	// the capacity of identifier1
	for (i = 0; i < count && !isFound; i++) {
		if (strcmp(identifiers[i], identifier1) == 0) {
			isFound = true;
			capacityOfIdentifier1 = capacities[i];
		}
	}
	
	// the capacity of identifier2
	isFound = false;
	for (i = 0; i < count && !isFound; i++) {
		if (strcmp(identifiers[i], identifier2) == 0) {
			isFound = true;
			capacityOfIdentifier2 = capacities[i];
		}
	}
	
	printf("Capacity of Identifier 1 is %s\n", capacityOfIdentifier1);
	printf("Capacity of Identifier 2 is %s\n", capacityOfIdentifier2);
	
	// Now have got a style like 1-2 or 1...
	int numOfDigitsIdentifier1 = 0, numOfDecimalPlacesIdentifier1 = 0;
	int numOfDigitsIdentifier2 = 0, numOfDecimalPlacesIdentifier2 = 0;
	char* digitIdentifier1; char* decimalPlacesIdentifier1; 
	char* digitIdentifier2; char* decimalPlacesIdentifier2;
	
	if (strchr(capacityOfIdentifier1, '-') != NULL) {
		// for the format 1-2
		digitIdentifier1 = strtok(capacityOfIdentifier1, "-");
		decimalPlacesIdentifier1 = strtok(NULL, "-");
		
		numOfDigitsIdentifier1 = atoi(digitIdentifier1);
		numOfDecimalPlacesIdentifier1 = atoi(decimalPlacesIdentifier1);
	} else {
		// for the format 2
		digitIdentifier1 = capacityOfIdentifier1;
		
		numOfDigitsIdentifier1 = atoi(digitIdentifier1);
		numOfDecimalPlacesIdentifier1 = 0;
	}
	
	if (strchr(capacityOfIdentifier2, '-') != NULL) {
		// for the format 1-2
		digitIdentifier2 = strtok(capacityOfIdentifier2, "-");
		decimalPlacesIdentifier2 = strtok(NULL, "-");
		
		numOfDigitsIdentifier2 = atoi(digitIdentifier2);
		numOfDecimalPlacesIdentifier2 = atoi(decimalPlacesIdentifier2);
	} else {
		// for the format 2
		digitIdentifier2 = capacityOfIdentifier2;
		
		numOfDigitsIdentifier2 = atoi(digitIdentifier2);
		numOfDecimalPlacesIdentifier2 = 0;
	}
	
	bool isValid = false;
	if ((numOfDecimalPlacesIdentifier1 <= numOfDecimalPlacesIdentifier2) 
				&& (numOfDigitsIdentifier1 <= numOfDigitsIdentifier2)) {
		isValid = true;
	}
	
	if (!isValid) {
		printf("Error - Line %d: The identifier %s doesn't have a valid size for Identifier %s!\n", yylineno, identifier1, identifier2);
		exit(-1);
	}
}

void checkDoubleIdCapacity(char* doubleValue, char* identifier) {
	
	// check if capacity matched between doublevalue and identifier
	removeDot(identifier);
	
	bool FLAG = false;
	for (i = 0; i < strlen(identifier) && !FLAG; i++) {
		if (identifier[i] == ' ' || identifier[i] == ';') {
			identifier[i] = '\0';
			FLAG = true;
		}
	}
	
	// treat double value as a char, same as identifier
	bool FLAG2 = false;
	for (i = 0; i < strlen(doubleValue) && !FLAG2; i++) {
		if (doubleValue[i] == ' ' || doubleValue[i] == ';') {
			doubleValue[i] = '\0';
			FLAG2 = true;
		}
	}
	
	int numOfDigitsIdentifier = 0, numOfDecimalPlacesIdentifier = 0;
	char* digitIdentifier; char* decimalPlacesIdentifier;
	char* capacityOfIdentifier;
	bool isFound = false;
	for (i = 0; i < count && !isFound; i++) {
		if (strcmp(identifiers[i], identifier) == 0) {
			isFound = true;
			capacityOfIdentifier = capacities[i];
		}
	}
	
	// capacityOfIdentifier is something like 1-2 or 2 ...
	if (strchr(capacityOfIdentifier, '-') != NULL) {
		// for the format 1-2
		digitIdentifier = strtok(capacityOfIdentifier, "-");
		decimalPlacesIdentifier = strtok(NULL, "-");
		
		numOfDigitsIdentifier = atoi(digitIdentifier);
		numOfDecimalPlacesIdentifier = atoi(decimalPlacesIdentifier);
	} else {
		// for the format 2
		digitIdentifier = capacityOfIdentifier;
		
		numOfDigitsIdentifier = atoi(digitIdentifier);
		numOfDecimalPlacesIdentifier = 0;
	}
	
	int numOfDigitsDoubleValue = 0, numOfDecimalPlacesDoubleValue = 0;
	char* digitDoubleValue; char* decimalPlaceDoubleValue;
	
	// check if there is a dot contained in the doubleValue
	if (strchr(doubleValue, '.') != NULL) {
		// for the format 1.2
		digitDoubleValue = strtok(doubleValue, ".");
		decimalPlaceDoubleValue = strtok(NULL, ".");
		
		numOfDigitsDoubleValue = strlen(digitDoubleValue);
		numOfDecimalPlacesDoubleValue = strlen(decimalPlaceDoubleValue);		
	} else {
		// for the format 1
		digitDoubleValue = doubleValue;
		decimalPlaceDoubleValue = NULL;
		
		numOfDigitsDoubleValue = strlen(digitDoubleValue);
		numOfDecimalPlacesDoubleValue = 0;
	}
	
	bool isValid = false;
	if ((numOfDecimalPlacesDoubleValue <= numOfDecimalPlacesIdentifier) 
				&& (numOfDigitsDoubleValue <= numOfDigitsIdentifier)) {
		isValid = true;
	}
	
	if (!isValid) {
		printf("Error - Line %d: This double figure doesn't have a valid size for Identifier: %s!\n", yylineno, identifier);
		exit(-1);
	}
}

void calCapacity(char* doubleType, char* identifier, char* result) {

	int frequency1, frequency2, FLAG = 0;
	char *part1, *part2;
	char *string = doubleType;
	
	printf("%s: ", string);
	for (i = 0; doubleType[i] != '\0'; ++i) {
		if (doubleType[i] == '-') {
			part1 = strtok(doubleType, "-");
			part2 = strtok(NULL, "-");
			FLAG = 1;
		}
	}
	
	if (FLAG == 0) {
		frequency1 = 0; frequency2 = 0;
		for (i = 0; doubleType[i] != '\0'; ++i) {
			if (doubleType[i] == 'x' || doubleType[i] == 'X')
				++frequency1;
		}
		printf("is the double type which specifies a %d-digit number\n", frequency1);
		
		char value1[10];
		sprintf(value1, "%d", frequency1);
		char* var = value1;
		strncpy(result, var, 5);
		
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
		printf("The double type specifies a %d-digit number with %d decimal places can be held in the variable\n", frequency1, frequency2);
		
		char value1[10];
		char value2[10];
		sprintf(value1, "%d", frequency1);
		sprintf(value2, "%d", frequency2);
		strcat(value1, "-");
		strcat(value1, value2);
		char* var = value1;
		strncpy(result, var, 5);
	}
}

void checkIdIdCapacityEqualsTo(char* identifier1, char* identifier2) {
	// check if capacity matched between identifiers
	removeDot(identifier1);
	removeDot(identifier2);
	bool FLAG = false;
	for (i = 0; i < strlen(identifier1) && !FLAG; i++) {
		if (identifier1[i] == ' ' || identifier1[i] == ';') {
			identifier1[i] = '\0';
			FLAG = true;
		}
	}
	
	bool FLAG2 = false;
	for (i = 0; i < strlen(identifier2) && !FLAG2; i++) {
		if (identifier2[i] == ' ' || identifier2[i] == ';') {
			identifier2[i] = '\0';
			FLAG2 = true;
		}
	}
	
	char* capacityOfIdentifier1;
	char* capacityOfIdentifier2;
	bool isFound = false;
	
	// the capacity of identifier1
	for (i = 0; i < count && !isFound; i++) {
		if (strcmp(identifiers[i], identifier1) == 0) {
			isFound = true;
			capacityOfIdentifier1 = capacities[i];
		}
	}
	
	// the capacity of identifier2
	isFound = false;
	for (i = 0; i < count && !isFound; i++) {
		if (strcmp(identifiers[i], identifier2) == 0) {
			isFound = true;
			capacityOfIdentifier2 = capacities[i];
		}
	}
	
	if (strcmp(capacityOfIdentifier1, capacityOfIdentifier2) != 0) {
		printf("Warning - Line %d: The capacity of Identifier 1 does not equals to the capacity of Identifier 2 %s!\n", yylineno, identifier1, identifier2);
		countWarning++;
	}
}

char* removeDot(char* c) {

	// remove the dot
	if (c[strlen(c) - 1] == '.') {
		c[strlen(c) - 1] = '\0';
	}
	
	return c;
}

char* getDoubleType(char* c) {
	
	// split by whitespace
	char* result = strtok(c, " ");
	
	return result;
}

void warningCount() {
	printf("There are %d warnings in total!\n", countWarning);
}

int main(void) {

	do {
		yyparse();
	} while (!feof(yyin));
	
	warningCount();
	
	return 0;
}

void yyerror(const char *err) {

	fprintf(stderr, "Error on line %d: %s\n", yylineno, err);
	exit(-1);
}
