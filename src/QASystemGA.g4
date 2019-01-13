grammar QASystemGA;

@header{
    import java.util.*;
    import java.util.stream.Collectors;
}

@members{
    class Par{
        String tipo;
        ArrayList<String> acoes;
        ArrayList<String> keywords;
        String resposta;
                      
        public String toString(){
             StringBuffer sb = new StringBuffer();
             sb.append("p = ");
             sb.append("("+this.tipo+",");
             sb.append(Arrays.toString(this.acoes.toArray())+",");
             sb.append(Arrays.toString(this.keywords.toArray())+")");
             return sb.toString();
        }
    }
         
    boolean containsElemList(ArrayList<String> l1, ArrayList<String> l2){
        boolean ret=false;
        int size1 = l1.size();
        int size2 = l2.size();
        
        for(int i=0; i<size1 && !ret; i++)
            for(int j=0; j<size2 && !ret; j++)
                ret=l2.get(j).toLowerCase().equals(l1.get(i).toLowerCase());

        return ret;
    }

    boolean containsAllKeywords(ArrayList<String> l1, ArrayList<String> l2){
        boolean ret=false;
        int size1 = l1.size();
        int size2 = l2.size();
        int nkeys = size2;
        
        for(int i=0; i<size1; i++)
            for(int j=0; j<size2; j++)
                if (l2.get(j).toLowerCase().equals(l1.get(i).toLowerCase()) == true)
                    nkeys--; 
         
        if(nkeys==0) return true;
        else return false;           
    }

    /* cria lista com as keywords presentes na BC*/
    ArrayList<String> addkeywords (ArrayList<String> l, ArrayList<Par> p) {
        ArrayList<String> k = new ArrayList<String>();
        
        for (Par pair : p)
            for (String s : pair.keywords)
                if(!l.contains(s)) l.add(s);
        
        return l;
    }
     
    /* Obtém a(s) resposta(s) para cada questão */
    void getAnswer(HashMap<String, ArrayList<Par>> bc, StringBuffer question,ArrayList<String> tipos, ArrayList<String> acoes, ArrayList<String> keywords, ArrayList<String> palavras){
        int tipoSize = tipos.size();
        ArrayList<String> keywordsBC = new ArrayList<String>();
        ArrayList<String> keywordsPalavras = new ArrayList<String>();
        ArrayList<String> resp;
        ArrayList<Par> aux = new ArrayList<Par>();

        for(ArrayList<Par> l : bc.values())
            keywordsBC = addkeywords(keywordsBC,l);

        if(tipoSize>0){
            for(int i=0;i<tipoSize;i++)
                aux.addAll(bc.get(tipos.get(i)));
        }else{
            for(ArrayList<Par> l : bc.values())
                aux.addAll(l);                        
        }  

        for (String s : palavras) {
            if(keywordsBC.contains(s.toLowerCase()))
                keywordsPalavras.add(s);
        }
                    
        resp = aux.stream()
                       .filter(a -> containsElemList(a.acoes,acoes) || containsElemList(a.acoes,palavras))
                       .filter(a -> containsAllKeywords(a.keywords,keywords) && containsAllKeywords(a.keywords,keywordsPalavras))
                       .map(a -> a.resposta)
                       .distinct()
                       .collect(Collectors.toCollection(ArrayList::new));

        if(resp.isEmpty()){

            resp = aux.stream()
                      .filter(a -> containsElemList(a.acoes,acoes) || containsElemList(a.acoes,palavras))
                      .filter(a -> containsElemList(a.keywords,keywords) || containsElemList(a.keywords,palavras))
                      .map(a -> a.resposta)
                      .distinct()
                      .collect(Collectors.toCollection(ArrayList::new));
        }
        
        if (resp.isEmpty()) System.out.println("Não foi encontrada resposta à sua pergunta.");
        else{
            System.out.println("\n"+question.toString());
            int w=0;
            for(String r : resp)
                System.out.println("R" + w++ + ":" + r);
        }
    }
}

qas: 'BC:' bcQAS 'QUESTOES:' questoes [$bcQAS.bc]
   ;

questoes [HashMap<String, ArrayList<Par>> bc]: (questao [$questoes.bc])+
                                                ;

questao [HashMap<String, ArrayList<Par>> bc]
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

bcQAS returns [HashMap<String, ArrayList<Par>> bc]
@init{$bcQAS.bc = new HashMap<String,ArrayList<Par>>();}
    : t1=par [$bcQAS.bc] (t2=par [$t1.bcOut] {$t1.bcOut = $t2.bcOut;})*
    ;

par [HashMap<String, ArrayList<Par>> bcIn] returns [HashMap<String, ArrayList<Par>> bcOut]
    : '(' intencao ';' resposta')' 
    {
        $intencao.p.resposta = $resposta.val;
        ArrayList<Par> aux = $bcIn.get($intencao.p.tipo);
        if(aux==null) aux = new ArrayList<Par>();
        aux.add($intencao.p);
        $bcIn.put($intencao.p.tipo,aux);
        $bcOut = $bcIn;
    }
    ;

intencao returns [Par p]
        : tipo ',' acao ',' keywords
        {
            $intencao.p = new Par();
            $intencao.p.tipo = $tipo.val;
            $intencao.p.acoes = $acao.list;
            $intencao.p.keywords = $keywords.list;
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

keyword returns [String val]
       : ( t='propinas' | t='época' | t='especial' | t='email' | t='diretor' | t='curso' 
       | t='portal' | t='académico' | t='Universidade' | t='Minho' | t='exame' | t='recurso' 
       | t='calendário' | t='escolar' | t='reitor' | t='horário' | t='regulamento' 
       | t='código' | t='ético' | t='conduta' | t='direitos' | t='deveres' |  t='cadeira' 
       | t='unidade' | t='curricular' | t='ECT' | t='ECTS' | t='Erasmus') {$keyword.val=$t.text;}
       ;

/* Definição do Analisador Léxico */         
TEXTO: (('\'') ~('\'')* ('\''));

fragment LETRA : [a-zA-ZáéíóúÁÉÍÓÚÃãÕõâêôÂÊÔÀÈÌÒÙàèìòùÇç] ;

fragment DIGITO: [0-9];

fragment SIMBOLO : [-%$€@&()\[\]:{}=><+*;,ºª~^/\'"];

PONTOTERMINAL: [?.!];

PALAVRA: (LETRA | DIGITO | SIMBOLO)+;

Separador: ( '\r'? '\n' | ' ' | '\t' )+  -> skip; 