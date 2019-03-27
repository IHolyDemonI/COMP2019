%{
    //Roman Zhydyk 2016231789
    //Artem Yushchynskyy 2015251647
    #include "y.tab.h"
	int yycolumn=1, auxC, auxL;
    int gotSemicolon = 0;
    int cmd_flag;
    int valid_strlit = 1;
    int strSize = 0;
    int rbrace = 0;
    char *str;
%}


DECIMAL				[0-9]              
OCTAL				[0-7]             
HEXA				[a-f]|[A-F]     
LETTER				[a-z]|[A-Z]|"_"
SEMICOLON 			";"              
BLANKID				"_"             
PACKAGE				"package"        
RETURN				"return"        
AND					"&&"               
STAR				"*"                  
COMMA				","                     
DIV					"/"                     
ASSIGN				"="                       
EQ					"=="                        
GE					">="                       
GT					">"                          
LBRACE 				"{"                       
LE 					"<="                         
LPAR 				"("                        
LSQ 				"["                           
LT 					"<"                       
MINUS				"-"                        
MOD 				"%"                
NE 					"!="                 
NOT 				"!"              
OR 					"||"              
PLUS 				"+"              
RBRACE 				"}"             
RPAR 				")"              
RSQ 				"]"                 
ELSE 				"else"                
FOR 				"for"                  
IF 					"if"                   
VAR 				"var"                
INT 				"int"                   
FLOAT32 			"float32"                  
BOOL 				"bool"                    
STRING				"string"                     
PRINT 				"fmt.Println"                   
PARSEINT 			"strconv.Atoi"                  
FUNC 				"func"                          
CMDARGS 			"os.Args"  
STRLIT 				\"([^\n\r\"\\]|(\\f|\\n|\\r|\\t|\\\\|\\\"))*\"                     
                                                          
INTLIT				(0(x|X)({HEXA}|{DECIMAL})+)|(0{OCTAL}+)|{DECIMAL}+                                                  

REALLIT				(({DECIMAL})*\.?({DECIMAL})+|({DECIMAL})+\.?({DECIMAL})*)((e|E)[\-\+]?({DECIMAL})+)? 
RESERVED			"++"|"--"|"break"|"default"|"interface"|"select"|"case"|"defer"|"go"|"map"|"struct"|"chan"|"goto"|"package"|"switch"|"const"|"fallthrough"|"range"|"type"|"continue"|"for"|"import"
ESCSEQ				\\t|\\n|\\f|\\r|\\\\|\\\"
ID 					{LETTER}({LETTER}|{DECIMAL})*
NEWLINE				"\n"|"\r"|"\r\n"
IGNORE 				" "|"\t"|\v|\f


%X MULTIPLE_LINE_COMMENT
%X STR

%%

\/\/.*                            	{yycolumn+=yyleng;};

"/*"								{BEGIN MULTIPLE_LINE_COMMENT; auxC = yycolumn; auxL = yylineno; yycolumn += yyleng;}

<MULTIPLE_LINE_COMMENT>{NEWLINE}	{yylineno++;yycolumn=1;if(gotSemicolon && cmd_flag == 1);
                                    gotSemicolon = 0;}

<MULTIPLE_LINE_COMMENT><<EOF>>		{printf("Line %d, column %d: unterminated comment\n", auxL, auxC);
                                    BEGIN 0;}

<MULTIPLE_LINE_COMMENT>.			{yycolumn+=yyleng;}

<MULTIPLE_LINE_COMMENT>"*/"			{yycolumn+=yyleng;
									BEGIN 0;}

{STRLIT}							{if(cmd_flag == 1){printf("STRLIT(%s)\n", yytext);} yycolumn+=yyleng; {yylval.id = (char*) strdup(yytext); return STRLIT;}}
"\""								{BEGIN STR;
                                    auxC = yycolumn; 
                                    auxL = yylineno; 
                                    yycolumn += yyleng;            
                                    valid_strlit = 1;
                                    str = realloc(str,strSize+1);
                                    str[strSize] = yytext[0];
                                    strSize++;
                                    gotSemicolon=1;}
									

