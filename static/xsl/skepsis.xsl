<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
     xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs">
    <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>
   
    <xsl:include href="tei2html5.xsl"/>
    
    
    <xsl:template match="/">

        <xsl:apply-templates/>
      

    </xsl:template>

   <xsl:template match="@type">
             <xsl:attribute name="class"><xsl:value-of select="."/></xsl:attribute>
              <xsl:attribute name="title"><xsl:value-of select="."/></xsl:attribute>
    </xsl:template>
    
    <xsl:template match="*:title[not(ancestor::*)]">
             <xsl:value-of select="text()" />
    </xsl:template>
    
    <xsl:template match="*:title[ancestor::*]">
                 <em><xsl:apply-templates /></em>
    </xsl:template>
    
    <xsl:template match="*:list[@type='facettes']//*:item">
        <a href="/skepsis/{@ref}" title="Notio : {text()}"><xsl:value-of select="text()"/></a>
    </xsl:template>

</xsl:stylesheet>