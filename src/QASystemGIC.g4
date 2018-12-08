//Area de conhecimento: FAQ UMinho

//TODOs
//->(pagar|pagam|pago) não na BdC mas na parte da gramática

grammar QASystemGIC;

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

fragment PRONOMES: ( 'eu' | 'me' | 'mim' | 'tu' | 'te' | 'ti' | 'ele' | 'ela' |
                     'se' | 'lhe' | 'nós' | 'nos' | 'vos' | 'vós' | 'lhes' | 
                     'eles' | 'elas' )
                 ;
                     
fragment PROPOSICOES: ( 'ante' | 'após' | 'até' | 'com' | 'contra' |
                      | 'desde' | 'em' | 'entre' | 'para' | 'perante' | 'por' 
                      | 'sem' | 'sob' | 'sobre' | 'trás' ) 
                    ;

fragment CONJUNCOES : ( 'e' | 'mas' | 'ainda' | 'também' | 'nem' | 'contudo' | 
                        'entretanto' | 'obstante' | 'entanto' | 'porém' | 'todavia' |
                        'já' | 'ou' | 'ora' | 'quer' | 'assim' | 'então' | 'logo' | 
                        'pois' | 'conseguinte' | 'portanto' | 'porquanto' | 
                        'porque' | 'que' )
                    ;

fragment DETERMINANTES: ( 'meu' | 'teu' | 'seu' | 'minha' | 'tua' | 'sua' | 'meus' | 
                          'teus' | 'seus' | 'minhas' | 'tuas' | 'suas' | 'nosso' | 
                          'vosso' | 'nossa' | 'vossa' | 'nossos' | 'vossos' | 
                          'nossas' | 'vossas' | 'este' | 'esse' | 'aquele' | 'esta' | 
                          'essa' | 'aquela' | 'estes' | 'esses' | 'aqueles' | 'estas' | 
                          'essas' | 'aquelas' | 'isto' | 'isso' | 'aquilo' | 'todo' | 
                          'algum' | 'nenhum' | 'outro' | 'muito' | 'pouco' | 'tanto' | 
                          'qualquer' | 'toda' | 'alguma' | 'nenhuma' | 'outra' | 'muita' | 
                          'pouca' | 'tanta' | 'todos' | 'alguns' | 'nenhuns' | 'outros' | 
                          'muitos' | 'poucos' | 'tantos' | 'quaisquer' | 'todas' | 
                          'algumas' | 'nenhumas' | 'outras' | 'muitas' | 'poucas' | 'tantas' | 
                          'tudo' | 'nada' | 'cada' | 'ninguém' | 'alguém' )
                      ;

fragment ARTIGOS: ( 'o' | 'os' | 'um' | 'uns' | 'a' | 'as' | 'uma' | 'umas' |
                    'ao' | 'à' | 'aos' | 'às' | 'em' | 'num' | 'numa' | 'nuns' | 
                    'numas' | 'de' | 'do' | 'da' | 'dos' | 'das' | 'em' | 
                    'no' | 'na' | 'nos' | 'nas' | 'dum' | 'duma' | 'duns' | 'dumas' |
                    'pelo' | 'pela' | 'pelos' | 'pelas' )
                ;

fragment NOVALUE : ( 'não' | PRONOMES | PROPOSICOES | CONJUNCOES | DETERMINANTES | ARTIGOS );

Separador: ('\r'? '\n' | ' ' | '\t' | NOVALUE)+  -> skip; 
