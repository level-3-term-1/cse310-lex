%option noyywrap

%{
#include<stdio.h>

#include<iostream>
#include<stdlib.h>
#include<string>
using namespace std;

int line_count=1;

FILE *logout;
FILE *tokenout;

void printToken(string type, char* id){
    cout << type << ", " << id << endl;
    // printf("%s, %s\n", type, id);
}


void printToken(string type, char id){
    cout << type << ", " << id << endl;
    // printf("%s, %s\n", type, id);
}

char convertStringToChar(string str){
    if(str == "\\n") return '\n';
    if(str == "\\t") return '\t';
    if(str == "\\\\") return '\\';
    if(str == "\\\'") return '\'';
    if(str == "\\\"") return '\"';
    if(str == "\\a") return '\a';
    if(str == "\\f") return '\f';
    if(str == "\\r") return '\r';
    if(str == "\\b") return '\b';
    if(str == "\\v") return '\v';
    if(str == "\\0") return '\0';
    
    //error
    return ' ';
}

%}


delim [ \t\v\r\f]
ws {delim}+
digit [0-9]
letter [A-Za-z]
special_character ((\\n)|(\\t)|(\\\\)|(\\\')|(\\\")|(\\a)|(\\f)|(\\r)|(\\b)|(\\v)|(\\0))
float_number {digit}*(\.{digit}+)?(E[+-]?{digit}+)?
const_char ((\'([^\\]|{special_character})\'))

addop [+-]
mulop [*/%]
incop (\+\+|--)
relop (<|(<=)|>|(>=)|(==)|(!=))
assignop =
logicop (&&|\|\|)
not (!)
lparen [(]
rparen [)]
lcurl [{]
rcurl [}]
lthird [[]
rthird []]
comma (,)
semicolon (;)
identifier [A-Za-z_]+[A-Za-z0-9_]*


%%
[\n]                {line_count ++;}
{ws}                {}
{digit}+            {
                        printToken("CONST_INT", yytext);

                    }

{float_number}      {
                        printToken("CONST_FLOAT", yytext);
}
{const_char}        {
                        char* str= yytext;
                        // cout << yytext << endl;
                        int len = strlen(yytext);
                        str[len - 1] = '\0';
                        str++;
                        len = strlen(str);
                        char a = str[0];
                        if(len>= 2) a = convertStringToChar(str);
                        printToken("CONST_CHAR", a);
}


{addop}             {
                        printToken("ADDOP", yytext);
}

{incop}          {
                        printToken("INCOP", yytext);
}
{mulop}            {
                        printToken("MULOP", yytext);
}    


{relop}             {
                        printToken("RELOP", yytext);
}

{assignop}             {
                        printToken("ASSIGNOP", yytext);
}


{logicop}             {
                        printToken("LOGICOP", yytext);
}


{not}             {
                        printToken("NOT", yytext);
}


{lparen}             {
                        printToken("LPAREN", yytext);
}

{rparen}             {
                        printToken("RPAREN", yytext);
}


{lcurl}             {
                        printToken("LCURL", yytext);
}

{rcurl}             {
                        printToken("RCURL", yytext);
}


{lthird}            {
                        printToken("LTHIRD", yytext);
}

{rthird}            {
                        printToken("RTHIRD", yytext);
}

{comma}             {
                        printToken("COMMA", yytext);
}
{semicolon}         {
                        printToken("SEMICOLON", yytext);
}

{identifier}        {
                        printToken("IDENTIFIER", yytext);
}







%%



int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout= fopen("log.txt","w");
	tokenout= fopen("token.txt","w");

	yyin= fin;
	yylex();
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
    printf("%d\n", line_count);
	return 0;
}
