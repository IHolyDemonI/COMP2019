%{
    #include <stdio.h>
    #include <stdlib.h>  
    #include <string.h>  


    extern int cmd_flag;
    int yylex();
    void yyerror(const char *s); 

    
    typedef struct node {
        char * id;
        char * type;
        struct node * nodeSon;
        struct node * nodeBrother;
    } node;

    int commaFlag = 0;
    int numNode = 0;
    int errorFlag = 0;

    char * auxType;
    node * nodeAux;

    node * insertNode(char * id, 
                      char * type, 
                      node * nodeSon
                     )
    {
        node * auxNode = (node *)malloc(sizeof(node));
        auxNode->type = type;
        auxNode->id = id;
        auxNode->nodeSon = nodeSon;
        auxNode->nodeBrother = NULL;

        return auxNode;
    }

      void linkBrother(node * node1, node * node2)
    {
        node1->nodeBrother = node2;
    }

    void printTree(node * auxNode, int pontos)
    {
        int i, call=0;

        if (auxNode!=NULL){

            if (auxNode->type!=NULL && strcmp(auxNode->type,"Comma")==0 && commaFlag == 1){
                if (auxNode->nodeSon != NULL){
                    printTree(auxNode->nodeSon,pontos);  
                }
            }
            else if (auxNode->type!=NULL && strcmp(auxNode->type,"Aux")==0){
                if (commaFlag==1){
                    commaFlag = 0;
                    if (auxNode->nodeSon != NULL)
                        printTree(auxNode->nodeSon,pontos); 
                    commaFlag = 1;    
                }
                else
                    if (auxNode->nodeSon != NULL)
                        printTree(auxNode->nodeSon,pontos);    
            }

            else{
                if (auxNode->id != NULL && strcmp(auxNode->id,"type")==0){
                    for (i = 0; i < pontos-2; i++)
                        printf(".");
                    
                    printf("%s\n", auxNode->type);
                    for (i = 0; i < pontos; i++)
                        printf(".");
                    printf("%s\n",auxType);
                
                    if (auxNode->nodeSon != NULL)
                        printTree(auxNode->nodeSon,pontos);  
                            
                }
                
                else if (auxNode->type != NULL){
                    
                    if (strcmp(auxNode->type,"Call")==0){
                        call = 1;
                        commaFlag = 1;
                    }
                    
                    if (strcmp(auxNode->type,"Declaration")==0)
                        auxType = auxNode->nodeSon->type;

                    for (i = 0; i < pontos; i++)
                        printf(".");
                    if (auxNode->id != NULL) 
                        printf("%s(%s)\n", auxNode->type, auxNode->id);
                    else   
                        printf("%s\n", auxNode->type);
                    
                    if (auxNode->nodeSon != NULL){
                        pontos+=2;
                        printTree(auxNode->nodeSon,pontos);
                        pontos-=2;
                    }
                    if (call==1)
                        commaFlag=0;  
                }
                else
                    if (auxNode->nodeSon != NULL)
                        printTree(auxNode->nodeSon,pontos);
            }
            if (auxNode->nodeBrother != NULL)
                    printTree(auxNode->nodeBrother,pontos);   
        }  
        free(auxNode);
    }
    
%}

%union{
    struct node * node;
    char * id;
}

%token <id> INTLIT
%token <id> REALLIT
%token <id> ID
%token <id> STRLIT

%type <node> Expr
%type <node> COMMA_Expr_LOOP
%type <node> Optional_Expr_with_loop
%type <node> FuncInvocation
%type <node> ParseArgs
%type <node> Optional_Expr
%type <node> Statement_SEMICOLON_LOOP
%type <node> Optional_ELSE_LBRACE
%type <node> Statement
%type <node> Optional_VarDeclaration_OR_Statement
%type <node> VarsAndStatements
%type <node> FuncBody
%type <node> COMMA_ID_Type_LOOP
%type <node> Parameters
%type <node> Optional_Type
%type <node> Optional_Parameters
%type <node> FuncDeclaration
%type <node> Type
%type <node> COMMA_ID_LOOP
%type <node> VarSpec
%type <node> VarDeclaration
%type <node> Declarations
%type <node> Program

%token SEMICOLON         
%token BLANKID
%token PACKAGE
%token RETURN	
%token AND				
%token ASSIGN	
%token STAR			
%token COMMA		
%token DIV				        
%token EQ					         
%token GE					        
%token GT					         
%token LBRACE	         
%token LE					         
%token LPAR			        
%token LSQ				        
%token LT					       
%token MINUS		     
%token MOD				    
%token NE					      
%token NOT				      
%token OR					       
%token PLUS			       
%token RBRACE	      
%token RPAR			      
%token RSQ				      
%token ELSE		      
%token FOR			     
%token IF				      
%token VAR			  
%token INT			     
%token FLOAT32
%token BOOL		    
%token STRING	    
%token PRINT	       
%token PARSEINT      
%token FUNC		       
%token CMDARGS      
%token RESERVED


