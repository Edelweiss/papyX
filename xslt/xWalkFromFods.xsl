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
    update idnos
        java -Xms512m -Xmx1536m net.sf.saxon.Transform -o:data/IDNOS.xml -it:GET_IDNOS -xsl:xslt/getIdnos.xsl

    xwalk
        java -Xms512m -Xmx1536m net.sf.saxon.Transform -s:data/oKrok_Claud_Images.fods -o:data/louvreImages.xml -it:ADD_IMAGES -xsl:xslt/xWalkFromFods.xsl
        java -Xms512m -Xmx1536m net.sf.saxon.Transform -s:data/oOntMus_collection.fods -o:data/oOntMus_coll.xml -it:ADD_COLLECTION -xsl:xslt/xWalkFromFods.xsl

    Lookup-Formel für Goolge Sheets
        =ARRAYFORMULA(IFNA(VLOOKUP(B2:B,xWalk!$A$1:$A,1,false),""))
    -->

  <xsl:output method="xml" media-type="text/xml" />
  <xsl:include href="helper.xsl" />

  <xsl:param name="TABLE_NAME" select="'data'"/>
  <xsl:param name="IMAGE_KEY" select="'url'"/>
  <xsl:param name="HEADER_KEY" select="'TM'"/>
  <xsl:param name="HEADER_LINE" select="1"/>
  <xsl:param name="DATA_LINE" select="3"/>

  <xsl:template name="ADD_COLLECTION">
    <xsl:variable name="fods">
      <xsl:call-template name="papy:fodsIndexData">
        <xsl:with-param name="fodsDocument" select="."/>
        <xsl:with-param name="tableName" select="$TABLE_NAME"/>
        <xsl:with-param name="dataLine" select="$DATA_LINE"/>
        <xsl:with-param name="headerKey" select="$HEADER_KEY"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:for-each-group select="$fods//tei:row[matches(tei:cell[@name=$HEADER_KEY], '^\d+$')]" group-by="tei:cell[@name=$HEADER_KEY]">
      <xsl:call-template name="xwalk">
        <xsl:with-param name="id" select="current-grouping-key()"/>
        <xsl:with-param name="data" select="current-group()"/>
      </xsl:call-template>
    </xsl:for-each-group>
  </xsl:template>

  <xsl:template name="ADD_IMAGES">
    <xsl:variable name="fods">
      <xsl:call-template name="papy:fodsIndexData">
        <xsl:with-param name="fodsDocument" select="."/>
        <xsl:with-param name="tableName" select="$TABLE_NAME"/>
        <xsl:with-param name="dataLine" select="$DATA_LINE"/>
        <!--xsl:with-param name="headerLine" select="$HEADER_LINE"/-->
        <xsl:with-param name="headerKey" select="$HEADER_KEY"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:for-each-group select="$fods//tei:row[matches(tei:cell[@name=$HEADER_KEY], '^\d+$')]" group-by="tei:cell[@name=$HEADER_KEY]">
      <xsl:call-template name="xwalk">
        <xsl:with-param name="id" select="current-grouping-key()"/>
        <xsl:with-param name="data" select="current-group()"/>
      </xsl:call-template>
    </xsl:for-each-group>
  </xsl:template>

  <xsl:template name="xwalk">
    <xsl:param name="id"/>
    <xsl:param name="data"/>
    <xsl:param name="mode"/>
    <!-- HGV -->
    <!--xsl:variable name="hgv" select="$IDNOS//tei:item[@tm=$id][@hgv]/@hgv"/>
    <xsl:for-each select="$hgv">
      <xsl:variable name="in" select="concat('../idp.data/papyri/master/', papy:hgvFilePath(.))"/>
      <xsl:variable name="out" select="replace($in, 'master', 'xwalk')"/>
      <xsl:result-document href="{$out}" method="xml" media-type="text/xml" indent="yes">
        <xsl:apply-templates select="doc($in)" mode="copy">
          <xsl:with-param name="data" select="$data"/>
        </xsl:apply-templates>
      </xsl:result-document>
      <xsl:message select="concat($id, '/', .)"/>
    </xsl:for-each-->
    <!-- DCLP -->
    <xsl:variable name="dclp" select="$IDNOS//tei:item[@tm=$id][@dclp]/@dclp"/>
    <xsl:for-each select="$dclp">
      <xsl:variable name="in" select="concat('../idp.data/papyri/master/', papy:dclpFilePath($id))"/>
      <xsl:variable name="out" select="replace($in, 'master', 'xwalk')"/>
      <xsl:result-document href="{$out}" method="xml" media-type="text/xml" indent="yes">
        <xsl:apply-templates select="doc($in)" mode="copy_dclp">
          <xsl:with-param name="data" select="$data"/>
        </xsl:apply-templates>
      </xsl:result-document>
      <xsl:message select="concat('_____ ', $id, '/', .)"/>
    </xsl:for-each>
  </xsl:template>

  <!-- HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV -->


  <!--msIdentifier>
    <placeName>
      <settlement>Dublin</settlement>
    </placeName>
    <collection>Trinity College</collection>
    <idno type="invNo">Pap. Select Box 201</idno>
  </msIdentifier-->

  <xsl:template match="tei:msIdentifier" mode="copy">
    <xsl:param name="data"/>
    <xsl:copy>
      <xsl:for-each select="$data//tei:cell[@name='inv']">
        <xsl:variable name="settlement" select="'Toronto'"/>
        <xsl:variable name="collection" select="'Royal Ontario Museum'"/>
        <xsl:variable name="inventoryNumber" select="normalize-space(.)"/>
        <xsl:message select="$inventoryNumber"/>
        <placeName>
          <settlement><xsl:value-of select="$settlement"/></settlement>
        </placeName>
        <collection><xsl:value-of select="$collection"/></collection>
        <idno type="invNo"><xsl:value-of select="$inventoryNumber"/></idno>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <!-- DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP -->
  
  <xsl:template match="tei:msIdentifier" mode="copy_dclp">
    <xsl:param name="data"/>
    <xsl:copy>
      <xsl:variable name="invNo" select="string-join($data//tei:cell[@name='inv'], '; ')"/>
      <xsl:message select="$invNo"/>
      <idno type="invNo">Toronto, Royal Ontario Museum <xsl:value-of select="$invNo"/></idno>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:msDesc[not(tei:msIdentifier)]" mode="copy_dclp">
    <xsl:param name="data"/>
    <xsl:copy>
      <msIdentifier>
        <xsl:variable name="invNo" select="string-join($data//tei:cell[@name='inv'], '; ')"/>
        <xsl:message select="concat($invNo, ' - no tei:msIdentifier')"/>
        <idno type="invNo">Toronto, Royal Ontario Museum <xsl:value-of select="$invNo"/></idno>
      </msIdentifier>
      <xsl:apply-templates select="./node()" mode="copy_dclp">
        <xsl:with-param name="data" select="$data"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()" mode="copy_dclp">
    <xsl:param name="data"/>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="copy_dclp">
        <xsl:with-param name="data" select="$data"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>