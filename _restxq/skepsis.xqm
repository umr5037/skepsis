xquery version "3.0" ;
module namespace skepsis.webapp = 'skepsis.webapp' ;

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
import module namespace synopsx.lib.commons = 'synopsx.lib.commons' at '../../../lib/commons.xqm' ;

(: Put here all import modules declarations as needed :)
import module namespace synopsx.models.tei = 'synopsx.models.tei' at '../../../models/tei.xqm' ;
import module namespace skepsis.models.tei = 'skepsis.models.tei' at '../models/tei.xqm' ;

(: Put here all import declarations for mapping according to models :)
import module namespace synopsx.mappings.htmlWrapping = 'synopsx.mappings.htmlWrapping' at '../../../mappings/htmlWrapping.xqm' ;

(: Use a default namespace :)
declare default function namespace 'skepsis.webapp' ;


declare variable $skepsis.webapp:project := 'skepsis' ;
declare variable $skepsis.webapp:db := synopsx.lib.commons:getProjectDB($skepsis.webapp:project) ;



(:~
 : this resource function redirect to /home
 :
 :)
declare 
  %restxq:path("/skepsis")
function index() {
  <rest:response>
    <http:response status="303" message="See Other">
      <http:header name="location" value="/skepsis/home"/>
    </http:response>
  </rest:response>
};

(:~
 : this resource function is the html representation of the corpus resource
 :
 : @return an html representation of the corpus resource with a bibliographical list
 : the HTML serialization also shows a bibliographical list
 :)
declare 
  %restxq:path('/skepsis/{$page}')
  %rest:produces('text/html')
  %output:method("html")
  %output:html-version("5.0")
function page($page) {
  let $queryParams := map {
    'project' : $skepsis.webapp:project,
    'dbName' :  $skepsis.webapp:db,
    'model' : 'tei' ,
    'function' : 'getDivById',
    'id' : $page,
    'lang' : 'fr'
    }
  let $outputParams := map {
    'lang' : 'fr',
    'layout' : 'home.xhtml',
    'pattern' : 'inc_defaultItem.xhtml' ,
    'xsl' : 'skepsis.xsl'
    }  
 return synopsx.lib.commons:htmlDisplay($queryParams, $outputParams)
};

declare 
  %restxq:path('/skepsis/en/{$page}')
  %rest:produces('text/html')
  %output:method("html")
  %output:html-version("5.0")
function pageEn($page) {
  let $queryParams := map {
    'project' : $skepsis.webapp:project,
    'dbName' :  $skepsis.webapp:db,
    'model' : 'tei' ,
    'function' : 'getDivById',
    'id' : $page,
    'lang' : 'en'
    }
  let $outputParams := map {
    'lang' : 'fr',
    'layout' : 'home.xhtml',
    'pattern' : 'inc_defaultItem.xhtml' ,
    'xsl' : 'skepsis.xsl'
    }  
 return synopsx.lib.commons:htmlDisplay($queryParams, $outputParams)
};


(:~
 : this resource function is the html representation of the corpus resource
 :
 : @return an html representation of the corpus resource with a bibliographical list
 : the HTML serialization also shows a bibliographical list
 :)
declare 
  %restxq:path('/skepsis/volumina')
  %rest:produces('text/html')
  %output:method("html")
  %output:html-version("5.0")
function textsHtml() {  
    let $queryParams := map {
    'project' : $skepsis.webapp:project,
    'dbName' :  $skepsis.webapp:db,
    'model' : 'tei' ,
    'function' : 'getTextsList'
    }
   let $outputParams := map {
    'lang' : 'fr',
    'layout' : 'volumina.xhtml',
    'pattern' : 'inc_textTitleItem.xhtml' ,
    'xsl' : 'skepsis.xsl' 
    }
 return synopsx.lib.commons:htmlDisplay($queryParams, $outputParams)
};


(:~
 : this resource function is the html representation of the corpus resource
 :
 : @return an html representation of the corpus resource with a bibliographical list
 : the HTML serialization also shows a bibliographical list
 :)
declare 
  %restxq:path('/skepsis/volumina/{$id}/xml')
  %rest:produces('text/xml')
function textXml($id) {  
 let $queryParams := map {
    'project' : $skepsis.webapp:project,
    'dbName' :  $skepsis.webapp:db,
    'model' : 'tei' ,
    'function' : 'getTextById',
    'id' : $id
    }
    let $text := synopsx.models.tei:getTextById($queryParams)
    let $node := $text('content')('tei')
    
     return
 $node
};

