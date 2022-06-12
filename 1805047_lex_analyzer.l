%option noyywrap
%x state_string
%x state_single_line_comment
%x state_multi_line_comment
%x state_character

%{
#include<stdio.h>
#include "1805047_symbol_table.h"
#include<iostream>
#include<algorithm>
#include<stdlib.h>
#include<string>
using namespace std;

int line_count=1;
int error_count = 0;
string taking_string = "";

FILE *logout;
FILE *tokenout;

string fixString(string str){
    // cout << "before " << str << endl;
    for(int i = 0; i < str.size(); i++){
        if(str[i] == '\\' && str[i+1] == 't'){
            str.erase(i + 1, 1);
            // cout << "tab" << endl;
            str[i] = '\t';
        }
        else if(str[i] == '\\' && str[i+1] == 'n'){
            str.erase(i + 1, 1);
            str[i] = '\n';
        }
        else if(str[i] == '\\' && str[i+1] == '\"'){
            str.erase(i + 1, 1);
            str[i] = '\"';
        }
        else if(str[i] == '\\' && str[i+1] == '\''){
            str.erase(i + 1, 1);
            str[i] = '\'';
        }
        else if(str[i] == '\\' && str[i+1] == '\\'){
            str.erase(i + 1, 1);
            str[i] = '\\';
        }
        else if(str[i] == '\\' && str[i+1] == 'b'){
            str.erase(i + 1, 1);
            str[i] = '\b';
        }
        else if(str[i] == '\\' && str[i+1] == 'f'){
            str.erase(i + 1, 1);
            str[i] = '\f';
        }
        else if(str[i] == '\\' && str[i + 1] == '\n'){
            //new line
            // cout << line_count << endl;
            str.erase(i , 2);
            i--;
        }
    }
    return str;
}

void printToken(string type, char* id){
    fprintf(tokenout, "<%s, %s>",type.c_str(), id);
    fprintf(logout, "Line no %d: Token <%s> Lexeme %s found\n", line_count, type.c_str(), id);
}


void printString(string type, string str){
    string actual_string = fixString(str);
    fprintf(tokenout, "<%s, %s>",type.c_str(), actual_string.c_str());
    fprintf(logout, "Line no %d: Token <%s> Lexeme %s found\n", line_count, type.c_str(), str.c_str());
}


void printChar(string type, char id){
    fprintf(tokenout, "<%s, %c>",type.c_str(), id);
    fprintf(logout, "Line no %d: Token <%s> Lexeme %c found\n", line_count, type.c_str(), id);
}
void printKeyword(string type, char* id){
    string up(id);
    transform(up.begin(), up.end(), up.begin(), ::toupper);
    fprintf(tokenout, "<%s>", up.c_str());
    fprintf(logout, "Line no %d: Token <%s> Lexeme %s found\n", line_count, up.c_str(), id);
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

void printErrorLog(string str){
    fprintf(logout, "Error at Line no %d: %s\n", line_count, str.c_str());
    error_count++;
}

void printCommentLog(){
    fprintf(logout, "Line no %d: Token COMMENT Lexeme %s\n", line_count, taking_string.c_str());
}


%}


delim [ \t\v\r\f]
ws {delim}+
digit [0-9]
letter [A-Za-z]
special_character ((\\n)|(\\t)|(\\\\)|(\\\')|(\\\")|(\\a)|(\\f)|(\\r)|(\\b)|(\\v)|(\\0))
float_number (({digit}*(\.{digit}+)?)|({digit}+))(E[+-]?{digit}+)?
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
keywords ((if)|(else)|(for)|(while)|(do)|(break)|(int)|(char)|(float)|(double)|(void)|(return)|(switch)|(case)|(default)|(continue))
special_character_2 ((\n)|(\t)|(\\)|(\')|(\")|(\a)|(\f)|(\r)|(\b)|(\v)|(\0))
special_character_3 ((\t)|(\\)|(\')|(\")|(\a)|(\f)|(\r)|(\b)|(\v)|(\0))

decimal_point_error ({digit}*[.]{digit}*[.])
ill_formed_number {digit}*([.]{digit}*)*([E]+[+-]*({digit}*)([.]{digit}*)*)*

non_id {float_number}({digit}*[.]*)*{identifier}+
multi_character_constant_error ((\'(([^\\\']|{special_character}){2,})\'))
unfinished_character ((\'(([^\\\']|{special_character}){1,})))
empty_character ['][']



%%
[\n]                {line_count ++;}
{ws}                {}

{keywords}          {
                        printKeyword("keywords", yytext);
}

{digit}+            {
                        printToken("CONST_INT", yytext);

                    }

{float_number}      {
                        printToken("CONST_FLOAT", yytext);
}
{const_char}        {
                        char* str= yytext;
                        int len = strlen(yytext);
                        str[len - 1] = '\0';
                        str++;
                        len = strlen(str);
                        char a = str[0];
                        if(len>= 2) a = convertStringToChar(str);
                        if(!(len >= 2 && a == ' '))
                            printChar("CONST_CHAR", a);
                        else {
                            printErrorLog("invalid character");
                        }
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
                        printToken("ID", yytext);
}


["]                 {
                        BEGIN state_string;
                        // printf("starting string state\n");
                        taking_string = "";
}
<state_string>["]   {
                        BEGIN INITIAL;

                    //    cout << yytext << endl;
                        // printf("close string state\n");
                        // cout <<"final "<< endl <<  taking_string << endl;
                       printString("STRING", taking_string);
}

<state_string>\\\"    {
                    //    printf("\nhandled\n");
                       taking_string += yytext;
}

<state_string>\\\n    {
                    //    printf("\nhandled\n");
                       taking_string += yytext;
                       line_count ++;
}

<state_string>(.|{special_character_3}) {
                        // cout << "printing " << yytext << " " << (int)yytext[0] << endl;
                        taking_string += yytext;
}
<state_string>\n  {
                        // cout << "unfinished_string" << endl;
                        printErrorLog("unfinished string");
                        line_count ++;
                        BEGIN INITIAL;
}




"//"                {
                        BEGIN state_single_line_comment;
                        taking_string = yytext;
                        // printf("statring single line comment\n");
}

<state_single_line_comment>.*\\ {
                        line_count++;
                        taking_string += yytext;
                        // cout << line_count << endl;
}

<state_single_line_comment>.*\n {
                        line_count++;
                        taking_string += yytext;
                        // printf("ending comment\n");
                        printCommentLog();
                        BEGIN INITIAL;
}

"/*"                {
                        BEGIN state_multi_line_comment;
                        taking_string = yytext;
                        // printf("starting multiline comment\n");
}

<state_multi_line_comment>([*][/]) {
                        BEGIN INITIAL;
                        taking_string += yytext;
                        printCommentLog();
                        // printf("ending multiline\n");
}
<state_multi_line_comment>(.|{special_character_2}) {
                        // cout << yytext << endl;
                        taking_string += yytext;
                        if(yytext[0] == '\n') line_count ++;

                        // printf("ending multiline \t %s", yytext);
}
<state_multi_line_comment><<EOF>> {
                        printErrorLog("unfinished comment");
                        // cout << "unfinished_comment" << endl;
                        BEGIN INITIAL;
}

{decimal_point_error}({digit}*[.]*)* {
                        // cout << yytext << endl;
                        // cout << "decimal_point_error" << endl;
                        printErrorLog("decimal point error");
}

{ill_formed_number} {
                        // cout << yytext << endl;
                        // cout << "ill_formed_number" << endl;
                        printErrorLog("ill formed number");
}

{non_id}            {
                        // cout << yytext << endl;
                        // cout << "non id" << endl;
                        printErrorLog("invalid identifier");
}

{multi_character_constant_error}  {
                        // cout << yytext << endl;
                        // cout << "multi_character_constant_error" << endl;
                        printErrorLog("multi character constant error");
}

{unfinished_character}      {
                        // cout << yytext << endl;
                        string str = yytext;
                        for(int i = 0; i < str.size(); i++){
                            if(str[i] == '\n') line_count ++;
                        }
                        printErrorLog("unfinished character");
                        // cout << "unfinished_character" << endl;
}

{empty_character}       {
                        // cout << yytext << endl;
                        // cout << "empty_character" << endl;
                        printErrorLog("empty character");
}

.                       {
                            // cout<< "unrecognized_character" << endl;
                            printErrorLog("unrecognized character");
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
    fprintf(logout, "Total lines: %d\n", line_count);
    fprintf(logout, "Total errors: %d\n", error_count);
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}
