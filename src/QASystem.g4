//Area de conhecimento: FAQ UMinho

//TODOs
//->(pagar|pagam|pago) não na BdC mas na parte da gramática
//-> dar skip aos pronomes


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

questao: (PALAVRA | tipo | acao | keyword )+ SIMBOLOTERMINAL
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

SIMBOLOTERMINAL: [?.!];

PALAVRA: (LETRA | DIGITO | SIMBOLO)+;

fragment pronomes: 
                 ;
                     
fragment proposicoes: ('a' | 'ante' | 'após' | 'até' | 'com' | 'contra' | 'de' 
                      | 'desde' | 'em' | 'entre' | 'para' | 'perante' | 'por' 
                      | 'sem' | 'sob' | 'sobre' | 'trás') 
                    ;

fragment conjuncoes :
                    ;

fragment NOVALUE : ('de' | 'do' | 'as' | 'se' | 'nos' | 'para' | 'a' );

Separador: ('\r'? '\n' | ' ' | '\t' | NOVALUE)+  -> skip; 
