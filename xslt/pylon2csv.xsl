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
    java -Xms512m -Xmx1536m net.sf.saxon.Transform -o:data/pylon2csv.csv -it:PYLONxCSV  -xsl:xslt/pylon2csv.xsl

    -->

    <xsl:include href="helper.xsl"/>
    <xsl:output method="text" media-type="text/csv" />

    <xsl:param name="IDP-DATA_READ"  select="'../idp.data/papyri/master'"/>
    <xsl:param name="IDP-DATA_WRITE" select="'../idp.data/papyri/xwalk'"/>
    <xsl:param name="PYLON" select="doc('../data/pylon.xml')"/>
    <xsl:param name="SOURCE" select="96295"/>
    <xsl:param name="CREATOR" select="'pylon2'"/>
    <xsl:param name="COMPILATION_ID" select="31"/>

    <xsl:template name="PYLONxCSV">
        <xsl:call-template name="papy:csvLine">
            <xsl:with-param name="data" select="('lfd', 'compilation_id', 'compilation_page', 'register_id', 'ddb', 'edition_id', 'edition', 'text', 'position', 'description', 'source', 'creator')"/>
        </xsl:call-template>
        <xsl:for-each select="$PYLON//tei:div[@type = 'section'][tei:head = 'DDbDP']//tei:row">
            <xsl:variable name="ddb" select=".//tei:ref[contains(@target, '://papyri.info/')]/replace(@target, 'http://papyri.info/ddbdp/', '')"/>
            <xsl:variable name="edition" select="string(.//tei:ref[contains(@target, '://papyri.info/')])"/>
            <xsl:variable name="text" select="replace($edition, '^.+ ([^ ]+)$', '$1')"/>
            <xsl:variable name="edition" select="replace($edition, '^(.+) [^ ]+$', '$1')"/>
            <xsl:variable name="position" select="string(.//tei:cell[2])"/>
            <xsl:variable name="description" select="string(.//tei:cell[3])"/>
            <xsl:variable name="compilationPage" select="0"/>
            <xsl:variable name="registerId" select="0"/>
            <xsl:variable name="editionId" select="0"/>
            <xsl:message select="concat('____', $ddb, ' / ', $edition, ' ', $text, ' ', $position)"></xsl:message>
            <xsl:call-template name="papy:csvLine">
                <xsl:with-param name="data" select="(position(), $COMPILATION_ID, $compilationPage, $registerId, $ddb, $editionId, $edition, $text, $position, $description, $SOURCE, $CREATOR)"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>