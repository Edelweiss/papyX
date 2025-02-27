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
GROUP BY r.hgv, comp.short, c.compilationPage
ORDER BY comp.volume, c.sort LIMIT 1000

    java -Xms512m -Xmx1536m net.sf.saxon.Transform -s:data/bl.fods -o:data/bl.xml -it:FODS -xsl:xslt/updateByFods_bl.xsl TABLE_NAME=papyX HEADER_KEY=HGV

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

    </xsl:for-each-group>
  </xsl:template>

  <xsl:template match="tei:div[@type='bibliography'][@subtype='corrections']" mode="copy"/>
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
            <xsl:if test="$page != '0'">
              <biblScope type="pages"><xsl:value-of select="$page"/></biblScope>
            </xsl:if>
          </bibl>
        </xsl:for-each>
      </listBibl>
    </div>
  </xsl:template>

</xsl:stylesheet>