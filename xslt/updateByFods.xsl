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
      java -Xms512m -Xmx1536m net.sf.saxon.Transform -s:data/provenance_province.fods -o:data/provenance_nome.xml -it:FODS_PROVINCE -xsl:xslt/updateByFods.xsl

      java -Xms512m -Xmx1536m net.sf.saxon.Transform -o:data/EXCLUDE.xml -it:EXCLUDE -xsl:xslt/updateByFods.xsl
      java -Xms512m -Xmx1536m net.sf.saxon.Transform -o:data/NO_NOME_NO_PROVINCE.xml -it:NO_NOME_NO_PROVINCE -xsl:xslt/updateByFods.xsl

      cd ~/projects/papyX/
      java -Xms512m -Xmx1536m net.sf.saxon.Transform -s:data/MP3.fods -o:data/MP3.xml -it:FODS -xsl:xslt/updateByFods.xsl TABLE_NAME=MP3
    -->

  <xsl:output method="xml" media-type="text/xml" />
  <xsl:include href="helper.xsl" />
  <xsl:strip-space elements="tei:p" />
  <xsl:preserve-space elements="tei:div tei:revisionDesc" />

  <xsl:param name="TABLE_NAME" select="'TM to MP3'"/>
  <xsl:param name="HEADER_KEY" select="'TM'"/>
  <xsl:param name="HEADER_LINE" select="1"/>
  <xsl:param name="DATA_LINE" select="2"/>
  <xsl:param name="IDP_DATA_READ" select="'../idp.data/papyri/master'"/>
  <xsl:param name="IDP_DATA_WRITE" select="'../idp.data/papyri/xwalk'"/>

  <xsl:template name="NO_NOME_NO_PROVINCE">
    <xsl:for-each select="collection(concat($IDP_DATA_READ, '/HGV_meta_EpiDoc/?select=*.xml;recurse=yes'))[not(.//tei:placeName[@subtype = 'nome'])][not(.//tei:placeName[@subtype = 'province'])]">
      <xsl:message select="concat('____ ', string-join(.//tei:idno[@type='ddb-hybrid'], ', '), ' (', string-join(.//tei:idno[@type='filename'], ', '), ')')"/>
      <xsl:message select="string(.//tei:origPlace)"/>

    </xsl:for-each>
    <!--
      'Antaiopolites', 'Antinoites', 'Aphroditopolites', 'Apollonopolites', 'Apollonopolites Heptakomias', 'Arsinoites', 'Athribites', 'Busirites', 'Eileithyiopolites', 'Fayūm', 'Heliopolites', 'Herakleopolites', 'Hermonthites', 'Hermopolites', 'Kabasites', 'Koptites', 'Kussites', 'Kynopolites', 'Latopolites', 'Leontopolites', 'Letopolites', 'Lykopolites', 'Memphites', 'Mendesios', 'Oasis Magna', 'Oxyrhynchites', 'Panopolites', 'Pathyrites', 'Pharbaithites', 'Prosopites', 'Theben', 'Theodosiopolites', 'Thinites' 
    -->
  </xsl:template>

  <xsl:template name="FODS">
    <xsl:variable name="fods">
      <xsl:call-template name="papy:fodsIndexData">
        <xsl:with-param name="fodsDocument" select="."/>
        <xsl:with-param name="tableName" select="$TABLE_NAME"/>
        <xsl:with-param name="dataLine" select="$DATA_LINE"/>
        <xsl:with-param name="headerKey" select="$HEADER_KEY"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:message select="$fods"/>

    <!--xsl:for-each select="collection(concat($IDP_DATA_READ, '/HGV_meta_EpiDoc/?select=*.xml;recurse=yes'))[.//tei:placeName[@subtype = 'nome'][string(.) = ('Antaiopolites', 'Antinoites', 'Aphroditopolites', 'Apollonopolites', 'Apollonopolites Heptakomias', 'Arsinoites', 'Athribites', 'Busirites', 'Eileithyiopolites', 'Fayūm', 'Heliopolites', 'Herakleopolites', 'Hermonthites', 'Hermopolites', 'Kabasites', 'Koptites', 'Kussites', 'Kynopolites', 'Latopolites', 'Leontopolites', 'Letopolites', 'Lykopolites', 'Memphites', 'Mendesios', 'Oasis Magna', 'Oxyrhynchites', 'Panopolites', 'Pathyrites', 'Pharbaithites', 'Prosopites', 'Theben', 'Theodosiopolites', 'Thinites')]]"-->
    <!--xsl:for-each select="collection(concat($IDP_DATA_READ, '/HGV_meta_EpiDoc/?select=*.xml;recurse=yes'))[.//tei:placeName[@subtype = 'nome'][string(.) = ('Bubastites, Delta', 'Gynaikopolites', 'Menelaites', 'Metelites', 'Onuphites', 'Saites', 'Sebennytes', 'Sethroites', 'Tanites', 'Tentyrites')]]">
      <xsl:message select="concat('____ ', string-join(.//tei:idno[@type='ddb-hybrid'], ', '), ' (', string-join(.//tei:placeName[@subtype = 'nome'], '|'),')')"/>
      <xsl:result-document href="{replace(base-uri(.), 'master', 'xwalk')}" method="xml" media-type="text/xml" indent="yes">
        <xsl:apply-templates mode="copy">
          <xsl:with-param name="data" select="$fods"></xsl:with-param>
        </xsl:apply-templates>
      </xsl:result-document>
    </xsl:for-each-->

    <xsl:for-each-group select="$fods//tei:row" group-by="tei:cell[@name='TM']">
      <xsl:variable name="tm" select="current-grouping-key()"/>
      <xsl:variable name="data" select="current-group()"/>
      <!--xsl:message select="$tm"/-->
      <!--xsl:message select="$data"/-->

      <xsl:variable name="mp3" select="string-join($data//tei:cell[@name='MP3'], '|')"/>
      <xsl:variable name="file" select="papy:dclpFilePath($tm)"/>
      <!--xsl:message select="($tm, ' ', $mp3, ' - - - - ', $file)"/-->
      <xsl:variable name="xml" select="document(concat($IDP_DATA_READ, '/', $file))"/>
      <!--xsl:message select="(' ↳ ', string-join($xml//tei:idno[@type='dclp-hybrid']))"/-->

      <xsl:choose>
        <xsl:when  test="$xml//tei:idno">
          <xsl:result-document href="{concat($IDP_DATA_WRITE, '/',  $file)}" method="xml" media-type="text/xml" indent="yes">
            <xsl:apply-templates mode="copy" select="$xml">
              <xsl:with-param name="data" select="$data"/>
            </xsl:apply-templates>
          </xsl:result-document>
          </xsl:when>
        <xsl:otherwise>
          <xsl:message select="concat('UNMATCHED ', $tm, ',', $mp3)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </xsl:template>

  <xsl:template match="tei:idno[@type='MP3']" mode="copy"/>

  <xsl:template match="tei:availability" mode="copy">
    <xsl:param name="data"/>
    <xsl:for-each select="$data//tei:cell[@name='MP3']">
      <idno type="MP3"><xsl:value-of select="string(.)"/></idno>
    </xsl:for-each>
    <xsl:copy-of select="."/>
  </xsl:template>

</xsl:stylesheet>