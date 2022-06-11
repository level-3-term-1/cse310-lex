%option noyywrap
%x state_string
%x state_single_line_comment
%x state_multi_line_comment
%x state_character

%{
#include<stdio.h>

#include<iostream>
#include<stdlib.h>
#include<string>
using namespace std;

int line_count=1;
string taking_string = "";

FILE *logout;
FILE *tokenout;

void printToken(string type, char* id){
    cout << type << ", " << id << endl;
    // printf("%s, %s\n", type, id);
}


void printString(string type, string str){
    cout << type << ", " << str << endl;
    // printf("%s, %s\n", type, id);
}


void printToken(string type, char id){
    cout << type << ", " << id << endl;
}
void printKeyword(string type, char* id){
    cout << type << ", " << id << endl;
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

string fixString(string str){
    cout << "before " << str << endl;
    for(int i = 0; i < str.size(); i++){
        if(str[i] == '\\' && str[i+1] == 't'){
            str.erase(i + 1, 1);
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
    // cout << str << endl;
    return str;
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
                       printString("string", fixString(taking_string));
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
                        cout << "unfinished_string" << endl;
                        line_count ++;
                        BEGIN INITIAL;
}




"//"                {
                        BEGIN state_single_line_comment;
                        printf("statring single line comment\n");
}

<state_single_line_comment>.*\\ {
                        line_count++;
                        // cout << line_count << endl;
}

<state_single_line_comment>.*\n {
                        line_count++;
                        printf("ending comment\n");
                        BEGIN INITIAL;
}

"/*"                {
                        BEGIN state_multi_line_comment;
                        printf("starting multiline comment\n");
}

<state_multi_line_comment>([*][/]) {
    BEGIN INITIAL;
                        printf("ending multiline\n");
}
<state_multi_line_comment>(.|{special_character_2}) {
                        // cout << yytext << endl;
                        if(yytext[0] == '\n') line_count ++;

                        // printf("ending multiline \t %s", yytext);
}
<state_multi_line_comment><<EOF>> {
                        cout << "unfinished_comment" << endl;
                        BEGIN INITIAL;
}

{decimal_point_error}({digit}*[.]*)* {
                        cout << yytext << endl;
                        cout << "decimal_point_error" << endl;
}

{ill_formed_number} {
                        cout << yytext << endl;
                        cout << "ill_formed_number" << endl;
}

{non_id}            {
                        cout << yytext << endl;
                        cout << "non id" << endl;
}

{multi_character_constant_error}  {
                        cout << yytext << endl;
                        cout << "multi_character_constant_error" << endl;
}

{unfinished_character}      {
                        cout << yytext << endl;
                        string str = yytext;
                        for(int i = 0; i < str.size(); i++){
                            if(str[i] == '\n') line_count ++;
                        }
                        cout << "unfinished_character" << endl;
}

{empty_character}       {
                        cout << yytext << endl;
                        cout << "empty_character" << endl;
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
