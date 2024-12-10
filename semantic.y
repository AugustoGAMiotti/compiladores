%{ 
/* Para simplificar a notação, S é para sintetizar. A atualizar. V verificar */
void yyerror(char *s);
#include "analex.c" 
#include "codigo.h" 
/* Funcoes auxiliares podem ser declaradas aqui */
void verifica_var_declarada(?);
%}

%union{
	struct no{
		int place;
		char *code;
		int tipo;
	} node;
	int val;
	struct ids{
		int ids[50];
		int tam;
		char *code;
	} id_list;
}

%token <node> NUM 
%token <val> ID 
%token WHILE
%token IF 
%token ELSE
%token ENDIF
%token CHAR
%token INT
%token FLOAT
%token VOID
%token OR
%token AND
%token NOT
%token GE
%token LE
%token EQ
%token NEQ
%token DO
%token STRING

%type <val> Type TypeF
%type <id_list> IDs ParamList ArgList
%type <node> Atribuicao Exp Function Prog Statement Statement_Seq
%type <node> If While Compound_Stt DoWhile FunctionCall

%right '='

%left OR
%left AND

%nonassoc EQ NEQ

%left '>' '<' GE LE

%left '+' '-'
%left '*' '/' '%'

%right NOT

%right '(' '['


%start ProgL
%% 
ProgL : Prog { printf("%s",$1.code);} /* S código. */
    ;
    
Prog : Prog Function {create_cod(&$$.code); insert_cod(&$$.code,$1.code); insert_cod(&$$.code,$2.code);} /* S código. */
	| Function /* S código. */
	;	

Function :
	TypeF ID '(' ParamList ')' '{' Decls Statement_Seq '}'  {?} /* A. Tabela. S código. */
	| TypeF ID '(' ')' '{' Decls Statement_Seq '}'  {?} /* A. Tabela. S código. */
	;
	
FunctionCall :
    ID '(' ArgList ')' {?} /* V declaração, # argumentos. S código*/
	| ID '(' ')' {?} /* V declaração, # argumentos. S código*/
    ;
    
ArgList:
    Exp ',' ArgList {?} /* S código e Lista de IDs*/
    | Exp  {?} /* S código e Lista de IDs*/
    ;

ParamList: 
    ParamList ',' Type ID  {?} /* S Lista de IDs. A Tabela*/
    | Type ID {?} /* S Lista de IDs. A Tabela*/
	; 
		
Decls:
	  Decl ';' Decls  
	| 
	;

Decl:
	Type IDs {?} /* A tabela. */
	; 
	
