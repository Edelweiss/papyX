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
        java -Xms512m -Xmx1536m net.sf.saxon.Transform -o:data/007_image_urls.xml -it:GET_INFO  -xsl:xslt/007_getInfoFromHttpHtml.xsl
    -->

    <xsl:include href="helper.xsl"/>
    <!--xsl:output method="text" media-type="text/csv" /-->
    <xsl:output method="xml" media-type="text/xml" indent="yes" />

    <xsl:param name="IDP-DATA_READ"  select="'../idp.data/papyri/master'"/>
    <xsl:param name="IDP-DATA_WRITE" select="'../idp.data/papyri/xwalk'"/>
    <xsl:variable name="HARVEST_MOON">
        <list>
            <item>https://digicoll.lib.berkeley.edu/search?ln=en&amp;p=apis1_1</item>
            <item>https://digicoll.lib.berkeley.edu/search?ln=en&amp;p=apis1_11512</item>
            <item>https://digicoll.lib.berkeley.edu/search?ln=en&amp;p=apis1_1154</item>
        </list>
    </xsl:variable>

    <xsl:template name="GET_INFO">
        <list>
            <xsl:for-each select="$HARVEST_MOON//tei:item/string(.)">
                <xsl:variable name="apis" select="replace(., '^http.+p=', '')"/>
                <!--xsl:message select="concat($apis, ' - - - - - ', .)"></xsl:message-->
                <xsl:variable name="records">
                    <list>
                        <xsl:analyze-string select="unparsed-text(.)" regex="/record/\d+">
                            <xsl:matching-substring>
                                <item><xsl:value-of select="."/></item>
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </list>
                </xsl:variable>
                <xsl:variable name="recordsUnique">
                    <list>
                        <xsl:for-each-group select="$records//tei:item" group-by="string(.)">
                            <item><xsl:value-of select="concat('https://digicoll.lib.berkeley.edu', current-grouping-key())"/></item>
                        </xsl:for-each-group>
                    </list>
                </xsl:variable>
                <xsl:message select="concat($apis, ',', count($recordsUnique//tei:item), ',', string-join($recordsUnique//tei:item, '|'))"/>
            </xsl:for-each>
        </list>
    </xsl:template>

</xsl:stylesheet>