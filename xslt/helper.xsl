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
    xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
    xmlns="http://www.tei-c.org/ns/1.0">

  <xsl:variable name="apo" select="'&#x22;'"/>
  <xsl:variable name="gt" select="'&#x3e;'"/>
  <xsl:variable name="lt" select="'&#x3c;'"/>

  <!-- GEO GEO GEO GEO GEO GEO GEO GEO GEO GEO GEO GEO GEO GEO GEO GEO GEO GEO GEO GEO -->

    <xsl:variable name="GEO" select="document('../data/GEO.xml')"/>

    <xsl:template name="GEO">
      <xsl:param name="idp.data"/>
        <list>
            <xsl:for-each-group select="collection(concat($idp.data, '/HGV_meta_EpiDoc', '?select=*.xml;recurse=yes'))//tei:provenance" group-by="string(.)">
                <xsl:message select="concat(position(), ' ', normalize-space(current-grouping-key()))"></xsl:message>
                <xsl:variable name="hgv" select="string-join(current-group()/ancestor::tei:TEI//tei:idno[@type='filename'], ' ')"/>
                <item count="{count(current-group())}" hgv="{$hgv}">
                  <xsl:for-each select="current-group()[1]//tei:placeName">
                    <xsl:variable name="subtype" select="@subtype"/>
                    <xsl:variable name="ref" select="string-join(distinct-values(tokenize(normalize-space(string-join(current-group()//tei:placeName[@subtype = $subtype]/@ref, ' ')), ' ')), ' ')"/>
                    

                    <geo type="{if(string(@subtype))then(@subtype)else(@type)}" ref="{$ref}">
                      <xsl:value-of select="."/>
                    </geo>
                  </xsl:for-each>
                </item>
            </xsl:for-each-group>
          </list>
      </xsl:template>

<!-- IDNOS IDNOS IDNOS IDNOS IDNOS IDNOS IDNOS IDNOS IDNOS IDNOS IDNOS IDNOS IDNOS -->

  <xsl:variable name="IDNOS" select="document('../data/IDNOS.xml')"/>

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

<!-- CSV CSV CSV CSV CSV CSV CSV CSV CSV CSV CSV CSV CSV CSV CSV CSV CSV CSV CSV CSV -->

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

  <!-- FODS FODS FODS FODS FODS FODS FODS FODS FODS FODS FODS FODS FODS FODS FODS -->

  <xsl:template name="papy:fodsIndex">
      <xsl:param name="fodsTable" as="node()"/>
      <xsl:param name="headerLine" as="xs:integer" select="0"/>
      <xsl:param name="headerKey" as="xs:string"/>
      <xsl:variable name="header" as="xs:integer">
        <xsl:choose>
          <xsl:when test="number($headerLine)">
            <xsl:value-of select="$headerLine"/>
          </xsl:when>
          <xsl:when test="string($headerKey)">
            <xsl:value-of select="count($fodsTable//table:table-cell[normalize-space(.) = $headerKey]/ancestor::table:table-row/preceding-sibling::table:table-row) + 1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="1"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <list>
          <xsl:for-each select="$fodsTable//table:table-row[$header]/table:table-cell">
              <xsl:if test="string(.)">
                  <item column="{position() + sum(preceding-sibling::table:table-cell/@table:number-columns-repeated) - count(preceding-sibling::table:table-cell[number(@table:number-columns-repeated) &gt; 1])}" name="{normalize-space(.)}"/>
              </xsl:if>
          </xsl:for-each>
      </list>
  </xsl:template>

  <xsl:template name="papy:fodsIndexData">
      <xsl:param name="fodsDocument" as="node()"/>
      <xsl:param name="tableName" as="xs:string"/>
      <xsl:param name="dataLine" as="xs:integer"/>
      <xsl:param name="headerLine" as="xs:integer" select="0"/>
      <xsl:param name="headerKey" as="xs:string"/>

      <xsl:message select="concat('TABLE: ', $tableName, '; DATA: ', $dataLine, '; HEADER: ', $headerLine, ' (', $headerKey, ')')"/>
      <xsl:message select="'________________________________'"/>

      <xsl:variable name="fodsTable" select="$fodsDocument//table:table[@table:name=$tableName]"/>

      <xsl:variable name="index">
        <xsl:call-template name="papy:fodsIndex">
            <xsl:with-param name="fodsTable" select="$fodsTable"/>
            <xsl:with-param name="headerLine" select="$headerLine"/>
            <xsl:with-param name="headerKey" select="$headerKey"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:for-each select="$index//tei:item">
          <xsl:message select="concat(@column, '&#09;', @name)"/>
      </xsl:for-each>
      <xsl:message select="'________________________________'"/>

      <fods>
        <index>
          <xsl:copy-of select="$index"/>
        </index>
      <table>
          <xsl:for-each select="$fodsTable/table:table-row[position() &gt;= $dataLine]">
              <row>
                  <xsl:for-each select="table:table-cell">
                      <xsl:variable name="summedUpPosition" select="position() + sum(preceding-sibling::table:table-cell/@table:number-columns-repeated) - count(preceding-sibling::table:table-cell[number(@table:number-columns-repeated) &gt; 1])"/>
                      <xsl:variable name="value" select="normalize-space(.)"/>
                      <cell name="{$index//tei:item[@column = $summedUpPosition]/@name}">
                          <xsl:value-of select="$value"/>
                      </cell>
                      <xsl:if test="number(@table:number-columns-repeated) &gt; 1">
                          <xsl:for-each select="papy:range(2, @table:number-columns-repeated)">
                              <xsl:variable name="subsequent" select="position()"/>
                              <cell name="{$index//tei:item[@column = $summedUpPosition + $subsequent]/@name}">
                                  <xsl:value-of select="$value"/>
                              </cell>
                          </xsl:for-each>
                      </xsl:if>
                  </xsl:for-each>
              </row>
          </xsl:for-each>
      </table>
      </fods>
  </xsl:template>

  <!-- HGV etc. HGV etc. HGV etc. HGV etc. HGV etc. HGV etc. HGV etc. HGV etc.-->

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

  <!-- A L L G E M E I N -->

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