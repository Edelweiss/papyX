<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:papy="Papyrillio"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:fm="http://www.filemaker.com/fmpxmlresult"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:fn="http://www.xsltfunctions.com/"
    xmlns:functx="http://www.functx.com"
    xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    >
    
    <!--
    java -Xms512m -Xmx1536m net.sf.saxon.Transform -o:data/medieval-mss.csv -it:GET_IMAGES -xsl:xslt/medievelMss_xml2csv.xsl
    -->

    <xsl:include href="helper.xsl"/>
    <xsl:output method="text" media-type="text/csv" />
<!--

    -->
    <xsl:template name="GET_IMAGES">
        <xsl:call-template name="papy:csvLine">
            <xsl:with-param name="data" select="('source', 'tm', 'url')"/>
        </xsl:call-template>
        <xsl:for-each select="('Gr_bib', 'Gr_class', 'Gr_liturg', 'Gr_misc', 'Gr_th', 'Lat_bib', 'Lat_class', 'Lat_hist', 'Lat_liturg', 'Lat_misc', 'Lat_th')">
            <xsl:variable name="subfolder" select="."/>
            <xsl:for-each select="collection(concat('/Users/elemmire/data/medieval-mss/collections/', $subfolder, '/?select=*.xml;recurse=yes'))[.//tei:bibl[@type = 'digital-facsimile'][@subtype = 'full']]">
                <xsl:variable name="digitalFacsimileList" select=".//tei:bibl[@type = 'digital-facsimile'][@subtype = 'full']/tei:ref/@target"/>
                <xsl:variable name="tmList" select=".//tei:altIdentifier[@type = 'external']/tei:idno[@type = 'TM']"/>
                <xsl:for-each select="$digitalFacsimileList">
                    <xsl:variable name="digitalFacsimile" select="string(.)"/>
                    <xsl:for-each select="$tmList">
                        <xsl:variable name="tm" select="string(.)"/>
                        <xsl:call-template name="papy:csvLine">
                            <xsl:with-param name="data" select="($subfolder, $tm, $digitalFacsimile)"/>
                        </xsl:call-template>
                      <xsl:message select="concat($tm, ': ', $digitalFacsimile)"></xsl:message>
                    </xsl:for-each>
                </xsl:for-each>
        </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>