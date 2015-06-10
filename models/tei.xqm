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
     'url' : 'sceptici/' || $item/@xml:id,
     'fr' : $item/tei:persName[@xml:lang='fr'],
     'la' : $item/tei:persName[@xml:lang='la'],
     'tei' : $item
    }
};



declare function getTextPartByScepticus($queryParams as map(*)) as map(*) {
  let $ref := '#' || map:get($queryParams, 'id')
  let $parts := synopsx.lib.commons:getDb($queryParams)//tei:div//tei:*[@corresp contains text {$ref}]/ancestor-or-self::*:ab
  let $meta := map{
    'title' : 'Sceptique : ' ||  map:get($queryParams, 'id')
    }
  let $content := for $item in $parts return 
          map {
         'id' : $item/@xml:id,
         'type' : $item/@type,
         'n' : $item/@n,
         'corresp' : $item/@corresp,
         'gr': $item,
          'fr' : synopsx.lib.commons:getDb($queryParams)//tei:*[@corresp = '#' || $item/@xml:id],
         'author' : $item/ancestor::tei:TEI//tei:titleStmt/tei:author/text(),
         'title':$item/ancestor::tei:TEI//tei:titleStmt/tei:title/text(),
          'livre':$item/ancestor::tei:div[@type='livre']/fn:data(@n),
          'chapitre' :  $item/ancestor::tei:div[@type='chapitre']/fn:data(@n),
          'paragraphe' : getParagraph(map:put($queryParams, 'id', $item/fn:data(@xml:id)))
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
declare function getNotionesList($queryParams as map(*)) as map(*) {
  let $notiones := synopsx.lib.commons:getDb($queryParams)//tei:keywords//tei:term
  let $meta := map{
    'title' : 'Liste des notions'
    }
  let $content := for $notio in $notiones return getNotio($notio)
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};


declare function getNotio($item as node()) as map(*){
        map {
         'title' : $item/text() ,
         'id' : $item/@xml:id ,
         'tei' : $item,
         'url' : 'notiones/' || $item/@xml:id
        }
};


declare function getTextPartByNotio($queryParams as map(*)) as map(*) {
  let $ref := '#' || map:get($queryParams, 'id')
  let $parts := synopsx.lib.commons:getDb($queryParams)//tei:div//tei:*[@ana contains text {$ref}]
  let $meta := map{
    'title' : 'Notion : ' ||  map:get($queryParams, 'id')
    }
  let $content := for $item in $parts return 
          map {
         'id' : $item/@xml:id,
         'type' : $item/@type,
         'n' : $item/@n,
         'corresp' : $item/@corresp,
         'gr': $item,
          'fr' : synopsx.lib.commons:getDb($queryParams)//tei:*[@corresp = '#' || $item/@xml:id],
         'author' : $item/ancestor::tei:TEI//tei:titleStmt/tei:author/text(),
         'title':$item/ancestor::tei:TEI//tei:titleStmt/tei:title/text(),
          'livre':$item/ancestor::tei:div[@type='livre']/fn:data(@n),
          'chapitre' :  $item/ancestor::tei:div[@type='chapitre']/fn:data(@n),
          'paragraphe' : getParagraph(map:put($queryParams, 'id', $item/fn:data(@xml:id)))
        }
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

declare function getParagraph($queryParams as map(*))  {
  let $textPartId :=  map:get($queryParams, 'id')
  let $tei := synopsx.lib.commons:getDb($queryParams)//tei:div[tei:*[@xml:id = $textPartId]]
  let $textPart := $tei//tei:*[@xml:id = $textPartId]
  let $paragraph := $textPart/*:milestone[1]/fn:data(@n)
  return if(fn:empty($paragraph) || fn:not(fn:normalize-space($textPart/*:milestone[1]/fn:string-join(preceding-sibling::text())) = '')) then $tei//tei:*[@xml:id = $textPartId]//preceding::*:milestone[1]/fn:data(@n)
          else $paragraph 
          
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
          'author':$volumen//tei:titleStmt/tei:author,
          'title':$volumen//tei:titleStmt/tei:title
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
  let $author := $volumen//tei:titleStmt/tei:author
  let $title := $volumen//tei:titleStmt/tei:title
  
  let $meta := map{
    'title' : $title,
    'author' : $author,
    'livre' : map:get($queryParams, 'livre'),
    'chapitre' : map:get($queryParams, 'chapitre')  
           }
  let $chapitre := getChapterById($queryParams)      
  let $content :=
     map {
          'tei': $chapitre,
          'gr' : $chapitre/tei:ab[fn:not(@type='translatio')],
          'fr' : $chapitre/tei:ab[@type='translatio'],
           'title' : $title,
    'author' : $author,
    'livre' : map:get($queryParams, 'livre'),
    'chapitre' : map:get($queryParams, 'chapitre')  
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