(:~
 : this resource function is the html representation of the corpus resource
 :
 : @return an html representation of the corpus resource with a bibliographical list
 : the HTML serialization also shows a bibliographical list
 :)
declare 
  %restxq:path('/skepsis/volumina/{$id}')
  %rest:produces('text/html')
  %output:method("html")
  %output:html-version("5.0")
function textHtml($id) {  
 let $queryParams := map {
    'project' : $skepsis.webapp:project,
    'dbName' :  $skepsis.webapp:db,
    'model' : 'tei' ,
    'function' : 'getTextById',
    'id' : $id
    }
    let $text := synopsx.models.tei:getTextById($queryParams)
    let $node := $text('content')('tei')
    let $firstSubSection := skepsis.models.tei:getFirstSubSection($node)
     return
  <rest:response>
    <http:response status="303" message="See Other">
      <http:header name="location" value="/skepsis/volumina/{$id}/livre/{map:get($firstSubSection, 'livre')}/{map:get($firstSubSection, 'type')}/{map:get($firstSubSection, 'subSection')}"/>
    </http:response>
  </rest:response>
};

(:~
 : this resource function redirect to /home
 :
 :)
declare 
  %restxq:path("/skepsis/sceptici/Sextus")
function sextus() {
  <rest:response>
    <http:response status="303" message="See Other">
      <http:header name="location" value="/skepsis/volumina/Sextus"/>
    </http:response>
  </rest:response>
};

declare 
  %restxq:path('/skepsis/volumina/Sextus')
  %rest:produces('text/html')
  %output:method("html")
  %output:html-version("5.0")
function textHtml() {  
 let $queryParams := map {
    'project' : $skepsis.webapp:project,
    'dbName' :  $skepsis.webapp:db,
    'model' : 'tei' ,
    'function' : 'getTextsListByAuthor',
    'id' : 'Sextus'
    }
   let $outputParams := map {
    'lang' : 'fr',
    'layout' : 'volumina.xhtml',
    'pattern' : 'inc_textTitleItem.xhtml' ,
    'xsl' : 'skepsis.xsl' 
    }
 return synopsx.lib.commons:htmlDisplay($queryParams, $outputParams)
};



(:~
 : this resource function is the html representation of the corpus resource
 :
 : @return an html representation of the corpus resource with a bibliographical list
 : the HTML serialization also shows a bibliographical list
 :)
declare 
  %restxq:path('/skepsis/volumina/{$id}/livre/{$livre}/{$type}/{$subSection}')
  %rest:produces('text/html')
  %output:method("html")
  %output:html-version("5.0")
function textHtml($id, $livre, $subSection,$type) {  
    let $queryParams := map {
    'project' : $skepsis.webapp:project,
    'dbName' :  $skepsis.webapp:db,
    'model' : 'tei' ,
    'function' : 'getSubSection',
    'id' : $id,
    'livre' : $livre,
    'subSection' : $subSection,
    'type' : $type
    }
   let $outputParams := map {
    'lang' : 'fr',
    'layout' : 'volumina.xhtml',
    'pattern' : 'inc_subSectionItem.xhtml' ,
    'xsl' : 'skepsis.xsl' 
    }
 return synopsx.lib.commons:htmlDisplay($queryParams, $outputParams)
};


declare 
  %restxq:path('/skepsis/sceptici')
  %rest:produces('text/html')
  %output:method("html")
  %output:html-version("5.0")
function scepticiHtml() {
    let $queryParams := map {
    'project' : $skepsis.webapp:project,
    'dbName' :  $skepsis.webapp:db,
    'model' : 'tei' ,
    'function' : 'getScepticiList'
    }
    
     let $outputParams := map {
    'lang' : 'fr',
    'layout' : 'sceptici.xhtml',
    'pattern' : 'inc_scepticusItem.xhtml' ,
    'xsl' : 'skepsis.xsl' 
    }  
 return synopsx.lib.commons:htmlDisplay($queryParams, $outputParams)
};


declare 
  %restxq:path('/skepsis/sceptici/{$id}')
  %rest:produces('text/html')
  %output:method("html")
  %output:html-version("5.0")
function scepticusHtml($id) {
    let $queryParams := map {
    'project' : $skepsis.webapp:project,
    'dbName' :  $skepsis.webapp:db,
    'model' : 'tei' ,
    'function' : 'getTextPartByScepticus',
    'id' : $id,
    'xsl' : 'skepsis.xsl' 
    }
    
     let $outputParams := map {
    'lang' : 'fr',
    'layout' : 'scepticus.xhtml',
    'pattern' : 'inc_textPartItem.xhtml' ,
    'xsl' : 'skepsis.xsl' 
    }  
 return synopsx.lib.commons:htmlDisplay($queryParams, $outputParams)
};


