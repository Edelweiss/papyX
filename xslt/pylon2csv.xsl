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
    java -Xms512m -Xmx1536m net.sf.saxon.Transform -o:data/pylon2csv.csv -it:PYLONxCSV  -xsl:xslt/pylon2csv.xsl SOURCE=97060 COMPILATION_ID=33
    -->

    <xsl:include href="helper.xsl"/>
    <xsl:output method="text" media-type="text/csv" />

    <xsl:param name="IDP-DATA_READ"  select="'../idp.data/papyri/master'"/>
    <xsl:param name="IDP-DATA_WRITE" select="'../idp.data/papyri/xwalk'"/>
    <xsl:param name="PYLON" select="doc('../data/pylon.xml')"/>
    <xsl:param name="REGISTER" select="document('../data/BEEHIVE_REGISTER.xml')"/>
    <xsl:param name="EDITION" select="doc('../data/BEEHIVE_EDITION.xml')"/>
    <xsl:param name="CREATOR" select="'pylon3'"/>
    <xsl:param name="SOURCE" select="97060"/>
    <xsl:param name="COMPILATION_ID" select="33"/>

    <xsl:template name="PYLONxCSV">
        <xsl:call-template name="papy:csvLine">
            <xsl:with-param name="data" select="('lfd', 'compilation_id', 'compilation_index', 'register_id', 'ddb', 'dclp', 'edition_id', 'edition', 'text', 'position', 'description', 'source', 'creator')"/>
        </xsl:call-template>
        <xsl:for-each select="$PYLON//tei:div[@type = 'section'][normalize-space(tei:head) = ('DDbDP', 'DCLP')]//tei:row">
            <xsl:variable name="ddb" select=".//tei:ref[contains(@target, '://papyri.info/ddbdp')]/replace(@target, 'https?://papyri.info/ddbdp/', '')"/>
            <xsl:variable name="dclp" select=".//tei:ref[contains(@target, '://papyri.info/dclp')]/replace(@target, 'https?://papyri.info/dclp/', '')"/>
            <xsl:variable name="edition">
                <xsl:choose>
                    <xsl:when test="$ddb">
                        <xsl:value-of select="string(.//tei:ref[contains(@target, '://papyri.info/')])"/>
                    </xsl:when>
                    <xsl:when test="$dclp">
                        <xsl:choose>
                            <xsl:when test="starts-with(string(.//tei:cell[3]), '(')">
                                <xsl:value-of select="replace(string(.//tei:cell[3]), '^\(([^)]+)\).+$', '$1')"/>
                            </xsl:when>
                            <xsl:otherwise><xsl:text>Trismegistos</xsl:text></xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>

            <xsl:variable name="text" select="if($edition = 'Trismegistos')then '' else replace($edition, '^.+ ([^ ]+)$', '$1')"/>
            <xsl:variable name="edition" select="replace($edition, '^(.+) [^ ]+$', '$1')"/>

            <xsl:variable name="beehiveEditionId" select="$EDITION//edition[@title = $edition]/@id"/>
            <xsl:variable name="beehiveEditionTitle" select="$EDITION//edition[@title = $edition]/@title"/>

            <xsl:variable name="beehiveRegisterId">
                <xsl:choose>
                    <xsl:when test="$ddb">
                        <xsl:value-of select="$REGISTER//register[@ddb = $ddb]/@id"/>
                    </xsl:when>
                    <xsl:when test="$dclp">
                        <xsl:value-of select="$REGISTER//register[@tm = $dclp]/@id"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>

            <xsl:variable name="position" select="string(.//tei:cell[2])"/>
            <xsl:variable name="description" select="string(.//tei:cell[3])"/>
            <xsl:variable name="compilationIndex" select="@n"/>

            <xsl:message select="concat($compilationIndex, '____', $ddb, '/', $dclp, ' (', $beehiveRegisterId,'): ', $edition, ' (', $beehiveEditionId, ' - ', $beehiveEditionTitle, ') ', $text, ' ', $position)"></xsl:message>
            <xsl:call-template name="papy:csvLine">
                <xsl:with-param name="data" select="(position(), $COMPILATION_ID, $compilationIndex, $beehiveRegisterId, if($ddb)then $ddb else '', if($dclp)then $dclp else '', if($beehiveEditionId)then $beehiveEditionId else '', $edition, $text, $position, $description, $SOURCE, $CREATOR)"/>
            </xsl:call-template>
        </xsl:for-each>

    </xsl:template>

</xsl:stylesheet>