%left COMMA
%right ASSIGN
%left OR
%left AND
%left EQ NE
%left LE LT GT GE
%left PLUS MINUS
%left STAR DIV MOD
%right NOT
%left LPAR RPAR LBRACE RBRACE 

%%

Program:                           
        PACKAGE ID SEMICOLON Declarations   {}
    ;

Declarations:
        EmptyState  {}
    |   Declarations VarDeclaration SEMICOLON   {}
    |   Declarations FuncDeclaration SEMICOLON  {}
    ;

VarDeclaration:
        VAR VarSpec {}
    |   VAR LPAR VarSpec SEMICOLON RPAR {}
    ;

VarSpec:
       ID COMMA_ID_LOOP Type    {}
    ;

COMMA_ID_LOOP:
        EmptyState  {}
    |   COMMA ID COMMA_ID_LOOP  {}
    ;

Type:
        INT     {}
    |   FLOAT32 {}
    |   BOOL    {}
    |   STRING  {}
    ;

FuncDeclaration:
        FUNC ID LPAR Optional_Parameters RPAR Optional_Type FuncBody    {}
    ;

Optional_Parameters:
        EmptyState  {}
    |   Parameters   {}
    ;

Optional_Type:
        EmptyState  {}
    |   Type    {}
    ;

Parameters:
        ID Type COMMA_ID_Type_LOOP  {}
    ;

COMMA_ID_Type_LOOP:
        EmptyState  {}
    |   COMMA ID Type COMMA_ID_Type_LOOP    {}
    ;

FuncBody:
        LBRACE VarsAndStatements RBRACE     {}
    ;

VarsAndStatements: 
        EmptyState  {}
    |   VarsAndStatements Optional_VarDeclaration_OR_Statement SEMICOLON    {}
    ;

Optional_VarDeclaration_OR_Statement:
        EmptyState  {}
    |   VarDeclaration      {}
    |   Statement       {}
    ;

Statement:
        ID ASSIGN Expr  {}
    |   LBRACE Statement_SEMICOLON_LOOP RBRACE  {}
    |   IF Expr LBRACE Statement_SEMICOLON_LOOP RBRACE Optional_ELSE_LBRACE {}
    |   FOR Optional_Expr LBRACE Statement_SEMICOLON_LOOP RBRACE    {}
    |   RETURN Optional_Expr    {}
    |   FuncInvocation  {}
    |   ParseArgs   {}
    |   PRINT LPAR Expr RPAR    {}
    |   PRINT LPAR STRLIT RPAR  {}
    |   error   {}
    ;

Optional_ELSE_LBRACE:
        EmptyState  {}
    |   ELSE LBRACE Statement_SEMICOLON_LOOP RBRACE {}
    ;

Statement_SEMICOLON_LOOP:
        EmptyState  {}
    |   Statement SEMICOLON Statement_SEMICOLON_LOOP    {}
    ;

Optional_Expr:
        EmptyState  {}
    |   Expr    {}
    ;


ParseArgs:
        ID COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR {}
    |   ID COMMA BLANKID ASSIGN PARSEINT LPAR error RPAR    {}
    ;

FuncInvocation:
        ID LPAR Optional_Expr_with_loop RPAR    {}
    |   ID LPAR error RPAR  {}
    ;

Optional_Expr_with_loop:
        EmptyState  {}
    |   Expr COMMA_Expr_LOOP    {}
    ;

COMMA_Expr_LOOP:
        EmptyState  {}
    |   COMMA Expr COMMA_Expr_LOOP  {}
    ;

Expr:
        Expr OR Expr    {}
    |   Expr AND Expr   {}
    |   Expr LT Expr    {}
    |   Expr GT Expr    {}
    |   Expr EQ Expr    {}
    |   Expr NE Expr    {}
    |   Expr LE Expr    {}
    |   Expr GE Expr    {}
    |   Expr PLUS Expr  {}
    |   Expr MINUS Expr {}
    |   Expr STAR Expr  {}
    |   Expr DIV Expr   {}
    |   Expr MOD Expr   {}
    |   NOT Expr    {}
    |   MINUS Expr  {}
    |   PLUS Expr   {}
    |   INTLIT  {}
    |   REALLIT {}
    |   ID  {}
    |   FuncInvocation  {}
    |   LPAR Expr RPAR  {}
    |   LPAR error RPAR {}
    ;
   
EmptyState:
    ;
%%
