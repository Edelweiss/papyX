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

    <xsl:include href="helper.xsl"/>
    <xsl:output method="xml" media-type="text/xml" />

    <xsl:variable name="IDP-DATA_READ"  select="'../idp.data/papyri/master'"/>
    <xsl:variable name="IDP-DATA_WRITE" select="'../idp.data/papyri/xwalk'"/>

    <xsl:param name="DATA_FILE" select="'../data/imageUrls.fods'" as="xs:string"/>
    <xsl:param name="TABLE" select="'update image urls'" as="xs:string"/>
    <xsl:param name="ID_COLUMN" select="1" as="xs:integer"/>
    <xsl:param name="URL_COLUMN" select="2" as="xs:integer"/>
    <xsl:param name="IDENTIFIER" select="'HGV'" as="xs:string"/><!--HGV or TM -->
    <xsl:param name="HEADER" select="0" as="xs:integer"/><!-- number of header lines in the input document -->
    <xsl:param name="KILL_URL" select="'ALL_FIGURE_GRAPHIC_URLS_CONTAINING_THIS_STRING_WILL_BE_DROPPED_DURING_ID_TRANSFORMATION'"/>
    <xsl:variable name="IMAGE_URLS" select="doc($DATA_FILE)"/>

    <xsl:template name="UPDATE_IMAGES">

        <xsl:for-each-group select="$IMAGE_URLS//table:table[@table:name=$TABLE]/table:table-row[position() &gt; $HEADER][matches(normalize-space(table:table-cell[$ID_COLUMN]), '^\d+[^a-z]*$')]" group-by="normalize-space(table:table-cell[$ID_COLUMN])">
            <xsl:variable name="id" select="current-grouping-key()"/>
            <xsl:variable name="hgvList" as="item()*">
                <xsl:choose>
                    <xsl:when test="$IDENTIFIER = 'HGV'">
                        <xsl:value-of select="$id"/>
                    </xsl:when>
                    <xsl:when test="$IDENTIFIER = 'TM'">
                        <xsl:copy-of select="$IDNOS//tei:item[@tm = $id]/string(@hgv)"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>

            <xsl:choose>
                <xsl:when test="count($hgvList) &gt; 0">
                  <xsl:for-each select="$hgvList">
                      <xsl:variable name="hgv" select="string(.)"/>
                      <xsl:variable name="hgvFile" select=" papy:hgvFilePath($hgv)"/>
                      <xsl:message select="concat('____', $hgvFile)"/>
                      <xsl:result-document href="{concat($IDP-DATA_WRITE, '/', $hgvFile)}" method="xml" media-type="text/xml" indent="yes">
                          <xsl:apply-templates select="doc(concat($IDP-DATA_READ, '/', $hgvFile))" mode="copy"/>
                      </xsl:result-document>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message select="concat('WARNING: HGV NOT FOUND ', $id)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
        <xsl:message select="concat('____ input file: ', $DATA_FILE, '::', $TABLE)"/>
    </xsl:template>

    <xsl:template match="tei:div[@type='figure']/tei:p" mode="copy">
        <xsl:copy>
            <xsl:apply-templates select="tei:figure[not(contains(tei:graphic/@url, $KILL_URL))]" mode="copy"/>
            <xsl:call-template name="figure"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:body[not(tei:div[@type='figure'])]" mode="copy">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="copy"/>
            <div type="figure">
                <p>
                    <xsl:call-template name="figure"/>
                </p>
            </div>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="figure">
        <xsl:variable name="id" select="string(if($IDENTIFIER = 'HGV')then(/tei:TEI//tei:idno[@type='filename'])else(/tei:TEI//tei:idno[@type='TM']))"/>
        <xsl:variable name="urlList" select="$IMAGE_URLS//table:table[@table:name=$TABLE]/table:table-row[normalize-space(table:table-cell[$ID_COLUMN]) = $id]"/>
        <xsl:for-each select="$urlList">
            <xsl:variable name="url" select="normalize-space(table:table-cell[$URL_COLUMN])"/>
            <xsl:message select="$url"/>
            <figure>
                <graphic url="{$url}"/>
            </figure>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>