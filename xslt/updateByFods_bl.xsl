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
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0">
  <!--

Daten von beehive für data/bl.fods

SELECT r.hgv, comp.short, c.compilationPage FROM
register r JOIN correction_register cr ON cr.register_id = r.id JOIN correction c ON cr.correction_id = c.id JOIN compilation comp ON c.compilation_id = comp.id
WHERE r.hgv IS NOT NULL
GROUP BY r.hgv, comp.short, c.compilationPage
ORDER BY comp.volume, r.hgv, c.compilationPage LIMIT 1000

    java -Xms512m -Xmx1536m net.sf.saxon.Transform -s:data/bl.fods -o:data/bl.xml -it:FODS -xsl:xslt/updateByFods_bl.xsl TABLE_NAME=papyX HEADER_KEY=HGV
    java -Xms512m -Xmx1536m net.sf.saxon.Transform -s:data/bl.fods -o:data/bl.xml -it:CHECK -xsl:xslt/updateByFods_bl.xsl TABLE_NAME=papyX HEADER_KEY=HGV > nichtgefunden.txt 2>&1

  -->

  <xsl:output method="xml" media-type="text/xml" />
  <xsl:include href="helper.xsl" />
  <xsl:strip-space elements="tei:p" />
  <xsl:preserve-space elements="tei:div tei:revisionDesc" />

  <xsl:param name="TABLE_NAME" select="'papyX'"/>
  <xsl:param name="HEADER_KEY" select="'HGV'"/>
  <xsl:param name="HEADER_LINE" select="1"/>
  <xsl:param name="DATA_LINE" select="2"/>
  <xsl:param name="IDP_DATA_READ" select="'../idp.data/papyri/master'"/>
  <xsl:param name="IDP_DATA_WRITE" select="'../idp.data/papyri/xwalk'"/>

  <xsl:template name="FODS">
    <xsl:variable name="fods">
      <xsl:call-template name="papy:fodsIndexData">
        <xsl:with-param name="fodsDocument" select="."/>
        <xsl:with-param name="tableName" select="$TABLE_NAME"/>
        <xsl:with-param name="dataLine" select="$DATA_LINE"/>
        <xsl:with-param name="headerKey" select="$HEADER_KEY"/>
      </xsl:call-template>
    </xsl:variable>
    <!--xsl:message select="$fods"></xsl:message-->

    <xsl:for-each-group select="$fods//tei:row" group-by="tei:cell[@name='HGV']">
      <xsl:variable name="hgv" select="current-grouping-key()" />
      <xsl:variable name="file" select="concat($IDP_DATA_READ, '/', papy:hgvFilePath($hgv))" />
      <xsl:choose>
        <xsl:when test="unparsed-text-available($file)">
          <xsl:variable name="epidoc" select="doc($file)" />
          <xsl:message select="concat($hgv, ' - ', $epidoc//tei:idno[@type='ddb-hybrid'])"></xsl:message>
          <xsl:result-document href="{replace($file, 'master', 'xwalk')}" method="xml" media-type="text/xml" indent="yes">
            <xsl:apply-templates select="$epidoc" mode="copy">
              <xsl:with-param name="data">
                <table>
                  <xsl:copy-of  select="current-group()"/>
                </table>
              </xsl:with-param>
            </xsl:apply-templates>
          </xsl:result-document>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message select="concat('WARNING: FILE NOT FOUND - ', $file)"></xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </xsl:template>
  
  <xsl:template name="CHECK">
    <xsl:variable name="fods">
      <xsl:call-template name="papy:fodsIndexData">
        <xsl:with-param name="fodsDocument" select="."/>
        <xsl:with-param name="tableName" select="$TABLE_NAME"/>
        <xsl:with-param name="dataLine" select="$DATA_LINE"/>
        <xsl:with-param name="headerKey" select="$HEADER_KEY"/>
      </xsl:call-template>
    </xsl:variable>
    <!--xsl:message select="$fods"></xsl:message-->
    
    <xsl:for-each-group select="$fods//tei:row" group-by="tei:cell[@name='HGV']">
      <xsl:variable name="hgv" select="current-grouping-key()" />
      <xsl:variable name="file" select="concat($IDP_DATA_READ, '/', papy:hgvFilePath($hgv))" />
      <xsl:choose>
        <xsl:when test="unparsed-text-available($file)">
          <xsl:variable name="epidoc" select="doc($file)" />
          <xsl:if test="$epidoc//tei:div[@type='bibliography'][@subtype='corrections']">
            <xsl:message>xx xxx xxxx xxxxxxxx xxxx xxx xx</xsl:message>
            <xsl:message select="concat($hgv, ' - ', $epidoc//tei:idno[@type='ddb-hybrid'])"></xsl:message>
            <xsl:call-template name="check-bl">
              <xsl:with-param name="blOnline" select="current-group()"/>
              <xsl:with-param name="blEpiDoc" select="$epidoc//tei:div[@type='bibliography'][@subtype='corrections']"/>
            </xsl:call-template>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message select="concat('WARNING: FILE NOT FOUND - ', $file)"></xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </xsl:template>
  
  <xsl:template name="check-bl">
    <xsl:param name="blOnline"/>
    <xsl:param name="blEpiDoc"/>
    <xsl:for-each select="$blEpiDoc//tei:bibl[@type='BL']">
      <xsl:variable name="hgv" select="$blOnline[1]/tei:cell[@name='HGV']"/>
      <xsl:variable name="volume" select="concat('BL ', normalize-space(tei:biblScope[@type='volume']))" />
      <xsl:variable name="pages" select="normalize-space(tei:biblScope[@type='pages'])" />
      <xsl:variable name="found" select="$blOnline[tei:cell[@name='BL'][normalize-space(.) = $volume]][tei:cell[@name='page'][normalize-space(.) = $pages]]"/>
      <xsl:choose>
        <xsl:when test="$found">
          <xsl:message select="concat('Gesucht/Gefunden: ', $volume, ' ', $pages)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message select="concat('NICHT GEFUNDEN: ', $hgv, '|', $volume, '|', $pages)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:div[@type='bibliography'][@subtype='corrections']" mode="copy"/>

  <xsl:template match="text()[preceding-sibling::node()[1][@type='bibliography'][@subtype='corrections']]" mode="copy"/>

  <xsl:template match="tei:body/tei:div[position() = last()]" mode="copy">
    <xsl:param name="data"/>
    <xsl:copy-of select="."/>
    <div type="bibliography" subtype="corrections">
      <head>BL-Einträge nach BL-Konkordanz</head>
      <listBibl>
        <bibl type="BL-online">
          <ptr target="https://beehive.zaw.uni-heidelberg.de/hgv/{ $data//tei:row[1]/tei:cell[@name='HGV'] }"/>
        </bibl>
        <xsl:for-each select="$data//tei:row">
          <bibl type="BL">
            <biblScope type="volume"><xsl:value-of select="substring-after(tei:cell[@name='BL'], ' ')"/></biblScope>
            <xsl:variable name="page" select="normalize-space(tei:cell[@name='page'])"/>
            <xsl:if test="$page and $page != '0' and $page != 'NULL'">
              <biblScope type="pages"><xsl:value-of select="$page"/></biblScope>
            </xsl:if>
          </bibl>
        </xsl:for-each>
      </listBibl>
    </div>
  </xsl:template>

</xsl:stylesheet>