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
    java -Xms512m -Xmx1536m net.sf.saxon.Transform -o:data/xpathReplacement.csv -it:APPLY_CHANGES  -xsl:xslt/xpathReplacement.xsl
node()[preceding-sibling::lb[@n='16']][following-sibling::lb[@n='17']]
    Beispiel:
    https://github.com/jcowey/P3/blob/master/app%20editorial%20XML/pylon_6_text.xml
    https://github.com/papyri/idp.data/blame/master/DDB_EpiDoc_XML/p.ross.georg/p.ross.georg.3/p.ross.georg.3.1.xml
    
    Upgrade Saxon von 9 auf 12
    alt:
    CLASSPATH=:/Users/elemmire/tools/SaxonHE9-8-0-12J/saxon9he.jar
    export CLASSPATH=$CLASSPATH:/Users/elemmire/tools/SaxonHE9-8-0-12J/saxon9he.jar
    neu
    export CLASSPATH=$CLASSPATH:/Users/elemmire/tools/SaxonHE12-5J/saxon-he-12.5.jar
    
    
    XSL:EVALUATE
    
    https://www.w3.org/TR/xslt-30/#element-evaluate
    
    DISABLE_XSL_EVALUATE
    
    siehe auch
    fn:transform()
    
    weitere Divs zur Verwirrung enstreuen:
    
    <div type="textpart"><lb n="9999"/><ab>TEST</ab></div>
    -->

    <xsl:include href="helper.xsl"/>
    <xsl:output method="text" media-type="text/csv" />

    <xsl:param name="IDP-DATA_READ"  select="'../idp.data/papyri/master'"/>
    <xsl:param name="IDP-DATA_WRITE" select="'../idp.data/papyri/xwalk'"/>
    <xsl:param name="EDITORIAL" select="doc('../data/editorial.xml')"/>
    
    <xsl:template name="APPLY_CHANGES">
        <xsl:call-template name="papy:csvLine">
            <xsl:with-param name="data" select="('lfd', 'file')"/>
        </xsl:call-template>
        <xsl:for-each select="$EDITORIAL//tei:div[@type = 'corrections']/tei:list/tei:item">
            <xsl:variable name="index" select="string(@n)"/>
            <xsl:variable name="filename" select="substring-after(tei:ref/@target, 'master/')"/>

            <xsl:message select="concat($index, '____', $filename)"></xsl:message>

            <xsl:result-document href="{concat($IDP-DATA_WRITE, '/', $filename)}" method="xml" media-type="text/xml" indent="yes">
                <xsl:apply-templates select="doc(concat($IDP-DATA_READ, '/', $filename))" mode="replace">
                    <xsl:with-param name="data" select="tei:list[@type='replacements']"/>
                </xsl:apply-templates>
            </xsl:result-document>
            
            <xsl:call-template name="papy:csvLine">
                <xsl:with-param name="data" select="($index, $filename)"/>
            </xsl:call-template>
        </xsl:for-each>

    </xsl:template>

    <xsl:template name="APPLY_CHANGES_OLD2">
        <xsl:call-template name="papy:csvLine">
            <xsl:with-param name="data" select="('lfd', 'file', 'xpath', 'container', 'lb', 'replacement')"/>
        </xsl:call-template>
        <xsl:for-each select="$EDITORIAL//tei:div[@type = 'corrections']/tei:list/tei:item">
            <xsl:variable name="index" select="string(@n)"/>
            <xsl:variable name="filename" select="substring-after(tei:ref/@target, 'master/')"/>
            
            <xsl:variable name="replacements" select="tei:list[@type='replacements']"/>

            <xsl:message select="concat($index, '____', $filename)"></xsl:message>
            <!--xsl:message select="$replacements"/-->

            <xsl:variable name="out" select="replace($filename, 'master', 'xwalk')"/>
            <xsl:result-document href="{$out}" method="xml" media-type="text/xml" indent="yes">
                <xsl:apply-templates select="doc(concat($IDP-DATA_READ, '/', $filename))" mode="replace">
                    <xsl:with-param name="data" select="$replacements"/>
                </xsl:apply-templates>
            </xsl:result-document>

            <xsl:call-template name="papy:csvLine">
                <xsl:with-param name="data" select="($index, $filename)"/>
            </xsl:call-template>
        </xsl:for-each>

    </xsl:template>
    
    <xsl:template name="APPLY_CHANGES_OLD">
        <xsl:call-template name="papy:csvLine">
            <xsl:with-param name="data" select="('lfd', 'file', 'xpath', 'container', 'lb', 'replacement')"/>
        </xsl:call-template>
        <xsl:for-each select="$EDITORIAL//tei:div[@type = 'corrections']//tei:item">
            <xsl:variable name="index" select="string(@n)"/>
            <xsl:variable name="filename" select="substring-after(substring-before(tei:ref/@target, '#'), 'master/')"/>
            <xsl:variable name="file" select="doc(concat($IDP-DATA_READ, '/', $filename))"/>
            <xsl:variable name="xpath" select="replace(substring-before(substring-after(tei:ref/@target, '#xpath('), ')'), '//', '//tei:')"/>
            <xsl:variable name="container" select="substring-before($xpath, '//tei:lb[@n')"/>
            <xsl:variable name="lb" select="replace($xpath, '^.+lb\[@n=.(\d+).\]$', '$1')"/>
            <xsl:variable name="replacement" select="tei:p[@change='replacement']/*"/>
            
            <xsl:message select="concat($index, '____', $filename, ' - - - ', $container, ' - - - - ', $lb)"></xsl:message>
            <xsl:message select="$replacement"/>
            <xsl:call-template name="papy:csvLine">
                <xsl:with-param name="data" select="($index, $filename, $xpath, $container, $lb)"/>
            </xsl:call-template>
        </xsl:for-each>
        
    </xsl:template>

    <!--xsl:template match="tei:lb" mode="replace">
        <xsl:param name="data"/>
        <xsl:variable name="container" select="substring-before(substring-after($data//tei:ref[1]/@target, '#'), '//node()')" />

        <xsl:message select="$container"/>
        <xsl:message select="$data"/>
    </xsl:template-->

    <xsl:template match="@*|node()" mode="replace">
        <xsl:param name="data"/>
        <xsl:variable name="containerXpath" select="replace(substring-before(substring-after($data/tei:item[1]/tei:ref/@target, '#'), '/node()'), '/([^/])', '/tei:$1')" />
        <xsl:variable name="start_loco_lb_number" select="replace($data/tei:item[1]/tei:ref/@target, '^.+preceding-sibling::lb\[@n=[^d](\d+)[^d]\].+$', '$1')" />
        <xsl:variable name="stop_bumper_lb_number" select="replace($data/tei:item[1]/tei:ref/@target, '^.+following-sibling::lb\[@n=[^d](\d+)[^d]\].+$', '$1')" />

        <xsl:variable name="in_container">
            <xsl:variable name="containerFromFile">
                <xsl:evaluate xpath="$containerXpath" context-item="/"/>
            </xsl:variable>
            <xsl:variable name="containerMine">
                <xsl:copy-of select=".."/>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$containerFromFile = $containerMine"><xsl:value-of select="true()"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$in_container and preceding-sibling::tei:lb[@n=$start_loco_lb_number] and following-sibling::tei:lb[@n=$stop_bumper_lb_number]">
                <xsl:message select="'- - - - - - -'"/>
                <xsl:message select="$containerXpath"/>
                <xsl:message select="$start_loco_lb_number"/>
                <xsl:message select="$stop_bumper_lb_number"/>
                <xsl:message select="$in_container"/>
            </xsl:when>
            <xsl:when test="$in_container and name(.) = 'lb' and @n = $start_loco_lb_number">
                <xsl:message select="'+ + + + + +'"/>
                <xsl:message select="$containerXpath"/>
                <xsl:message select="$start_loco_lb_number"/>
                <xsl:message select="$stop_bumper_lb_number"/>
                <xsl:message select="$in_container"/>
                <xsl:copy-of select="$data//tei:p[@change='replacement'][1]/node()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()" mode="replace">
                        <xsl:with-param name="data" select="$data"/>
                    </xsl:apply-templates>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>