declare 
  %restxq:path('/skepsis/sceptici/{$id}/notiones/{$notio}')
  %rest:produces('text/html')
  %output:method("html")
  %output:html-version("5.0")
function scepticusHtml($id,$notio) {
    let $queryParams := map {
    'project' : $skepsis.webapp:project,
    'dbName' :  $skepsis.webapp:db,
    'model' : 'tei' ,
    'function' : 'getTextPartByScepticus',
    'id' : $id,
    'notio' : $notio,
    'xsl' : 'skepsis.xsl' 
    }
    
     let $outputParams := map {
    'lang' : 'fr',
    'layout' : 'scepticusByNotio.xhtml',
    'pattern' : 'inc_textPartItem.xhtml' ,
    'xsl' : 'skepsis.xsl' 
    }  
 return synopsx.lib.commons:htmlDisplay($queryParams, $outputParams)
};



declare 
  %restxq:path('/skepsis/notiones')
  %rest:produces('text/html')
  %output:method("html")
  %output:html-version("5.0")
function notionesHtml() {
    let $queryParams := map {
    'project' : $skepsis.webapp:project,
    'dbName' :  $skepsis.webapp:db,
    'model' : 'tei' ,
    'function' : 'getNotionesList'
    }
    
     let $outputParams := map {
    'lang' : 'fr',
    'layout' : 'notiones.xhtml',
    'pattern' : 'inc_notioItem.xhtml' ,
    'xsl' : 'skepsis.xsl' 
    }  
 return synopsx.lib.commons:htmlDisplay($queryParams, $outputParams)
};




declare 
  %restxq:path('/skepsis/notiones/{$id}')
  %rest:produces('text/html')
  %output:method("html")
  %output:html-version("5.0")
function notioHtml($id) {
    let $queryParams := map {
    'project' : $skepsis.webapp:project,
    'dbName' :  $skepsis.webapp:db,
    'model' : 'tei' ,
    'function' : 'getTextPartByNotio',
    'id' : $id
    }
    
     let $outputParams := map {
    'lang' : 'fr',
    'layout' : 'notiones.xhtml',
    'pattern' : 'inc_textPartItem.xhtml' ,
    'xsl' : 'skepsis.xsl' 
    }  
 return synopsx.lib.commons:htmlDisplay($queryParams, $outputParams)
};

declare 
  %restxq:path('/skepsis/notiones/{$id}/sceptici/{$scepticus}')
  %rest:produces('text/html')
  %output:method("html")
  %output:html-version("5.0")
function notioHtml($id, $scepticus) {
    let $queryParams := map {
    'project' : $skepsis.webapp:project,
    'dbName' :  $skepsis.webapp:db,
    'model' : 'tei' ,
    'scepticus' : $scepticus,
    'function' : 'getTextPartByNotio',
    'id' : $id
    }
    
     let $outputParams := map {
    'lang' : 'fr',
    'layout' : 'notiones.xhtml',
    'pattern' : 'inc_textPartItem.xhtml' ,
    'xsl' : 'skepsis.xsl' 
    }  
 return synopsx.lib.commons:htmlDisplay($queryParams, $outputParams)
};

declare 
  %restxq:path('/skepsis/bibl')
  %rest:produces('text/html')
  %output:method("html")
  %output:html-version("5.0")
function biblHtml() {
    let $queryParams := map {
    'project' : $skepsis.webapp:project,
    'dbName' :  $skepsis.webapp:db,
    'model' : 'tei' ,
    'function' : 'getBiblList'
    }
    
    let $outputParams := map {
    'lang' : 'fr',
    'layout' : 'home.xhtml',
    'pattern' : 'inc_BiblItem.xhtml' ,
    'xsl' : 'tei2html.xsl' 
    }
    
      
 return synopsx.lib.commons:htmlDisplay($queryParams, $outputParams)
};

(:~
 : this resource function is a corpus list for testing
 :
 : @param $pattern a GET param giving the name of the calling HTML tag
 : @return an html representation of the corpus list
 : @todo use this tag !
 :)
declare 
  %restxq:path("/skepsis/inc/texts")
 (:  %restxq:query-param("pattern", "{$pattern}") :)
