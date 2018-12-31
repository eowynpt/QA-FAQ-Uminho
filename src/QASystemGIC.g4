grammar QASystemGIC;

qas: 'BC:' bcQAS 'QUESTOES:' questoes
   ;

questoes: questao+
        ;

questao: (PALAVRA | tipo | acao | keyword )+ PONTOTERMINAL
       ;

bcQAS: triplo+
     ;

triplo: '(' intencao ';' resposta')'  
      ;

intencao: tipo ',' acao ',' keywords
        ;

resposta: TEXTO
        ;

tipo: 'Porquê' | 'O quê' | 'Quando' | 'Onde' | 'Como'
    ;

acao: 'aceder' | 'imprimir' | 'inscrever' | 'pagar' //....
    ;

keywords: '[' keyword ( ',' keyword)* ']'
        ;

keyword: 'propinas' | 'época' | 'especial' | 'portal' | 'académico' | 'Universidade' | 'Minho' //....
       ;

/* Definição do Analisador Léxico */         
TEXTO:    (('\'') ~('\'')* ('\''));

fragment LETRA : [a-zA-ZáéíóúÁÉÍÓÚÃãÕõâêôÂÊÔÀÈÌÒÙàèìòùÇç] ;

fragment DIGITO: [0-9];

fragment SIMBOLO : [-%$€@&()\[\]{}=><+*;,ºª~^/\'"];

PONTOTERMINAL: [?.!];

PALAVRA: (LETRA | DIGITO | SIMBOLO)+;

Separador: ( '\r'? '\n' | ' ' | '\t' )+  -> skip; 
