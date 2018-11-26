//Area de conhecimento: FAQ UMinho

grammar QASystem;

qas: 'BC:' bcQAS 'Q:' questoes
      ;

bcQAS: triplete+
           ;

questoes: questao+
                 ;

questao: PALAVRA+ SIMBOLOTERMINAL
               ;

triplete: '(' intencao ';' resposta ';' confianca')'
                  ;

intencao: tipo acao keywords
                 ;

resposta: TEXTO
                 ;

confianca: NUMERO
                    ;

tipo: 'Porquê' | 'O quê' | 'Quando' | 'Onde' | 'Como'
         ;

acao: 'aceder' | 'imprimir' | 'pagar' //....
         ;

keywords: keyword (',' keyword)*
                 ;

keyword: 'portal acadêmico' | 'Universidade do Minho' //....
               ;

/* Definição do Analisador Léxico */         
TEXTO:    '"' ~["]* '"';

fragment LETRA : [a-zA-ZáéíóúÁÉÍÓÚÃãÕõâêôÂÊÔÀÈÌÒÙàèìòùÇç] ;

fragment SIMBOLO : [?.!-%$€@&()\[\]{}=><+*;,ºª~^/\'"];

SIMBOLOTERMINAL: [?.!];

fragment DIGITO : [0-9];

PALAVRA: (LETRA| DIGITO | SIMBOLO)+;

NUMERO: DIGITO+ ;

Separador: ('\r'? '\n' | ' ' | '\t')+  -> skip; 