function corpusListHtml() {
    let $queryParams := map {
    'project' : $skepsis.webapp:project,
    'dbName' :  $skepsis.webapp:db,
    'model' : 'tei' ,
    'function' : 'getTextsList'
    }
    
   let $outputParams := map {
    'lang' : 'fr',
    'layout' : 'inc_defaultList.xhtml',
    'pattern' : 'inc_defaultItem.xhtml' ,
    'xsl' : 'tei2html.xsl' 
    }
   return synopsx.lib.commons:htmlDisplay($queryParams, $outputParams)
};

(:~
 : this resource function is a bibliographical list for testing
 :
 : @param $pattern a GET param giving the name of the calling HTML tag
 : @return an html representation of the bibliographical list
 : @todo use this tag !
 :)
declare 
  %restxq:path("/skepsis/inc/resp")
  %restxq:query-param("pattern", "{$pattern}")
function biblioListHtml($pattern as xs:string?) {
  let $queryParams := map {
    'project' : $skepsis.webapp:project,
    'dbName' :  $skepsis.webapp:db,
    'model' : 'tei' ,
    'function' : 'getRespList'
    }

  let $outputParams := map {
    'lang' : 'fr',
    'layout' : 'inc_defaultList.xhtml',
    'pattern' : 'inc_RespItem.xhtml' 
    }
        
return synopsx.lib.commons:htmlDisplay($queryParams, $outputParams)
};  


declare 
  %restxq:path('/skepsis/inc/notiones')
  %rest:produces('text/html')
  %output:method("html")
  %output:html-version("5.0")
function notionesIncHtml() {
    let $queryParams := map {
    'project' : $skepsis.webapp:project,
    'dbName' :  $skepsis.webapp:db,
    'model' : 'tei' ,
    'function' : 'getNotionesList'
    }
    
     let $outputParams := map {
    'lang' : 'fr',
    'layout' : 'inc_defaultAside.xhtml',
    'pattern' : 'inc_notioNavItem.xhtml' ,
    'xsl' : 'skepsis.xsl' 
    }  
 return synopsx.lib.commons:htmlDisplay($queryParams, $outputParams)
};



declare 
  %restxq:path('/skepsis/inc/notiones/sceptici/{$scepticus}')
  %rest:produces('text/html')
  %output:method("html")
  %output:html-version("5.0")
function notionesIncHtml($scepticus) {
    let $queryParams := map {
    'project' : $skepsis.webapp:project,
    'dbName' :  $skepsis.webapp:db,
    'model' : 'tei' ,
    'scepticus' : $scepticus,
    'function' : 'getNotionesList'
    }
    
     let $outputParams := map {
    'lang' : 'fr',
    'layout' : 'inc_defaultAside.xhtml',
    'pattern' : 'inc_notioNavItem.xhtml' ,
    'xsl' : 'skepsis.xsl' 
    }  
 return synopsx.lib.commons:htmlDisplay($queryParams, $outputParams)
};

declare 
  %restxq:path('/skepsis/inc/sceptici/{$id}/part/{$type}')
  %rest:produces('text/html')
  %output:method("html")
  %output:html-version("5.0")
function scepticusByTextTypeHtml($id, $type) {
    let $queryParams := map {
    'project' : $skepsis.webapp:project,
    'dbName' :  $skepsis.webapp:db,
    'model' : 'tei' ,
    'function' : 'getTextPartByScepticus',
    'id' : $id,
    'type' : $type,
    'xsl' : 'skepsis.xsl' 
    }
    
     let $outputParams := map {
    'lang' : 'fr',
    'layout' : 'inc_textPartList.xhtml',
    'pattern' : 'inc_textPartItem.xhtml' ,
    'xsl' : 'skepsis.xsl' 
    }  
 return synopsx.lib.commons:htmlDisplay($queryParams, $outputParams)
};


declare 
  %restxq:path('/skepsis/inc/sceptici/{$id}/notio/{$notio}/part/{$type}')
  %rest:produces('text/html')
  %output:method("html")
  %output:html-version("5.0")
function scepticusByTextTypeHtml($id, $notio, $type) {
    let $queryParams := map {
    'project' : $skepsis.webapp:project,
    'dbName' :  $skepsis.webapp:db,
    'model' : 'tei' ,
    'function' : 'getTextPartByScepticus',
    'id' : $id,
    'notio' : $notio,
    'type' : $type,
    'xsl' : 'skepsis.xsl' 
    }
    
     let $outputParams := map {
    'lang' : 'fr',
    'layout' : 'inc_textPartList.xhtml',
    'pattern' : 'inc_textPartItem.xhtml' ,
    'xsl' : 'skepsis.xsl' 
    }  
 return synopsx.lib.commons:htmlDisplay($queryParams, $outputParams)
};
