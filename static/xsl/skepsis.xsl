<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
     xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs">
    <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>
   
    <xsl:import href="tei2html5.xsl"/>
    
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

<xsl:template match="*:ab | *:q">
    <span>
    <xsl:attribute name="title">Ref. :  <xsl:value-of select="@xml:id"/><xsl:text>&#xA;</xsl:text>(= <xsl:value-of select="*:bibl"/>)</xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
    </span>
</xsl:template>

 <xsl:template match="*:head">
 <xsl:variable name="level" select="count(./ancestor::*:div) + 4 mod 6"/>
             <xsl:element name="h{$level}">
             <xsl:apply-templates />
             </xsl:element>
    </xsl:template>

 <xsl:template match="*:quote">
             <span class="citation">
             <xsl:apply-templates />
             </span>
    </xsl:template>
    
     <xsl:template match="*:persName">
             <span class="person">
               <xsl:apply-templates />
             </span>
    </xsl:template>


   <xsl:template match="@type">
             <xsl:attribute name="class"><xsl:value-of select="."/></xsl:attribute>  
    </xsl:template>
    
    <xsl:template match="*:title[not(ancestor::*)]">
             <xsl:value-of select="text()" />
    </xsl:template>
  
    <xsl:template match="*:gap">
                [— — —]
    </xsl:template>
    

 <xsl:template match="*:bibl" /> 
   
   
    <xsl:template match="*:title[ancestor::*]">
                 <span class="title"><xsl:apply-templates /></span>
    </xsl:template>
    
    <xsl:template match="*:list[@type='facettes']//*:item">
        <a href="/skepsis/{@ref}" title="Notio : {text()}"><xsl:value-of select="text()"/></a>
    </xsl:template>

</xsl:stylesheet>