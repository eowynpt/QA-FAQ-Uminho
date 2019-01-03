grammar QASystemGA;

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
                      
           public String toString(){
                 StringBuffer sb = new StringBuffer();
                 sb.append("t = ");
                 sb.append("("+this.tipo+",");
                 sb.append(Arrays.toString(this.acoes.toArray())+",");
                 sb.append(Arrays.toString(this.keywords.toArray())+")");
                 return sb.toString();
           }
         }
         
         boolean containsElemList(ArrayList<String> l1, ArrayList<String> l2, int n){
            boolean ret=false;
            int size1 = l1.size();
            int size2 = l2.size();
            int matches=0;
            
            for(int i=0; i<size1 && !ret; i++)
                for(int j=0; j<size2 && !ret; j++) {
                    ret=l2.get(j).toLowerCase().equals(l1.get(i).toLowerCase());
                    matches++;
                }
            if(matches>n) n = matches;
            if (matches<n) return false;
            return ret;
         }

         boolean containsAllKeywords(ArrayList<String> l1, ArrayList<String> l2){
            boolean ret=false;
            int size1 = l1.size();
            int size2 = l2.size();
            int nkeys = l2.size();
            
            if(size2==0) return false;
                      
            for(int i=0; i<size1 && nkeys>0; i++)
                for(int j=0; j<size2 && nkeys>0; j++)
                    if (l2.get(j).toLowerCase().equals(l1.get(i).toLowerCase()) == true) {
                        nkeys--; 
                    }
            if(nkeys==0) return true;
            else return false;           
         }

         /* cria lista com as keywords presentes na BC*/
         ArrayList<String> addkeywords (ArrayList<String> l, ArrayList<Triplo> t) {
            ArrayList<String> k = new ArrayList<String>();
            
            for (Triplo triple : t)
                for (String s : triple.keywords)
                    if(!l.contains(s)) l.add(s);
            
            return l;
         }
         
         /* Obtém a(s) resposta(s) para cada questão */
         void getAnswer(HashMap<String, ArrayList<Triplo>> bc, StringBuffer question,ArrayList<String> tipos, ArrayList<String> acoes, ArrayList<String> keywords, ArrayList<String> palavras){
                  int tipoSize = tipos.size();
                  ArrayList<String> keywordsBC = new ArrayList<String>();
                  ArrayList<String> keywordsPalavras = new ArrayList<String>();
                  ArrayList<String> resp;
                  ArrayList<String> respteste;
                  ArrayList<Triplo> aux = new ArrayList<Triplo>();

                  
                  for(ArrayList<Triplo> l : bc.values())
                        keywordsBC = addkeywords(keywordsBC,l);

                  if(tipoSize>0){
                        for(int i=0;i<tipoSize;i++)
                            aux.addAll(bc.get(tipos.get(i)));
                  }else{
                        for(ArrayList<Triplo> l : bc.values())
                            aux.addAll(l);                        
                  }
                  

                   for (String s : palavras) {
                        if(keywordsBC.contains(s.toLowerCase()))
                            keywordsPalavras.add(s);
                   }
                   if(keywordsPalavras.isEmpty())
                        for(String s : keywords)
                            keywordsPalavras.add(s);
                            
                   int x=0;
                   respteste = aux.stream()
                                       .filter(a -> containsElemList(a.acoes,acoes,x) || containsElemList(a.acoes,palavras,x))
                                       .filter(a -> containsAllKeywords(a.keywords,keywords) && containsAllKeywords(a.keywords,keywordsPalavras))
                                       .filter(a -> containsAllKeywords(a.keywords,keywordsPalavras))
                                       .map(a -> a.resposta)
                                       .distinct()
                                       .collect(Collectors.toCollection(ArrayList::new));

                   if(!respteste.isEmpty()) {

                   System.out.println("\n"+question.toString());
                   int w=0;
                   for(String r : respteste)
                        System.out.println("R" + w++ + ":" + r);

                   } else {

                   int n=0;
                   resp = aux.stream()
                                       .filter(a -> containsElemList(a.acoes,acoes,n) || containsElemList(a.acoes,palavras,n))
                                       .filter(a -> containsElemList(a.keywords,keywords,n) || containsElemList(a.keywords,palavras,n))
                                       .map(a -> a.resposta)
                                       .distinct()
                                       .collect(Collectors.toCollection(ArrayList::new));
            
                   System.out.println("\n"+question.toString());
                   int w=0;
                   for(String r : resp)
                        System.out.println("R" + w++ + ":" + r);

                   if (resp.isEmpty()) System.out.println("Não foi encontrada resposta à sua pergunta.");
                 }
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
    StringBuffer question = new StringBuffer();
}
               : (PALAVRA {palavras.add($PALAVRA.text); question.append($PALAVRA.text).append(" ");} 
                 | tipo {tipos.add($tipo.val); question.append($tipo.val).append(" ");} 
                 | acao {acoes.add($acao.val); question.append($acao.val).append(" ");} 
                 | keyword {keywords.add($keyword.val); question.append($keyword.val).append(" ");} )+ 
                 (PONTOTERMINAL {question.append($PONTOTERMINAL.text);} )+
                {getAnswer($bc,question,tipos,acoes,keywords,palavras);}
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
         : ( t='Porquê' | t='O que' | t='Quando' | t='Onde' | t='Como' | t='Qual' | t='Quem') {$tipo.val = $t.text;}
    ;

