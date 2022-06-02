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
      java -Xms512m -Xmx1536m net.sf.saxon.Transform -s:data/provenance_nome.fods -o:data/provenance_nome.xml -it:FODS -xsl:xslt/updateByFods.xsl
    -->

  <xsl:output method="xml" media-type="text/xml" />
  <xsl:include href="helper.xsl" />
  <xsl:strip-space elements="tei:p" />

  <xsl:param name="TABLE_NAME" select="'nome'"/>
  <xsl:param name="HEADER_KEY" select="'nome'"/>
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
    
    <xsl:for-each select="collection(concat($IDP_DATA_READ, '/HGV_meta_EpiDoc/?select=*.xml;recurse=yes'))[.//tei:placeName[@subtype = 'nome'][string(.) = ('Antaiopolites', 'Antinoites', 'Aphroditopolites', 'Apollonopolites', 'Apollonopolites Heptakomias', 'Arsinoites', 'Athribites', 'Busirites', 'Eileithyiopolites', 'Fayūm', 'Heliopolites', 'Herakleopolites', 'Hermonthites', 'Hermopolites', 'Kabasites', 'Koptites', 'Kussites', 'Kynopolites', 'Latopolites', 'Leontopolites', 'Letopolites', 'Lykopolites', 'Memphites', 'Mendesios', 'Oasis Magna', 'Oxyrhynchites', 'Panopolites', 'Pathyrites', 'Pharbaithites', 'Prosopites', 'Theben', 'Theodosiopolites', 'Thinites')]]">
      <xsl:message select="concat('____ ', string-join(.//tei:idno[@type='ddb-hybrid'], ', '), ' (', string-join(.//tei:placeName[@subtype = 'nome'], '|'),')')"/>
      <xsl:result-document href="{replace(base-uri(.), 'master', 'xwalk')}" method="xml" media-type="text/xml" indent="yes">
        <xsl:apply-templates mode="copy">
          <xsl:with-param name="data" select="$fods"></xsl:with-param>
        </xsl:apply-templates>
      </xsl:result-document>
    </xsl:for-each>
    <!--
      'Antaiopolites', 'Antinoites', 'Aphroditopolites', 'Apollonopolites', 'Apollonopolites Heptakomias', 'Arsinoites', 'Athribites', 'Busirites', 'Eileithyiopolites', 'Fayūm', 'Heliopolites', 'Herakleopolites', 'Hermonthites', 'Hermopolites', 'Kabasites', 'Koptites', 'Kussites', 'Kynopolites', 'Latopolites', 'Leontopolites', 'Letopolites', 'Lykopolites', 'Memphites', 'Mendesios', 'Oasis Magna', 'Oxyrhynchites', 'Panopolites', 'Pathyrites', 'Pharbaithites', 'Prosopites', 'Theben', 'Theodosiopolites', 'Thinites' 
    -->
  </xsl:template>

  <xsl:template match="tei:placeName[@subtype = 'region'][string(.) = ('Egypt', 'Ägypten', 'Aegyptus')]" mode="copy"/>

  <xsl:template match="tei:placeName[@subtype = 'nome']" mode="copy">
    <xsl:param name="data"/>
    <xsl:variable name="nome" select="string(.)"/>
    <xsl:variable name="ref" select="$data//tei:row[tei:cell[@name = 'nome'][string(.) = $nome]]/tei:cell[@name = 'ref revised']"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="ref" select="$ref"/>
      <xsl:value-of select="$nome"/>
    </xsl:copy>
    <placeName type="ancient" subtype="region">Ägypten</placeName>
  </xsl:template>

</xsl:stylesheet>