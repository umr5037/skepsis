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

(: TODO : factoriser getTextPartByScepticus et getTextPartByNotio !!!!:)

declare function getTextPartByScepticus($queryParams as map(*)) as map(*) {
  let $ref := '#' || map:get($queryParams, 'id')
  let $parts := synopsx.lib.commons:getDb($queryParams)//tei:div//tei:*[(@corresp | @source) contains text {$ref}][fn:not(ancestor-or-self::*[@type='translatio'])]
  let $meta := map{
    'title' : 'Sceptique : ' ||  map:get($queryParams, 'id'),
      'facettes' : <tei:list type="facettes">{
      for $item in fn:distinct-values(fn:tokenize(fn:translate(fn:string-join($parts/@ana), ' ', ''), '#'))
       return 
       let $notio := getNotioById(map:put($queryParams, 'id', $item))
       return <tei:item ref="{map:get($notio, 'url')}" n="{$item}">{map:get($notio, 'title')}</tei:item>
  }</tei:list>
    }
  let $content := for $item in $parts return 
          map {
         'id' : fn:data($item/@xml:id),
         'type' : fn:data($item/@type),
         'n' : fn:data($item/@n),
         'corresp' : fn:data($item/@corresp),
         'gr': $item,
          'fr' : synopsx.lib.commons:getDb($queryParams)//tei:*[@corresp = '#' || $item/@xml:id],
         'author' : $item/ancestor::tei:TEI//tei:titleStmt/tei:author,
         'title':$item/ancestor::tei:TEI//tei:titleStmt/tei:title,
          'livre':fn:data($item/ancestor::tei:div[@type='livre']/@n),
          'chapitre' :  fn:data($item/ancestor::tei:div[@type='chapitre']/@n),
          'paragraphe' : fn:data(getParagraph(map:put($queryParams, 'id', $item/@xml:id)))
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
  let $notiones := synopsx.lib.commons:getDb($queryParams)//tei:keywords//tei:term/@xml:id
  let $meta := map{
    'title' : 'Liste des notions'
    }
  let $content := for $notio in $notiones return getNotioById(map:put($queryParams, 'id', $notio))
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};


declare function getNotioById($queryParams as map(*)*) as map(*){
   
        let $id :=  map:get($queryParams, 'id')
        let $item := synopsx.lib.commons:getDb($queryParams)//tei:keywords//tei:term[@xml:id = $id]
        let $title := $item/text()
        let $count := fn:count(synopsx.lib.commons:getDb($queryParams)//tei:*[@ana contains text {'#' || $id}])
        return map {
         'title' : $title ,
         'id' : $id ,
         'tei' : $item,
         'url' : 'notiones/' || $item/@xml:id,
         'count' : fn:string($count),
          'weight' : fn:format-number($count, '00')
        }
};


declare function getTextPartByNotio($queryParams as map(*)) as map(*) {
  let $id := map:get($queryParams, 'id')
  let $parts := synopsx.lib.commons:getDb($queryParams)//tei:div//tei:*[@ana contains text {'#' || $id}][fn:not(ancestor-or-self::*[@type='translatio'])]
  let $meta := map{
    'title' : 'Notion : ' ||  synopsx.lib.commons:getDb($queryParams)//tei:keywords//tei:term[@xml:id = $id],
    'facettes' : <tei:list type="facettes">{
      for $item in fn:distinct-values(fn:tokenize(fn:translate(fn:string-join($parts/@ana), ' ', ''), '#'))
       return 
       let $notio := getNotioById(map:put($queryParams, 'id', $item))
       return <tei:item ref="{map:get($notio, 'url')}" n="{$item}">{map:get($notio, 'title')}</tei:item>
  }</tei:list>
    }
  let $content := for $item in $parts return 
          map {
         'id' : fn:data($item/@xml:id),
         'type' : fn:data($item/@type),
         'n' :fn:data($item/@n),
         'corresp' : fn:data($item/@corresp),
         'gr': $item,
          'fr' : synopsx.lib.commons:getDb($queryParams)//tei:*[@corresp = '#' || $item/@xml:id],
         'author' : $item/ancestor::tei:TEI//tei:titleStmt/tei:author,
         'title':$item/ancestor::tei:TEI//tei:titleStmt/tei:title,
          'livre':fn:data($item/ancestor::tei:div[@type='livre']/@n),
          'chapitre' :  fn:data($item/ancestor::tei:div[@type='chapitre']/@n),
          'paragraphe' : fn:data(getParagraph(map:put($queryParams, 'id', $item/@xml:id)))
        }
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : TODO : factoriser le calcul de facettes
 :)
declare function getChapter($queryParams as map(*)) as map(*) { 
  let $volumen := synopsx.models.tei:getTextById($queryParams)('content')('tei')
  let $author := $volumen//tei:titleStmt/tei:author
  let $title := $volumen//tei:titleStmt/tei:title
   let $chapitre := getChapterById($queryParams)  
   let $livre := $chapitre/ancestor::*[@type='livre']
   
   let  $previousChapter :=
        if(fn:not(fn:empty($chapitre/preceding-sibling::tei:div[@type="chapitre"])))
        then($chapitre/preceding-sibling::tei:div[@type="chapitre"][fn:last()])
        else(if(fn:not(fn:empty($livre/preceding-sibling::tei:div[@type="livre"])))
             then($livre/preceding-sibling::tei:div[@type="livre"]/tei:div[@type="chapitre"][fn:last()])
             else())

      let $nextChapter :=
        if(fn:not(fn:empty($chapitre/following-sibling::tei:div[@type="chapitre"])))
        then($chapitre/following-sibling::tei:div[@type="chapitre"][1])
        else(if(fn:not(fn:empty($livre/following-sibling::tei:div[@type="livre"])))
             then($livre/following-sibling::tei:div[@type="livre"]/tei:div[@type="chapitre"][1])
             else())
  let $meta := map{
    'title' : $title,
    'author' : $author,
    'livre' : map:get($queryParams, 'livre'),
    'chapitre' : map:get($queryParams, 'chapitre')  ,
     'facettes' : <tei:list type="facettes">{
      for $item in fn:distinct-values(fn:tokenize(fn:translate(fn:string-join($chapitre//@ana), ' ', ''), '#'))
       return 
       let $notio := getNotioById(map:put($queryParams, 'id', $item))
       return <tei:item ref="{map:get($notio, 'url')}" n="{$item}">{map:get($notio, 'title')}</tei:item>
  }</tei:list>
           }
     
  let $content :=
     map {
       'id' : fn:data($volumen/@xml:id),
          'tei': $chapitre,
   'type' : fn:data($chapitre/tei:*[fn:local-name()='ab' or fn:local-name()='q'][fn:not(@type='translatio')]/@type),
          'gr' : $chapitre/tei:*[fn:local-name()='ab' or fn:local-name()='q'][fn:not(@type='translatio')],
          'fr' : $chapitre/tei:*[fn:local-name()='ab' or fn:local-name()='q'][@type='translatio'],
           'title' : $title,
    'author' : $author,
    'livre' : map:get($queryParams, 'livre'),
    'chapitre' : map:get($queryParams, 'chapitre')  ,
    'nextLivre' : fn:data($nextChapter/ancestor::*[@type='livre']/@n),
     'prevLivre' : fn:data($previousChapter/ancestor::*[@type='livre']/@n),
     'nextChapter' : fn:data($nextChapter/@n),
    'prevChapter' : fn:data($previousChapter//@n)
         } 
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

declare function getParagraph($queryParams as map(*))  {
  let $textPartId :=  fn:trace(map:get($queryParams, 'id'))
  let $tei := synopsx.lib.commons:getDb($queryParams)//tei:TEI[.//tei:*[@xml:id = $textPartId]]
  let $textPart := $tei//tei:*[@xml:id = $textPartId]
  let $paragraph := fn:trace(($textPart/*:milestone)[1]/fn:data(@n))
  (: toto : quand texte avant le milestone, milestone précedent :)
  return if(fn:not(fn:empty($paragraph)) and  fn:normalize-space(($textPart/*:milestone)[1]/fn:string-join(preceding-sibling::text())) = '' ) then $paragraph 
          else $tei//tei:*[@xml:id = $textPartId]//(preceding::*:milestone)[1]/fn:data(@n) 
          
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
 synopsx.lib.commons:getDb($queryParams)/tei:TEI[@xml:id = $queryParams('id')]//tei:div[@type="livre" and @n=map:get($queryParams, 'livre')]/tei:div[@type="chapitre" and @n=map:get($queryParams, 'chapitre')]
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
          'url': "volumina/" || $volumen/@xml:id,
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
declare function getTextByTitle($queryParams as map(*)) as node()* {
   synopsx.lib.commons:getDb($queryParams)/tei:TEI[.//tei:titleStmt/tei:title = map:get($queryParams, 'title')]          
};
