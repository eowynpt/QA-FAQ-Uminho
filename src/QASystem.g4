//Area de conhecimento: FAQ UMinho

//TODOs
//->(pagar|pagam|pago) não na BdC mas na parte da gramática
//-> dar skip aos pronomes
// keywords+
//decidir palavras+ vs texto


grammar QASystem;

@header{
        import java.util.*;
}

@members{
         
         }

qas: 'BC:' bcQAS 'QUESTOES:' questoes
   ;

questoes: questao+
        ;

questao: TEXTO
       ;

bcQAS: triplo+
     ;

triplo: '(' intencao ';' resposta ';' confianca')'  
      ;

intencao: tipo acao keyword
        ;

resposta: TEXTO
        ;

confianca: PERCENT
         ;

tipo: 'Porquê' | 'O quê' | 'Quando' | 'Onde' | 'Como'
    ;

acao: 'aceder' | 'imprimir' | 'inscrever' | 'pagar' //....
    ;


keyword: 'propinas' | 'época especial' | 'portal académico' | 'Universidade do Minho' //....
       ;

/* Definição do Analisador Léxico */         
TEXTO:    (('\''|'\"') ~('\''|'\"')* ('\''|'\"'));

fragment LETRA : [a-zA-ZáéíóúÁÉÍÓÚÃãÕõâêôÂÊÔÀÈÌÒÙàèìòùÇç] ;

fragment SIMBOLO : [?.!-%$€@&()\[\]{}=><+*;,ºª~^/\'"];

SIMBOLOTERMINAL: [?.!];

/*FRASE: (LETRA| DIGITO | SIMBOLO)+;*/

NUMERO: ('0'..'9')+ ;

fragment DIGITO: [0-9];

PERCENT: ('100' | (DIGITO? DIGITO('.'DIGITO+)?))' '?'%';

Separador: ('\r'? '\n' | ' ' | '\t')+  -> skip; 