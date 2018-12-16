grammar QASystemGA;

/*
    - nas questoes fazer uppercase dos tipos
*/

@header{
        import java.util.*;
        import java.util.stream.Collectors;
}

@members{
         class Triplo{
                      String tipo;
                      ArrayList<String> acoes;
                      ArrayList<String> keywords;
                      String resposta;
         }
         
         boolean containsElemList(ArrayList<String> l1, ArrayList<String> l2){
            boolean ret=false;
            int size = l1.size();
            
            for(int i=0; i<size && !ret; i++)
                ret=l2.contains(l1.get(i));
            
            return ret;
         }
}

qas: 'BC:' bcQAS 'QUESTOES:' questoes [$bcQAS.bc]
   ;

questoes [HashMap<String, ArrayList<Triplo>> bc]: (questao [$questoes.bc])+
        ;

questao [HashMap<String, ArrayList<Triplo>> bc]
@init{
    ArrayList<String> tipos = new ArrayList<String>();
    ArrayList<String> acoes = new ArrayList<String>();
    ArrayList<String> keywords = new ArrayList<String>();
    ArrayList<String> palavras = new ArrayList<String>();
    String question = "";
}
               : (PALAVRA {palavras.add($PALAVRA.text); question+=$PALAVRA.text + " ";} | tipo {tipos.add($tipo.val); question+=$tipo.val + " ";} | acao {acoes.add($acao.val); question+=$acao.val + " ";} | keyword {keywords.add($keyword.val); question+=$keyword.val + " ";} )+ PONTOTERMINAL
                {
                  question+= $PONTOTERMINAL.text;
                  int tipoSize = tipos.size();
                  if(tipoSize>0){
                        ArrayList<Triplo> aux = new ArrayList<Triplo>();
                        for(int i=0;i<tipoSize;i++)
                            aux.addAll($bc.get(tipos.get(i)));

                        ArrayList<String> resp = aux.stream()
                                                                                  .filter(a -> containsElemList(a.acoes,acoes) || containsElemList(a.acoes,palavras))
                                                                                  .filter(a -> containsElemList(a.keywords,keywords))
                                                                                  .map(a -> a.resposta.toString())
                                                                                  .collect(Collectors.toCollection(ArrayList::new));
                         
                        System.out.println(question);
                        int w=0;
                        for(String r : resp)
                            System.out.println("R" + w++ + ":" + r);
                  }else{
                        ArrayList<Triplo> aux = new ArrayList<Triplo>();
                        for(ArrayList<Triplo> l : $bc.values())
                            aux.addAll(l);

                        ArrayList<String> resp = aux.stream()
                                                                                  .filter(a -> containsElemList(a.acoes,acoes) || containsElemList(a.acoes,palavras))
                                                                                  .filter(a -> containsElemList(a.keywords,keywords))
                                                                                  .map(a -> a.resposta)
                                                                                  .collect(Collectors.toCollection(ArrayList::new));
                        
                        System.out.println(question);
                        int w=0;
                        for(String r : resp)
                            System.out.println("R" + w++ + ":" + r);
                  }
                }
       ;

bcQAS returns [HashMap<String, ArrayList<Triplo>> bc]
@init{$bcQAS.bc = new HashMap<String,ArrayList<Triplo>>();}
           : t1=triplo [$bcQAS.bc] (t2=triplo [$t1.bcOut] {$t1.bcOut = $t2.bcOut;})*
           ;

triplo [HashMap<String, ArrayList<Triplo>> bcIn] returns [HashMap<String, ArrayList<Triplo>> bcOut]
             : '(' intencao ';' resposta')' 
             {
                $intencao.t.resposta = $resposta.val;
                ArrayList<Triplo> aux = $bcIn.get($intencao.t.tipo);
                if(aux==null) aux = new ArrayList<Triplo>();
                aux.add($intencao.t);
                $bcIn.put($intencao.t.tipo,aux);
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

acao returns [ArrayList<String> list, String val]
@init{$acao.list = new ArrayList<String>();}
         : 'aceder' {$acao.list.add("aceder"); $acao.list.add("acedo"); $acao.val="aceder";} 
         | 'imprimir' {$acao.list.add("imprimir"); $acao.list.add("imprimo"); $acao.val="imprimir";} 
         | 'inscrever' {$acao.list.add("inscrever"); $acao.list.add("inscrevo"); $acao.val="inscrever";} 
         | 'pagar' {$acao.list.add("pagar"); $acao.list.add("pago"); $acao.list.add("pagam"); $acao.val="pagar";} 
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
/*
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
*/
Separador: ( '\r'? '\n' | ' ' | '\t' )+  -> skip; 