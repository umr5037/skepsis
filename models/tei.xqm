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
declare function getDivById($queryParams as map(*)) as map(*) {
 
  let $meta := map{
    'title' : $queryParams('id')
    }
  let $content := map{
    'tei' :  synopsx.lib.commons:getDb($queryParams)//tei:TEI[@xml:id='skepsis']//tei:div[@xml:id=$queryParams('id')]/tei:div[@xml:lang=$queryParams('lang')]    
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
declare function getScepticiList($queryParams as map(*)) as map(*) {
  let $queryParams := map:put($queryParams, "path", "philosophi.xml")
  let $sceptici := synopsx.lib.commons:getDb($queryParams)//tei:person
  let $meta := map{
    'title' : 'Index philosophi sceptici'
    }
  let $content := for $item in $sceptici   order by $item collation "?lang=fr-FR" return getScepticus($item)

  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};


declare function getScepticus($item) as map(*){

map {
     'id' : fn:data($item/@xml:id),
     'fr' : $item/tei:persName[@xml:lang='fr'],
     'la' : $item/tei:persName[@xml:lang='la'],
     'tei' : $item
    }
};



(: TODO : factoriser getTextPartByScepticus et getTextPartByNotio !!!!:)

declare function getTextPartByScepticus($queryParams as map(*)) as map(*) {

  let $ref := '#' ||  $queryParams('id')
  let $textType := $queryParams('type')
  let $parts := if (fn:empty($textType)) 
                then synopsx.lib.commons:getDb($queryParams)//tei:*[(@corresp | @source) contains text {$ref}][fn:not(ancestor-or-self::*[@type='translatio'])]
                else  synopsx.lib.commons:getDb($queryParams)//tei:*[@type = $textType][(@corresp | @source) contains text {$ref}][fn:not(ancestor-or-self::*[@type='translatio'])]
  let $notio :=  $queryParams('notio')
  let $parts := if (fn:empty($notio))
  then  $parts
  else
   let $notio :=  '#' || $notio
   return $parts[ancestor-or-self::*[@ana contains text {$notio}]]
  let $meta := map{
    'title' : $queryParams('id'),
    'scepticus'  : $queryParams('id'),
    'type' : $textType,
    'notioTitle' : map:get(getNotioById(map:put($queryParams, 'id', $notio)), 'title'),
     'notio' : $notio
    }
  let $content := for $item in $parts         
          order by fn:number($item/@n)
          return getTextPartMap($item)
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
  let $notiones := if (fn:empty($queryParams('scepticus')))
    then $notiones
    else
      let $scepticus := '#' || $queryParams('scepticus')
      let $corpus := synopsx.lib.commons:getDb($queryParams)//tei:div
        for $notio in $notiones
        let $label := '#' || $notio
        where $corpus//tei:*[@ana contains text {$label}][descendant-or-self::*[@source contains text {$scepticus} or @corresp contains text {$scepticus}]]
        return $notio
  let $meta := map{
    'title' : 'Index notionum'
    }
  let $content := for $notio in $notiones 
  let $map := getNotioById(map:put($queryParams, 'id', $notio))
        order by fn:number($map('count')) descending,  $map('title')
        return $map
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};


declare function getNotioById($queryParams as map(*)*) as map(*){
   
        let $id :=  $queryParams('id')
        let $item := synopsx.lib.commons:getDb($queryParams)//tei:keywords//tei:term[@xml:id = $id]
        let $title := $item/text()
        let $scepticus := $queryParams('scepticus')
        let $url := if (fn:empty($scepticus)) 
                    then  'notiones/' || $item/@xml:id 
                    else  'sceptici/' || $scepticus || '/notiones/' || $item/@xml:id  
        let $count := if (fn:empty($scepticus)) 
                      then fn:count(synopsx.lib.commons:getDb($queryParams)//tei:*[@ana contains text {'#' || $id}])
                      else fn:count(synopsx.lib.commons:getDb($queryParams)//tei:*[@ana contains text {'#' || $id}][descendant-or-self::*[@source contains text {$scepticus} or @corresp contains text {$scepticus}]])
        return map {
         'title' : $title ,
         'id' : $id ,
         'tei' : $item,
         'url' : $url,
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
          getTextPartMap($item)
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : TODO : factoriser le calcul de facettes
 :)
declare function getSubSection($queryParams as map(*)) as map(*) { 
  let $volumen := synopsx.models.tei:getTextById($queryParams)('content')('tei')
  let $author := $volumen//tei:titleStmt/tei:author
  let $title := $volumen//tei:titleStmt/tei:title
   let $subSection := getSubSectionById($queryParams)  
   let $livre := $subSection/ancestor::*[@type='livre']
   
   let  $previousSubSection :=
        if(fn:not(fn:empty($subSection/preceding-sibling::tei:div[$queryParams('type')])))
        then($subSection/preceding-sibling::tei:div[$queryParams('type')][fn:last()])
        else(if(fn:not(fn:empty($livre/preceding-sibling::tei:div[@type="livre"])))
             then($livre/preceding-sibling::tei:div[@type="livre"]/tei:div[$queryParams('type')][fn:last()])
             else())

      let $nextSubSection :=
        if(fn:not(fn:empty($subSection/following-sibling::tei:div[$queryParams('type')])))
        then($subSection/following-sibling::tei:div[$queryParams('type')][1])
        else(if(fn:not(fn:empty($livre/following-sibling::tei:div[@type="livre"])))
             then($livre/following-sibling::tei:div[@type="livre"]/tei:div[$queryParams('type')][1])
             else())
  let $meta := map{
    'title' : $title,
    'author' : $author,
    'livre' : $queryParams('livre'),
    'subSection' : $queryParams('subSection')  ,
     'facettes' : <tei:list type="facettes">{
      for $item in fn:distinct-values(fn:tokenize(fn:translate(fn:string-join($subSection//@ana), ' ', ''), '#'))
       return 
       let $notio := getNotioById(map:put($queryParams, 'id', $item))
       return <tei:item ref="{map:get($notio, 'url')}" n="{$item}">{map:get($notio, 'title')}</tei:item>
  }</tei:list>
           }
     
  let $content :=
     map {
       'id' : fn:data($volumen/@xml:id),
       'tei': $subSection,
       'type' : fn:data($subSection/tei:*[fn:local-name()='ab' or fn:local-name()='q'][fn:not(@type='translatio')]/@type),
       'gr' : $subSection/tei:*[fn:local-name()='head' or fn:local-name()='ab' or fn:local-name()='q'][fn:not(@type='translatio')],
       'fr' : $subSection/tei:*[fn:local-name()='head' or fn:local-name()='ab' or fn:local-name()='q'][@type='translatio'],
        'title' : $title,
    'author' : $author,
    'livre' : map:get($queryParams, 'livre'),
    'subSection' : $queryParams('subSection')  ,
     'subSectionType' : fn:data($subSection/@type),
    'nextLivre' : fn:data($nextSubSection/ancestor::*[@type='livre']/@n),
     'prevLivre' : fn:data($previousSubSection/ancestor::*[@type='livre']/@n),
     'nextSubSection' : fn:data($nextSubSection/@n),
    'prevSubSection' : fn:data($previousSubSection/@n)
         } 
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

declare function getParagraph($textPart as node())  {
  let $textPartId :=  $textPart/@xml:id
  let $tei := $textPart//ancestor::tei:TEI
  let $paragraph := ($textPart/*:milestone)[1]/fn:data(@n)
  (: toto : quand texte avant le milestone, milestone précedent :)
  return if(fn:not(fn:empty($paragraph)) and  fn:normalize-space(($textPart/*:milestone)[1]/fn:string-join(preceding-sibling::text())) = '' ) then $paragraph 
          else $tei//tei:*[@xml:id = $textPartId]//(preceding::*:milestone)[1]/fn:data(@n) 
          
};

declare function getFirstSubSection($volumen as node()) as map(*){
   let $firstBook := $volumen//tei:div[@type="livre"][1]
   let $firstSubSection := $firstBook/tei:div[1]
   return map{
     'livre' : fn:data($firstBook/@n),
     'subSection' : fn:data($firstSubSection/@n),
     'type':fn:data($firstSubSection/@type)
   }
};

declare function getSubSectionById($queryParams as map(*)) as node()*{
 synopsx.lib.commons:getDb($queryParams)/tei:TEI[@xml:id = $queryParams('id')]//tei:div[@type="livre" and @n=map:get($queryParams, 'livre')]/tei:div[$queryParams('type') and @n=$queryParams('subSection')]
};




(:~
 : this function returns a sequence of map for meta and content
 : !! the result structure has changed to allow sorting early in mapping
 :
 : @rmq for testing with new htmlWrapping
 :)
declare function getTextsList($queryParams as map(*)) as map(*) {
  let $meta := map{
    'title' : 'Index voluminorum'
    }
  let $content := for $volumen in synopsx.lib.commons:getDb($queryParams)/tei:TEI[fn:not(@xml:id = "skepsis")]  
   order by $volumen//tei:titleStmt/tei:author , $volumen//tei:titleStmt/tei:title     
     return 
     map {
          'id': fn:data($volumen/@xml:id),
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
declare function getTextsListByAuthor($queryParams as map(*)) as map(*) {
  let $meta := map{
    'title' : 'Liste des textes'
    }
  let $content := for $volumen in synopsx.lib.commons:getDb($queryParams)/tei:TEI[fn:not(@xml:id = "skepsis")][tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/@key contains text {$queryParams('id')}]    
     return 
     map {
          'id': fn:data($volumen/@xml:id),
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


(:~
 : this function returns a map for discribing a text part
 : @rmq for testing with new htmlWrapping
 :)
declare function getTextPartMap($item as node()) as map(*) {
 
          map {
         'id' : fn:data($item/@xml:id),
         'type' : fn:data($item/@type),
         'n' :fn:data($item/@n),
         'corresp' : fn:data($item/@corresp),
         'gr': $item,
          'fr' : $item/ancestor::tei:div//tei:*[@corresp = '#' || $item/@xml:id],
          'volumen' : fn:data($item/ancestor::tei:TEI/@xml:id),
         'author' : $item/ancestor::tei:TEI//tei:titleStmt/tei:author,
         'title':$item/ancestor::tei:TEI//tei:titleStmt/tei:title,
          'livre':fn:data($item/ancestor::tei:div[@type='livre']/@n),
          'subSection' :  fn:data($item/ancestor::tei:div[1]/@n),
           'subSectionType' :  fn:data($item/ancestor::tei:div[1]/@type),
          'paragraphe' : fn:data(getParagraph($item))
        }        
};
