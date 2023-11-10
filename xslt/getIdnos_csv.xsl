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
    java -Xms512m -Xmx1536m net.sf.saxon.Transform -o:data/IDNOS.csv -it:GET_IDNOS -xsl:xslt/getIdnos_csv.xsl > getIdnos_csv 2>&1
    java -Xms512m -Xmx1536m net.sf.saxon.Transform -o:data/REDIRECTS.csv -it:GET_REDIRECTS -xsl:xslt/getIdnos_csv.xsl > getRedirects_csv 2>&1
    -->

    <xsl:output method="text" media-type="text/csv" />
    <xsl:include href="helper.xsl" />

    <xsl:template name="GET_IDNOS">
        <xsl:call-template name="papy:csvLine">
            <xsl:with-param name="data" select="('HGV', 'TM', 'DDB', 'DCLP')"/>
        </xsl:call-template>
        <xsl:for-each select="$IDNOS//tei:item">
            <xsl:variable name="hgv" select="if(@hgv)then(string(@hgv))else('')"/>
            <xsl:variable name="tm" select="if(@tm)then(string(@tm))else('')"/>
            <xsl:variable name="ddb" select="if(@ddb)then(string(@ddb))else('')"/>
            <xsl:variable name="dclp" select="if(@dclp)then(string(@dclp))else('')"/>
            <xsl:if test="string($hgv) or string($ddb) or string($dclp)">
                <xsl:call-template name="papy:csvLine">
                    <xsl:with-param name="data" select="($hgv, $tm, $ddb, $dclp)"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="GET_REDIRECTS">
        <xsl:call-template name="papy:csvLine">
            <xsl:with-param name="data" select="('ddb', 'ddb-reprint', 'hgv', 'tm')"/>
        </xsl:call-template>
        <xsl:for-each select="$REDIRECTS//tei:item">
            <xsl:variable name="hgv" select="if(@hgv)then(string(@hgv))else('')"/>
            <xsl:variable name="tm" select="if(@tm)then(string(@tm))else('')"/>
            <xsl:variable name="ddb" select="if(@ddb)then(string(@ddb))else('')"/>
            <xsl:variable name="ddbReprint" select="if(@ddb-reprint)then(string(@ddb-reprint))else('')"/>
            <xsl:call-template name="papy:csvLine">
                <xsl:with-param name="data" select="($ddb, $ddbReprint, $hgv, $tm)"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>