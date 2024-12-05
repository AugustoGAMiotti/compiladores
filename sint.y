%union{
  struct no3 {
    int place;
    char *code;
    int len;
  } node;
}

%{
#include "analex.c"
#include "auxiliar.h"
#include "codigo.h"

char aux[30], aux1[30], aux2[30];

%}
%token <node> ID
%token <node> NUM
%token IF
%token ELSE
%token WHILE
%token DO
%token FOR
%token INT
%token FLOAT
%token CHAR
%token DOUBLE
%token E_OP
%token GE_OP
%token LE_OP
%token L_OP
%token G_OP
%token STRING
%token E_COMMERCE
%token DIFF
%token AND
%token OR

%type <node> Atr Exp ExpLog ChamadaFunc ExpRel IfSt BlocoComando ListaComandos ForSt WhileSt DoSt DeclaracaoFunc Declaracoes

%left AND OR
%left GE_OP LE_OP L_OP G_OP E_OP DIFF '!'
%left '+' '-'
%left '*' '/'
%start Prog
%%

Prog : Declaracoes {
    insere_cod(&$1.code,"\t\tHALT");
    imprime_cod(&$1.code);
};

//Talvez preciso de ChamadaFunc
ChamadaFunc : ID '(' ListaExp ')';

Tipo: INT
	| FLOAT
	| DOUBLE
	| CHAR;

Declaracoes: DeclaracaoFunc Declaracoes{
    $$.place = newTemp();
    create_cod(&$$.code);
    insere_cod(&$$.code,$1.code);
    }
    | DeclaracaoVar Declaracoes {
    $$.place = newTemp();
    create_cod(&$$.code);
    insere_cod(&$$.code,$2.code);

}
		|{
    create_cod(&$$.code);
};

//talvez preciso de BlocoComando
DeclaracaoFunc: Tipo ID '(' ListaArgumentos ')' BlocoComando {
    $$.place = newTemp();
    create_cod(&$$.code);
    insere_cod(&$$.code,$6.code);
}
		| ID '(' ListaArgumentos ')' BlocoComando{
    $$.place = newTemp();
    create_cod(&$$.code);
    insere_cod(&$$.code,$5.code);
};

DeclaracaoVar: Tipo ID ';'
		|Tipo Atr ';';

ListaArgumentos : Tipo ID ',' ListaArgumentos
		|;

ListaExp: Exp ';' ListaExp
		|;

