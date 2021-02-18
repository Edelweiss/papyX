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

<xsl:variable name="apo" select="'&#x22;'"/>
<xsl:variable name="gt" select="'&#x3e;'"/>
<xsl:variable name="lt" select="'&#x3c;'"/>
<xsl:variable name="IDNOS" select="document('data/IDNOS.xml')"/>

<xsl:template name="papy:csvLine">
    <xsl:param name="data"/>
      <xsl:for-each select="$data">
        <xsl:value-of select="$apo"/><xsl:value-of select="papy:makeCsvSafe(.)"/><xsl:value-of select="$apo"/><xsl:text>,</xsl:text>
      </xsl:for-each><xsl:text>
</xsl:text>
    </xsl:template>

    <xsl:function name="papy:makeCsvSafe">
      <xsl:param name="in"/>
      <xsl:value-of select="replace($in, $apo, concat($apo, $apo))"/>
    </xsl:function>

  <xsl:template name="IDNOS">
    <xsl:param name="idp.data"/>
    <xsl:param name="reference" select="'HGV'"/><!-- HGV or DDB -->
    <xsl:variable name="folder" select="if($reference = 'DDB')then('DDB_EpiDoc_XML')else('HGV_meta_EpiDoc')"/>
    <xsl:variable name="idnoTypeHgv" select="if($reference = 'DDB')then('HGV')else('filename')"/>
      <list>
          <xsl:for-each select="collection(concat($idp.data, '/', $folder, '?select=*.xml;recurse=yes'))[not(.//tei:ref[@type='reprint-in'])]">
              <xsl:variable name="ddbList" select=".//tei:idno[@type='ddb-hybrid']/string(.)"/>
              <xsl:variable name="hgvList" select="tokenize(string-join(.//tei:idno[@type=$idnoTypeHgv], ' '), ' ')"/>

              <xsl:for-each select="$hgvList">
                  <xsl:variable name="hgv" select="string(.)"/>
                  <xsl:for-each select="$ddbList">
                      <xsl:variable name="ddb" select="string(.)"/>
                      <xsl:message select="concat('____', $ddb, ' / ', $hgv)"/>
                      <item ddb="{$ddb}" hgv="{$hgv}" tm="{replace($hgv, '[^\d]+', '')}"/>
                  </xsl:for-each>
              </xsl:for-each>
          </xsl:for-each>
          <xsl:for-each select="collection(concat($idp.data, '/DCLP?select=*.xml;recurse=yes'))">
            <xsl:variable name="dclp" select="string(.//tei:idno[@type='dclp-hybrid'][1])"/>
            <xsl:variable name="tm" select="string(.//tei:idno[@type='TM'])"/>
            <xsl:message select="concat('____', $dclp, ' / ', $tm)"/>
            <item dclp="{$dclp}" tm="{$tm}"/>
          </xsl:for-each>
        </list>
    </xsl:template>

    <xsl:function name="papy:folder1000">
      <xsl:param name="tmlike"/>
      <xsl:value-of select="ceiling(number(replace($tmlike, '[^\d]', '')) div 1000)"/>
    </xsl:function>

    <xsl:function name="papy:dclpFilePath">
      <xsl:param name="tm"/>
      <xsl:value-of select="concat('DCLP/', papy:folder1000($tm), '/', normalize-space($tm), '.xml')"/>
    </xsl:function>

    <xsl:function name="papy:hgvFilePath">
      <xsl:param name="hgv"/>
      <xsl:value-of select="concat('HGV_meta_EpiDoc/HGV', papy:folder1000($hgv), '/', normalize-space($hgv), '.xml')"/>
    </xsl:function>

    <xsl:function name="papy:range">
      <xsl:param name="from" as="xs:integer"/>
      <xsl:param name="to" as="xs:integer"/>
      <xsl:if test="$to &gt;= $from">
        <xsl:copy-of select="papy:rangeR($from, $to)"/>
      </xsl:if>
    </xsl:function>

    <xsl:function name="papy:rangeR">
      <xsl:param name="from" as="xs:integer"/>
      <xsl:param name="to" as="xs:integer"/>
      <xsl:choose>
        <xsl:when test="$from &lt; $to">
          <xsl:copy-of select="($from, papy:rangeR($from + 1, $to))"/>
        </xsl:when>
        <xsl:when test="$from = $to">
          <xsl:copy-of select="$from"/>
        </xsl:when>
      </xsl:choose>
    </xsl:function>
    
    <xsl:template match="@*|node()" mode="copy">
      <xsl:param name="data"/>
      <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="copy">
          <xsl:with-param name="data" select="$data"/>
        </xsl:apply-templates>
      </xsl:copy>
    </xsl:template>
</xsl:stylesheet>