xquery version "3.0" ;
module namespace skepsis.models.tei = 'skepsis.models.tei' ;

(:~
 : This module is the RESTXQ for SynopsX's skepsis
 :
 : @version 2.0 (Constantia edition)
 : @since 2015-02-05
 : @author synopsx team
 :
 : This file is part of SynopsX.
 : created by AHN team (http://ahn.ens-lyon.fr)
 :
 : SynopsX is free software: you can redistribute it and/or modify
 : it under the terms of the GNU General Public License as published by
 : the Free Software Foundation, either version 3 of the License, or
 : (at your option) any later version.
 :
 : SynopsX is distributed in the hope that it will be useful,
 : but WITHOUT ANY WARRANTY; without even the implied warranty of
 : MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 : See the GNU General Public License for more details.
 : You should have received a copy of the GNU General Public License along
 : with SynopsX. If not, see http://www.gnu.org/licenses/
 :
 :)

(: Import synopsx's globals variables and libraries :)
import module namespace G = "synopsx.globals" at '../../../globals.xqm' ;

(: Put here all import modules declarations as needed :)
import module namespace synopsx.models.tei = 'synopsx.models.tei' at '../../../models/tei.xqm' ;
import module namespace synopsx.lib.commons = 'synopsx.lib.commons' at '../../../lib/commons.xqm' ;
declare namespace tei = 'http://www.tei-c.org/ns/1.0' ;

(: Use a default namespace :)
declare default function namespace 'skepsis.models.tei' ;


(:~
 : this function returns a sequence of map for meta and content
 : !! the result structure has changed to allow sorting early in mapping
 :
 : @rmq for testing with new htmlWrapping
 :)
declare function getScepticiList($queryParams as map(*)) as map(*) {
  let $queryParams := map:put($queryParams, "path", "philosophi.xml")
  let $sceptici := synopsx.lib.commons:getDb($queryParams)//tei:person
  let $meta := map{
    'title' : 'Liste des sceptiques'
    }
  let $content := for $item in $sceptici return getScepticus($item)
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};


declare function getScepticus($item) as map(*){

map {
     'title' : $item/tei:persName[1] ,
     'tei' : $item
    }
};

declare function getFirstChapter($volumen as node()) as map(*){
   let $premierLivre := $volumen//tei:div[@type="livre"][1]
   let $premierChapitre := $premierLivre//tei:div[@type="chapitre"][1]
   return map{
     'livre' : $premierLivre/fn:data(@n),
     'chapitre' : $premierChapitre/fn:data(@n)
   }
};

declare function getChapterById($queryParams as map(*)) as node()*{
 synopsx.lib.commons:getDb($queryParams)/tei:TEI[.//tei:titleStmt/tei:title = map:get($queryParams, 'title')]//tei:div[@type="livre" and @n=map:get($queryParams, 'livre')]/tei:div[@type="chapitre" and @n=map:get($queryParams, 'chapitre')]
};

(: declare function getNextChapter($volumen as node(), $NLivre as xs:string, $NChapitre as xs:string) as map(*){
            
      let $livre := $volumen//tei:div[@type="livre" and @n=$NLivre]
      let $chapitre := $livre//tei:div[@type="chapitre" and @n=$NChapitre]

        let $suivant :=
        if(not(empty($chapitre/following-sibling::tei:div[@type="chapitre"])))
        then($chapitre/following-sibling::tei:div[@type="chapitre"][1])
        else(if(not(empty($livre/following-sibling::tei:div[@type="livre"])))
             then($livre/following-sibling::tei:div[@type="livre"]/tei:div[@type="chapitre"][1])
             else())
      
      let $content := $volumen/tei:TEI[fn:not(@xml:id = "skepsis")]
      let $livre := $volumen//tei:div[@type="livre"][1]
      let $chapitre := $livre//tei:div[@type="chapitre"][1]
}; :)


(:~
 : this function returns a sequence of map for meta and content
 : !! the result structure has changed to allow sorting early in mapping
 :
 : @rmq for testing with new htmlWrapping
 :)
declare function getTextsList($queryParams as map(*)) as map(*) {
  let $meta := map{
    'title' : 'Liste des textes'
    }
  let $content := for $volumen in synopsx.lib.commons:getDb($queryParams)/tei:TEI[fn:not(@xml:id = "skepsis")]       
     return 
     map {
          'url': "volumina/" || $volumen//tei:titleStmt/tei:title/text(),
          'author':$volumen//tei:titleStmt/tei:author/text(),
          'title':$volumen//tei:titleStmt/tei:title/text() 
         } 
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : this function returns a sequence of map for meta and content
 : !! the result structure has changed to allow sorting early in mapping
 :
 : @rmq for testing with new htmlWrapping
 :)
declare function getChapter($queryParams as map(*)) as map(*) {
  
  let $volumen := getTextByTitle($queryParams)
  let $author := $volumen//tei:titleStmt/tei:author/text()
  let $title := $volumen//tei:titleStmt/tei:title/text() 
  
  let $meta := map{
    'title' : $title,
    'author' : $author,
    'livre' : map:get($queryParams, 'livre'),
    'chapitre' : map:get($queryParams, 'chapitre')  
           }
  let $chapitre := getChapterById($queryParams)      
  let $content :=
     map {
          'tei': $chapitre

         } 
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : this function returns a sequence of map for meta and content
 : !! the result structure has changed to allow sorting early in mapping
 :
 : @rmq for testing with new htmlWrapping
 :)
declare function getTextByTitle($queryParams as map(*)) as node()* {
   synopsx.lib.commons:getDb($queryParams)/tei:TEI[.//tei:titleStmt/tei:title = map:get($queryParams, 'title')]          
};