Atr : ID '=' Exp {
		create_cod(&$$.code);
		insere_cod(&$$.code,$3.code);
		sprintf(aux,"\t\tMOV AX,%s\n", getNome($3.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV %s,AX\n", getNome($1.place));
		insere_cod(&$$.code,aux);



	};

Exp : Exp '+' Exp {
		$$.place = newTemp();
		create_cod(&$$.code);
		insere_cod(&$$.code,$1.code);
		insere_cod(&$$.code,$3.code);
		sprintf(aux,"\t\tMOV AX,%s\n", getNome($1.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV DX,%s\n", getNome($3.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tADD AX, DX\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV %s,AX\n", getNome($$.place));
		insere_cod(&$$.code,aux);
        }
	| Exp '-' Exp {
		$$.place = newTemp();
		create_cod(&$$.code);
		insere_cod(&$$.code,$1.code);
		insere_cod(&$$.code,$3.code);
		sprintf(aux,"\t\tMOV AX,%s\n", getNome($1.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV DX,%s\n", getNome($3.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tSUB AX, DX\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV %s,AX\n", getNome($$.place));
		insere_cod(&$$.code,aux);
        }
	| Exp '*' Exp{
		$$.place = newTemp();
		create_cod(&$$.code);
		insere_cod(&$$.code,$1.code);
		insere_cod(&$$.code,$3.code);
		sprintf(aux,"\t\tMOV AX,%s\n", getNome($1.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV DX,%s\n", getNome($3.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMULT AX, DX\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV %s,AX\n", getNome($$.place));
		insere_cod(&$$.code,aux);
        }
	| Exp '/' Exp{
		$$.place = newTemp();
		create_cod(&$$.code);
		insere_cod(&$$.code,$1.code);
		insere_cod(&$$.code,$3.code);
		sprintf(aux,"\t\tMOV AX,%s\n", getNome($1.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV DX,%s\n", getNome($3.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tDIV AX, DX\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV %s,AX\n", getNome($$.place));
		insere_cod(&$$.code,aux);
        }
	| ID {
	    create_cod(&$$.code);
            $$.place = $1.place;
	}
	| NUM {
	    create_cod(&$$.code);
            $$.place = $1.place;
	}
	| ChamadaFunc
	| '(' ExpLog ')' {
		create_cod(&$$.code);
		insere_cod(&$$.code,$2.code);
	};

ExpRel : ExpRel GE_OP ExpRel{
		$$.place = newTemp();
		create_cod(&$$.code);
		insere_cod(&$$.code,$1.code);
		insere_cod(&$$.code,$3.code);
		sprintf(aux,"\t\tMOV AX,1\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV %s, AX\n", getNome($$.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV AX,%s\n", getNome($1.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV DX,%s\n", getNome($3.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tCMP AX, DX\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tJGE %s\n", getLabel($$.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV AX, 0\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV %s, AX\n", getNome($$.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"%s:", getLabel($$.place));
		insere_cod(&$$.code,aux);
    }
	| ExpRel LE_OP ExpRel{
		$$.place = newTemp();
		create_cod(&$$.code);
		insere_cod(&$$.code,$1.code);
		insere_cod(&$$.code,$3.code);
		sprintf(aux,"\t\tMOV AX,1\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV %s, AX\n", getNome($$.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV AX,%s\n", getNome($1.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV DX,%s\n", getNome($3.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tCMP AX, DX\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tJLE %s\n", getLabel($$.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV AX, 0\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV %s, AX\n", getNome($$.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"%s:", getLabel($$.place));
		insere_cod(&$$.code,aux);
    }
	| ExpRel G_OP ExpRel{
		$$.place = newTemp();
		create_cod(&$$.code);
		insere_cod(&$$.code,$1.code);
		insere_cod(&$$.code,$3.code);
		sprintf(aux,"\t\tMOV AX,1\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV %s, AX\n", getNome($$.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV AX,%s\n", getNome($1.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV DX,%s\n", getNome($3.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tCMP AX, DX\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tJG %s\n", getLabel($$.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV AX, 0\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV %s, AX\n", getNome($$.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"%s:", getLabel($$.place));
		insere_cod(&$$.code,aux);
    }
	| ExpRel L_OP ExpRel{
		$$.place = newTemp();
		create_cod(&$$.code);
		insere_cod(&$$.code,$1.code);
		insere_cod(&$$.code,$3.code);
		sprintf(aux,"\t\tMOV AX,1\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV %s, AX\n", getNome($$.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV AX,%s\n", getNome($1.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV DX,%s\n", getNome($3.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tCMP AX, DX\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tJL %s\n", getLabel($$.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV AX, 0\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV %s, AX\n", getNome($$.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"%s:", getLabel($$.place));
		insere_cod(&$$.code,aux);
    }
	| ExpRel E_OP ExpRel{
		$$.place = newTemp();
		create_cod(&$$.code);
		insere_cod(&$$.code,$1.code);
		insere_cod(&$$.code,$3.code);
		sprintf(aux,"\t\tMOV AX,1\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV %s, AX\n", getNome($$.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV AX,%s\n", getNome($1.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV DX,%s\n", getNome($3.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tCMP AX, DX\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tJE %s\n", getLabel($$.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV AX, 0\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV %s, AX\n", getNome($$.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"%s:", getLabel($$.place));
		insere_cod(&$$.code,aux);
    }
	| '!' ExpRel {
		$$ = $2;
	}
	| ExpRel DIFF ExpRel{
		$$.place = newTemp();
		create_cod(&$$.code);
		insere_cod(&$$.code,$1.code);
		insere_cod(&$$.code,$3.code);
		sprintf(aux,"\t\tMOV AX,1\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV %s, AX\n", getNome($$.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV AX,%s\n", getNome($1.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV DX,%s\n", getNome($3.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tCMP AX, DX\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tJNE %s\n", getLabel($$.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV AX, 0\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV %s, AX\n", getNome($$.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"%s:", getLabel($$.place));
		insere_cod(&$$.code,aux);
    }
	| Exp{
        $$.place = $1.place;
        $$.code = $1.code;
	};

ExpLog : ExpLog AND ExpLog{
		$$.place = newTemp();
		create_cod(&$$.code);
		insere_cod(&$$.code,$1.code);
		insere_cod(&$$.code,$3.code);
		sprintf(aux,"\t\tMOV AX,1\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV %s, AX\n", getNome($$.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV AX,%s\n", getNome($1.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV DX,%s\n", getNome($3.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tAND AX, DX\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tJNZ %s\n", getLabel($$.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV AX, 0\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV %s, AX\n", getNome($$.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"%s:", getLabel($$.place));
		insere_cod(&$$.code,aux);
    }
	| ExpLog OR ExpLog{
		$$.place = newTemp();
		create_cod(&$$.code);
		insere_cod(&$$.code,$1.code);
		insere_cod(&$$.code,$3.code);
		sprintf(aux,"\t\tMOV AX,1\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV %s, AX\n", getNome($$.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV AX,%s\n", getNome($1.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV DX,%s\n", getNome($3.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tOR AX, DX\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tJNZ %s\n", getLabel($$.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV AX, 0\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV %s, AX\n", getNome($$.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"%s:", getLabel($$.place));
		insere_cod(&$$.code,aux);
    }
        | ExpRel{
            $$.place = $1.place;
            $$.code = $1.code;
        };

IfSt : IF '(' ExpLog ')' BlocoComando{
        $$.place = newTemp();
		create_cod(&$$.code);
		insere_cod(&$$.code,$3.code);
		sprintf(aux,"\t\tOI\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tMOV AX,%s\n", getNome($3.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tCMP AX,1\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tJNZ %s,1\n", getLabel($$.place));
		insere_cod(&$$.code,aux);
		insere_cod(&$$.code,$5.code);
		sprintf(aux,"%s:", getLabel($$.place));
		insere_cod(&$$.code,aux);
    }
	| IF '(' ExpLog ')'BlocoComando ELSE BlocoComando{
        $$.place = newTemp();
		create_cod(&$$.code);
		insere_cod(&$$.code,$3.code);
		sprintf(aux,"\t\tMOV AX,%s\n", getNome($3.place));
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tCMP AX,1\n");
		insere_cod(&$$.code,aux);
		sprintf(aux,"\t\tJNZ %s,1\n", getLabel($$.place));
		insere_cod(&$$.code,aux);
		insere_cod(&$$.code,$5.code);
		strcpy(aux1, getLabel(newTemp()));
		sprintf(aux,"\t\tJMP %s\n", aux1);
		insere_cod(&$$.code,aux);
		sprintf(aux,"%s:", getLabel($$.place));
		insere_cod(&$$.code,aux);
		insere_cod(&$$.code,$7.code);
		sprintf(aux,"%s:", aux1);
		insere_cod(&$$.code,aux);
    };

ForSt : FOR '('Atr';' ExpLog ';' Atr ')' BlocoComando {
    $$.place = newTemp();
    create_cod(&$$.code);
    insere_cod(&$$.code,$3.code);
    insere_cod(&$$.code,$5.code);
    sprintf(aux,"\t\tMOV AX,%s\n", getNome($5.place));
    insere_cod(&$$.code,aux);
    sprintf(aux,"\t\tCMP AX,1\n");
    insere_cod(&$$.code,aux);
    sprintf(aux,"\t\tJNZ %s,1\n", getLabel($$.place));
    insere_cod(&$$.code,aux);
    insere_cod(&$$.code,$9.code);
    insere_cod(&$$.code,$7.code);
    sprintf(aux,"\t\tJMP %s\n", getLabel($5.place));
    insere_cod(&$$.code,aux);
    sprintf(aux,"%s:", getLabel($$.place));
    insere_cod(&$$.code,aux);
};

WhileSt : WHILE '(' ExpLog ')' BlocoComando{
    $$.place = newTemp();
    create_cod(&$$.code);
    insere_cod(&$$.code,$3.code);
    sprintf(aux,"\t\tMOV AX,%s\n", getNome($3.place));
    insere_cod(&$$.code,aux);
    sprintf(aux,"\t\tCMP AX,1\n");
    insere_cod(&$$.code,aux);
    sprintf(aux,"\t\tJNZ %s,1\n", getLabel($$.place));
    insere_cod(&$$.code,aux);
    insere_cod(&$$.code,$5.code);
    sprintf(aux,"\t\tJMP %s\n", getLabel($3.place));
    insere_cod(&$$.code,aux);
    sprintf(aux,"%s:", getLabel($$.place));
    insere_cod(&$$.code,aux);
};

DoSt : DO BlocoComando WHILE '(' ExpLog ')'{
    $$.place = newTemp();
    create_cod(&$$.code);
    insere_cod(&$$.code,$5.code);
    insere_cod(&$$.code,$2.code);
    sprintf(aux,"\t\tMOV AX,%s\n", getNome($5.place));
    insere_cod(&$$.code,aux);
    sprintf(aux,"\t\tCMP AX,1\n");
    insere_cod(&$$.code,aux);
    sprintf(aux,"\t\tJNZ %s,1\n", getLabel($$.place));
    insere_cod(&$$.code,aux);
    sprintf(aux,"\t\tJMP %s\n", getLabel($5.place));
    insere_cod(&$$.code,aux);
    sprintf(aux,"%s:", getLabel($$.place));
    insere_cod(&$$.code,aux);
};

BlocoComando : '{' ListaComandos '}'{
    $$.place = $2.place;
    create_cod(&$$.code);
    insere_cod(&$$.code,$2.code);
}
		| Atr{
    $$.place = $1.place;
    create_cod(&$$.code);
    insere_cod(&$$.code,$1.code);
}
		| ChamadaFunc{
    $$.place = $1.place;
    create_cod(&$$.code);
    insere_cod(&$$.code,$1.code);
}
		| IfSt{
    $$.place = $1.place;
    create_cod(&$$.code);
    insere_cod(&$$.code,$1.code);
}
		| ForSt{
    $$.place = $1.place;
    create_cod(&$$.code);
    insere_cod(&$$.code,$1.code);
}
		| WhileSt{
    $$.place = $1.place;
    create_cod(&$$.code);
    insere_cod(&$$.code,$1.code);
}
		| DoSt{
    $$.place = $1.place;
    create_cod(&$$.code);
    insere_cod(&$$.code,$1.code);
}
		| DeclaracaoVar{
    $$.place = newTemp();
    create_cod(&$$.code);
};

ListaComandos : Atr ';' ListaComandos{
    $$.place = newTemp();
    create_cod(&$$.code);
    insere_cod(&$$.code,$1.code);
    insere_cod(&$$.code,$3.code);
}
		| DeclaracaoVar ListaComandos{
    $$.place = newTemp();
    create_cod(&$$.code);
    insere_cod(&$$.code,$2.code);
}
		| ChamadaFunc ';' ListaComandos{
    $$.place = newTemp();
    create_cod(&$$.code);
    insere_cod(&$$.code,$1.code);
    insere_cod(&$$.code,$3.code);
}
		| IfSt ListaComandos{
    $$.place = newTemp();
    create_cod(&$$.code);
    insere_cod(&$$.code,$1.code);
    insere_cod(&$$.code,$2.code);
}
		| ForSt ListaComandos{
    $$.place = newTemp();
    create_cod(&$$.code);
    insere_cod(&$$.code,$1.code);
    insere_cod(&$$.code,$2.code);
}
		| WhileSt ListaComandos{
    $$.place = newTemp();
    create_cod(&$$.code);
    insere_cod(&$$.code,$1.code);
    insere_cod(&$$.code,$2.code);
}
		| DoSt ';' ListaComandos{
    $$.place = newTemp();
    create_cod(&$$.code);
    insere_cod(&$$.code,$1.code);
    insere_cod(&$$.code,$3.code);
}
		|{
    $$.place = newTemp();
    create_cod(&$$.code);
};


%%
main(int argc, char **argv){
	yyin = fopen(argv[1], "r");
	yyparse();
}

yyerror(char *s) {
	printf("erro sintatico na linha %d e coluna %d", linha, coluna);
}