<STR>{NEWLINE}				    {yylineno++;yycolumn=1;
								    printf("Line %d, column %d: unterminated string literal\n", auxL, auxC);
								    gotSemicolon = 0;
                                    valid_strlit = 0;
                                    memset(str,0,strSize);
                                    strSize = 0;
                                    BEGIN 0;}


<STR>{ESCSEQ}				    {yycolumn+=yyleng;
                                    str = realloc(str,strSize+2);
                                    str[strSize] = yytext[0];
                                    str[strSize+1] = yytext[1];
                                    strSize+=2;}

<STR>(\\.|\\)				    {printf("Line %d, column %d: invalid escape sequence (%s)\n", yylineno, yycolumn, yytext);
								    yycolumn+=yyleng;
                                    valid_strlit=0;
                                    gotSemicolon=0;
                                    memset(str,0,strSize);
                                    strSize = 0;}

<STR><<EOF>>				        {yycolumn+=yyleng;
                                    printf("Line %d, column %d: unterminated string literal\n", auxL, auxC);
                                    gotSemicolon = 0;
                                    memset(str,0,strSize);
                                    strSize = 0;
                                    BEGIN 0;}

<STR>"\""  					    {yycolumn+=yyleng;
                                    str = realloc(str,strSize+1);
                                    str[strSize] = yytext[0];
                                    strSize++;
                                    if(valid_strlit && cmd_flag == 1){
                                        printf("STRLIT(");
                                        for(int i = 0;i < strSize; i++){
                                            printf("%c", str[i]);
                                        }
                                        printf(")\n");
                                        
                                        gotSemicolon = 1;
                                        valid_strlit = 0;

                                        yylval.id=(char*)strdup(yytext);
										return STRLIT;
                                    }

                                    memset(str,0,strSize);
                                    strSize = 0;
                                    BEGIN 0;}


<STR>.						    {yycolumn+=yyleng;
                                    str = realloc(str,strSize+1);
                                    str[strSize] = yytext[0];
                                    strSize++;}