IDs :
	  IDs ',' ID {for(int i = 0; i < $1.tam; i++
				$$.ids[i] = $1.ids[i];
			} 
			$1.tam = $1.tam;
			$1.ids[tam++] = $3;/* S Lista de IDs. */
	| IDs ',' Atribuicao {?} /* S Lista de IDs. */
	| IDs ',' ID '[' NUM ']' {?} /* S Lista de IDs. */
	| ID '[' NUM ']' {?} /* S Lista de IDs. */
	| ID {?} /* S Lista de IDs. */
	| Atribuicao {?} /* S Lista de IDs. */
	;
	
TypeF :
	  VOID {?} /* S Tipo. */
	| Type
	;

Type :
	  INT {?} /* S Tipo. */
	| CHAR {?} /* S Tipo. */
	| FLOAT {?} /* S Tipo. */
	;
			
Statement_Seq :
	Statement Statement_Seq {?} /* S Codigo. */
	| Statement { create_cod(&$$.code); insert_cod(&$$.code,$1.code);} /* S Codigo. Exemplo */
	;
		
Statement: 
	  Atribuicao ';' {$$.place = $1.place; verifica_var_declarada($1.place); tipos_inconsistentes_atrib(Tabela[$1.place].tipo, $1.tipo);} /* V declaracao, tipos atribuicao. */
	| If  /* S código. */
	| While /* S código. */
	| DoWhile /* S código. */
	| FunctionCall ';'  /* S código. */
	;

Compound_Stt :
	  Statement  /* S código. Exemplo resolvido */
	| '{' Statement_Seq '}' {$$ = $2;}  /* S código. Exemplo resolvido */
	;
		
If :
	  IF '(' Exp ')' Compound_Stt ENDIF { If(?,?,?); } /* S código. Exemplo */
	| IF '(' Exp ')' Compound_Stt ELSE Compound_Stt ENDIF {?} /* S código. */
	;

While:
	WHILE '(' Exp ')' Compound_Stt  {?} /* S código. */
	;

DoWhile:
	DO Compound_Stt WHILE '(' Exp ')' ';' {?} /* S código. */
	;
			
Atribuicao : ID '[' NUM ']' '=' Exp {if(Tabela[$1].tipo == -1) yyerror("Erro: tipo não declarado");
									 if($3.tipo != Int) yyerror("Erro: indice do vetor incorreto");
									 tipos_inconsistentes_atrib(Tabela[$1].tipo, $6.tipo);
									 $$.tipo = $1;
									 $$.place = $1;} /* V tipo indice. S tipo, place, código. */
    | ID '=' Exp {if(Tabela[$1].tipo == -1) yyerror("Erro: tipo não declarado");
				  tipos_inconsistentes_atrib(Tabela[$1].tipo, $3.tipo);
				  $$.tipo = $1;
				  $$.place = $3;} /* S tipo, place, código. */
	;
				
Exp :
	  Exp '+' Exp {$$.tipo = retorna_maior_tipo($1.tipo, $3.tipo); ExpAri(&$$, "add", $1, $3);} /* S tipo, cod */
	| Exp '-' Exp {$$.tipo = retorna_maior_tipo($1.tipo, $3.tipo); ExpAri(&$$, "sub", $1, $3);} /* S tipo, cod */
	| Exp '*' Exp {$$.tipo = retorna_maior_tipo($1.tipo, $3.tipo); ExpAri(&$$, "mul", $1, $3);} /* S tipo, cod */
	| Exp '/' Exp {$$.tipo = retorna_maior_tipo($1.tipo, $3.tipo); ExpAri(&$$, "div", $1, $3);} /* S tipo, cod */
	| Exp '>' Exp {$$ = INT; ExpRel(&$$, "bgt", $1, $3);} /* S tipo, cod (bgt) */
	| Exp '<' Exp {$$ = INT; ExpRel(&$$, "blt", $1, $3);} /* S tipo, cod (blt) */
	| Exp GE Exp {$$ = INT;} /*  S tipo. Não precisa implementar código*/
	| Exp LE Exp {$$ = INT;} /*  S tipo. Não precisa implementar código*/
	| Exp EQ Exp {$$ = INT;} /*  S tipo. Não precisa implementar código*/
	| Exp NEQ Exp {$$ = INT;} /*  S tipo. Não precisa implementar código*/
	| Exp OR Exp {$$ = INT;} /* S tipo, cod */
	| Exp AND Exp {$$ = INT;} /* S tipo, cod */
	| NOT Exp {$$ = INT;} /*  S tipo. Não precisa implementar código*/
	| '(' Exp ')' {&$$ = $2} /*  S tipo, cod*/
	| NUM {Li(&$$, $1.place)} /* S tipo, código */
	| ID '[' NUM ']' {if(Tabela[$1].tipo == -1) yyerror("Erro: indice não encontrado");
					  &$$.tipo = Tabela[$1].tipo;
					  if($3.tipo != Int) yyerror("Erro no indice do vetor");}  /* V declaracao, indice. S tipo, codigo  */
	| ID  {if(Tabela[$1].tipo == -1) yyerror("Erro: indice não encontrado");
		   &$$.tipo = Tabela[$1].tipo;} /* V declaracao. S tipo, codigo  */
	| STRING {} /* Ignore, não precisa implementar  */
	;   
	
	
%%  
int main(int argc, char **argv) {     
  yyin = fopen(argv[1],"r");
  yyparse();      
} 

/* Funcoes auxiliares podem ser implementadas aqui */
void verifica_var_declarada(?){
	?
}
