<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:papy="Papyrillio"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:fm="http://www.filemaker.com/fmpxmlresult"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:fn="http://www.xsltfunctions.com/"
    xmlns:functx="http://www.functx.com"
    xmlns="http://www.tei-c.org/ns/1.0">

    <!--
    java -Xms512m -Xmx1536m net.sf.saxon.Transform -o:data/IDNOS.xml -it:GET_IDNOS -xsl:xslt/getIdnos.xsl > getIdnos 2>&1
    -->

    <xsl:output method="xml" media-type="text/xml" />
    <xsl:include href="helper.xsl" />

    <xsl:template name="GET_IDNOS">
        <xsl:call-template name="IDNOS">
            <xsl:with-param name="idp.data" select="'../idp.data/papyri/master'"/>
            <xsl:with-param name="reference" select="'HGV'"/>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>