{SEMICOLON}				{if (cmd_flag == 1) printf("SEMICOLON\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return SEMICOLON;}                     
{BLANKID}				{if (cmd_flag == 1) printf("BLANKID\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return BLANKID;}                     
{PACKAGE}				{if (cmd_flag == 1) printf("PACKAGE\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return PACKAGE;}                     
{RETURN}				{if (cmd_flag == 1) printf("RETURN\n"); yycolumn += yyleng;gotSemicolon = 1;
                        return RETURN;}                     
{AND}					{if (cmd_flag == 1) printf("AND\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return AND;}     
{ASSIGN}				{if (cmd_flag == 1) printf("ASSIGN\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return ASSIGN;}  
{STAR}					{if (cmd_flag == 1) printf("STAR\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return STAR;}    
{COMMA}					{if (cmd_flag == 1) printf("COMMA\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return COMMA;}   
{DIV}					{if (cmd_flag == 1) printf("DIV\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return DIV;}     
{EQ}					{if (cmd_flag == 1) printf("EQ\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return EQ;}      
{GE}					{if (cmd_flag == 1) printf("GE\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return GE;}      
{GT}					{if (cmd_flag == 1) printf("GT\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return GT;}          
{LBRACE}		        {if (cmd_flag == 1) printf("LBRACE\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return LBRACE;}      
{LE}					{if (cmd_flag == 1) printf("LE\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return LE;}          
{LPAR}					{if (cmd_flag == 1) printf("LPAR\n"); yycolumn += yyleng; gotSemicolon = 0; 
                        return LPAR;}    
{LSQ}					{if (cmd_flag == 1) printf("LSQ\n"); yycolumn += yyleng; gotSemicolon = 0; 
                        return LSQ;}         
{LT}					{if (cmd_flag == 1) printf("LT\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return LT;}          
{MINUS}					{if (cmd_flag == 1) printf("MINUS\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return MINUS;}       
{MOD}					{if (cmd_flag == 1) printf("MOD\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return MOD;}     
{NE}					{if (cmd_flag == 1) printf("NE\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return NE;}          
{NOT}					{if (cmd_flag == 1) printf("NOT\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return NOT;}         
{OR}					{if (cmd_flag == 1) printf("OR\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return OR;}              
{PLUS}					{if (cmd_flag == 1) printf("PLUS\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return PLUS;}            
{RBRACE}				{if (cmd_flag == 1) printf("RBRACE\n"); yycolumn += yyleng; gotSemicolon = 1; 
                        return RBRACE;}          
{RPAR}					{if (cmd_flag == 1) printf("RPAR\n"); yycolumn += yyleng; gotSemicolon = 1; 
                        return RPAR;}            
{RSQ}					{if (cmd_flag == 1) printf("RSQ\n"); yycolumn += yyleng; gotSemicolon = 1; 
                        return RSQ;}             
{ELSE}					{if (cmd_flag == 1) printf("ELSE\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return ELSE;}            
{FOR}					{if (cmd_flag == 1) printf("FOR\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return FOR;}                 
{IF}					{if (cmd_flag == 1) printf("IF\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return IF;}              
{VAR}					{if (cmd_flag == 1) printf("VAR\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return VAR;}             
{INT}					{if (cmd_flag == 1) printf("INT\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return INT;}             
{FLOAT32}				{if (cmd_flag == 1) printf("FLOAT32\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return FLOAT32;}             
{BOOL}					{if (cmd_flag == 1) printf("BOOL\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return BOOL;}            
{STRING}				{if (cmd_flag == 1) printf("STRING\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return STRING;}          
{PRINT}					{if (cmd_flag == 1) printf("PRINT\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return PRINT;}               
{PARSEINT}				{if (cmd_flag == 1) printf("PARSEINT\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return PARSEINT;}                
{FUNC}					{if (cmd_flag == 1) printf("FUNC\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return FUNC;}                
{CMDARGS}				{if (cmd_flag == 1) printf("CMDARGS\n"); yycolumn += yyleng; gotSemicolon = 0;
                        return CMDARGS;}                 
{RESERVED}				{if (cmd_flag == 1) printf("RESERVED(%s)\n",yytext); yycolumn += yyleng; gotSemicolon = 0;
                        return RESERVED;}                     

{INTLIT}				{if (cmd_flag == 1) printf("INTLIT(%s)\n",yytext); gotSemicolon = 1; yycolumn += yyleng;
                        yylval.id=(char*)strdup(yytext);
                        return INTLIT;}
{REALLIT}				{if (cmd_flag == 1) printf("REALLIT(%s)\n",yytext); gotSemicolon = 1; yycolumn += yyleng;
                        yylval.id=(char*)strdup(yytext);
                        return REALLIT;}			
{ID}					{if (cmd_flag == 1) printf("ID(%s)\n",yytext); gotSemicolon = 1; yycolumn += yyleng;
                        yylval.id=(char*)strdup(yytext);
                        return ID;}

{NEWLINE}				{yylineno++; yycolumn = 1; if (gotSemicolon && cmd_flag == 1)printf("SEMICOLON\n");
                        if (gotSemicolon){gotSemicolon=0; return SEMICOLON;}}               


{IGNORE}				{yycolumn+=yyleng;}				
.						{printf("Line %d, column %d: illegal character (%s)\n", yylineno, yycolumn, yytext);yycolumn+=yyleng;}
%%

int yywrap() {
	return 1;
}

void yyerror(char *s) {
	    printf("Line %d, column %d: %s: %s\n",yylineno ,yycolumn - (int)yyleng ,s ,yytext);
}

int main(int argc, char **argv) {
    if (argc > 1) {
        if (argv[1][0]=='-' && argv[1][1]=='l'){
            cmd_flag=1;
            //yylex();
        }
        else if(argv[1][0]=='-' && argv[1][1]=='t'){
            cmd_flag = 2;
        }
    }
    yyparse();
    return 0;
}