acao returns [ArrayList<String> list, String val]
@init{$acao.list = new ArrayList<String>();}
         : 'aceder' {$acao.list.add("aceder"); $acao.list.add("acedo"); $acao.val="aceder";} 
         | 'imprimir' {$acao.list.add("imprimir"); $acao.list.add("imprimo"); $acao.val="imprimir";} 
         | 'ser' {$acao.list.add("é"); $acao.list.add("foi"); $acao.list.add("são");} 
         | 'inscrever' {$acao.list.add("inscrever"); $acao.list.add("inscrevo"); $acao.val="inscrever";} 
         | 'pagar' {$acao.list.add("pagar"); $acao.list.add("pago"); $acao.list.add("pagam"); $acao.val="pagar";} 
         | 'tem' {$acao.list.add("tem"); $acao.list.add("teve"); $acao.list.add("tinha");}
         | 'haver' {$acao.list.add("há"); $acao.list.add("havia"); $acao.list.add("houve");}
         | 'funcionar' {$acao.list.add("funcionar"); $acao.list.add("funciona"); $acao.list.add("funcionará");}
         ;

keywords returns [ArrayList<String> list]
@init{$keywords.list = new ArrayList<String>();}
                  : '[' k1=keyword {$keywords.list.add($k1.val);} ( ',' k2=keyword {$keywords.list.add($k2.val);})* ']' 
                  ;

keyword returns [String val]: ( t='propinas' | t='época' | t='especial' | t='email' | t='diretor' | t='curso' |
                                t='portal' | t='académico' | t='Universidade' | t='Minho' |
                                t='exame' | t='recurso' | t='calendário' | t='escolar' | t='reitor' | t='horário' | 
                                t='regulamento' | t='código' | t='ético' | t='conduta' | t='direitos' | t='deveres' |  
                                t='cadeira' | t='unidade' | t='curricular' | t='ECT' | t='ECTS' | t='Erasmus'
                              ) {$keyword.val=$t.text;}
       ;

/* Definição do Analisador Léxico */         
TEXTO:    (('\'') ~('\'')* ('\''));

fragment LETRA : [a-zA-ZáéíóúÁÉÍÓÚÃãÕõâêôÂÊÔÀÈÌÒÙàèìòùÇç] ;

fragment DIGITO: [0-9];

fragment SIMBOLO : [-%$€@&()\[\]:{}=><+*;,ºª~^/\'"];

PONTOTERMINAL: [?.!];

PALAVRA: (LETRA | DIGITO | SIMBOLO)+;

Separador: ( '\r'? '\n' | ' ' | '\t' )+  -> skip; 