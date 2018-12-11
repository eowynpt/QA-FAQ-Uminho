grammar QASystemGA;

/*
    - nas questoes fazer uppercase dos tipos
*/

@header{
        import java.util.*;
}

@members{
         class Triplo{
                      String tipo;
                      ArrayList<String> acoes;
                      ArrayList<String> keywords;
                      String resposta;
         }
}

qas: 'BC:' bcQAS 'QUESTOES:' questoes [$bcQAS.bc]
   ;

questoes [HashMap<String, Triplo> bc]: (questao [$questoes.bc])+
        ;

questao [HashMap<String, Triplo> bc]
               : (PALAVRA | tipo | acao | keyword )+ PONTOTERMINAL
                {
                  //TODO: Responder a cada questão
                }
       ;

bcQAS returns [HashMap<String, Triplo> bc]
@init{$bcQAS.bc = new HashMap<String,Triplo>();}
           : t1=triplo [$bcQAS.bc] (t2=triplo [$t1.bcOut] {$t1.bcOut = $t2.bcOut;})*
           ;

triplo [HashMap<String, Triplo> bcIn] returns [HashMap<String, Triplo> bcOut]
             : '(' intencao ';' resposta')' 
             {
                $intencao.t.resposta = $resposta.val;
                $bcIn.put($intencao.t.tipo,$intencao.t);
                $bcOut = $bcIn;
             }
      ;

intencao returns [Triplo t]
                 : tipo ',' acao ',' keywords
                 {
                    $intencao.t = new Triplo();
                    $intencao.t.tipo = $tipo.val;
                    $intencao.t.acoes = $acao.list;
                    $intencao.t.keywords = $keywords.list;
                 }
        ;

resposta returns [String val]
                 : TEXTO {$resposta.val = $TEXTO.text;}
        ;

tipo returns [String val]
         : ( t='Porquê' | t='O quê' | t='Quando' | t='Onde' | t='Como') {$tipo.val = $t.text;}
    ;

acao returns [ArrayList<String> list]
@init{$acao.list = new ArrayList<String>();}
         : 'aceder' {$acao.list.add("aceder"); $acao.list.add("acedo");} 
         | 'imprimir' {$acao.list.add("imprimir"); $acao.list.add("imprimo");} 
         | 'inscrever' {$acao.list.add("inscrever"); $acao.list.add("inscrevo");} 
         | 'pagar' {$acao.list.add("pagar"); $acao.list.add("pago");} 
         ;

keywords returns [ArrayList<String> list]
@init{$keywords.list = new ArrayList<String>();}
                  : '[' k1=keyword {$keywords.list.add($k1.val);} ( ',' k2=keyword {$keywords.list.add($k2.val);})* ']' 
                  ;

keyword returns [String val]: ( t='propinas' | t='época' | t='especial' | t='portal' | t='académico' | t='Universidade' | t='Minho') {$keyword.val=$t.text;}
       ;

/* Definição do Analisador Léxico */         
TEXTO:    (('\'') ~('\'')* ('\''));

fragment LETRA : [a-zA-ZáéíóúÁÉÍÓÚÃãÕõâêôÂÊÔÀÈÌÒÙàèìòùÇç] ;

fragment DIGITO: [0-9];

fragment SIMBOLO : [-%$€@&()\[\]{}=><+*;,ºª~^/\'"];

PONTOTERMINAL: [?.!];

PALAVRA: (LETRA | DIGITO | SIMBOLO)+;

fragment PRONOMES: ( ' eu ' | ' me ' | ' mim ' | ' tu ' | ' te ' | ' ti ' | ' ele ' | ' ela '
                                        | ' se ' | ' lhe ' | ' nós ' | ' nos ' | ' vos ' | ' vós ' | ' lhes '
                                        | ' eles ' | ' elas ' )
                                    ;
                     
fragment PROPOSICOES: ( ' ante ' | ' após ' | ' até ' | ' com ' | ' contra '
                                              | ' desde ' | ' em ' | ' entre ' | ' para ' | ' perante ' | ' por ' 
                                              | ' sem ' | ' sob ' | ' sobre ' | ' trás ' ) 
                                          ;

fragment CONJUNCOES : ( ' e ' | ' mas ' | ' ainda ' | ' também ' | ' nem ' | ' contudo '
                                             | ' entretanto ' | ' obstante ' | ' entanto ' | ' porém ' | ' todavia '
                                             | ' já ' | ' ou ' | ' ora ' | ' quer ' | ' assim ' | ' então ' | ' logo '
                                             | ' pois ' | ' conseguinte ' | ' portanto ' | ' porquanto '
                                             | ' porque ' | ' que ' )
                                          ;

fragment DETERMINANTES: ( ' meu ' | ' teu ' | ' seu ' | ' minha ' | ' tua ' | ' sua ' | ' meus '
                                                   | ' teus' | ' seus ' | ' minhas ' | ' tuas ' | ' suas ' | ' nosso '
                                                   | ' vosso ' | ' nossa ' | ' vossa ' | ' nossos ' | ' vossos '
                                                   | ' nossas ' | ' vossas ' | ' este ' | ' esse ' | ' aquele ' | ' esta '
                                                   | ' essa ' | ' aquela ' | ' estes ' | ' esses ' | ' aqueles ' | ' estas '
                                                   | ' essas ' | ' aquelas ' | ' isto ' | ' isso ' | ' aquilo ' | ' todo '
                                                   | ' algum ' | ' nenhum ' | ' outro ' | ' muito ' | ' pouco ' | ' tanto '
                                                   | ' qualquer ' | ' toda ' | ' alguma ' | ' nenhuma ' | ' outra ' | ' muita '
                                                   | ' pouca ' | ' tanta ' | ' todos ' | ' alguns ' | ' nenhuns ' | ' outros '
                                                   | ' muitos ' | ' poucos ' | ' tantos ' | ' quaisquer ' | ' todas '
                                                   | ' algumas ' | ' nenhumas ' | ' outras ' | ' muitas ' | ' poucas ' | ' tantas '
                                                   | ' tudo ' | ' nada ' | ' cada ' | ' ninguém ' | ' alguém ' )
                                                ;

fragment ARTIGOS: ( ' o ' | ' os ' | ' um ' | ' uns ' | ' a ' | ' as ' | ' uma ' | ' umas '
                                     | ' ao ' | ' à ' | ' aos ' | ' às ' | ' em ' | ' num ' | ' numa ' | ' nuns '
                                     | ' numas ' | ' de ' | ' do ' | ' da ' | ' dos ' | ' das ' | ' em '
                                     | ' no ' | ' na ' | ' nos ' | ' nas ' | ' dum ' | ' duma ' | ' duns ' | ' dumas '
                                     | ' pelo ' | ' pela ' | ' pelos ' | ' pelas ' )
                                  ;

fragment NOVALUE : ( ' não ' | PRONOMES | PROPOSICOES | CONJUNCOES | DETERMINANTES | ARTIGOS );

Separador: ( NOVALUE | '\r'? '\n' | ' ' | '\t' )+  -> skip; 