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

  
    
    <xsl:template match="*[local-name()='title']">
        <em><xsl:apply-templates /></em>
    </xsl:template>

</xsl:stylesheet>