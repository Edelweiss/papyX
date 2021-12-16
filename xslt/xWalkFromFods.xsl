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
        java -Xms512m -Xmx1536m net.sf.saxon.Transform -s:data/louvreImages.fods -o:data/louvreImages.xml -it:ADD_IMAGES -xsl:xslt/xWalkFromFods.xsl

    Lookup-Formel für Goolge Sheets
        =ARRAYFORMULA(IFNA(VLOOKUP(B2:B,xWalk!$A$1:$A,1,false),""))
    -->

  <xsl:output method="xml" media-type="text/xml" />
  <xsl:include href="helper.xsl" />

  <xsl:param name="TABLE_NAME" select="'links_TM_nos'"/>
  <xsl:param name="IMAGE_KEY" select="'Louvre image link'"/>
  <xsl:param name="HEADER_KEY" select="'TM_no3'"/>
  <xsl:param name="HEADER_LINE" select="1"/>
  <xsl:param name="DATA_LINE" select="2"/>

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
    <!-- HGV -->
    <xsl:variable name="hgv" select="$IDNOS//tei:item[@tm=$id][@hgv]/@hgv"/>
    <xsl:for-each select="$hgv">
      <xsl:variable name="in" select="concat('../idp.data/papyri/master/', papy:hgvFilePath(.))"/>
      <xsl:variable name="out" select="replace($in, 'master', 'xwalk')"/>
      <xsl:result-document href="{$out}" method="xml" media-type="text/xml" indent="yes">
        <xsl:apply-templates select="doc($in)" mode="copy">
          <xsl:with-param name="data" select="$data"/>
        </xsl:apply-templates>
      </xsl:result-document>
      <xsl:message select="concat($id, '/', .)"/>
    </xsl:for-each>
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
      <xsl:message select="concat('_____ ', $tm, '/', .)"/>
    </xsl:for-each>
  </xsl:template>

  <!-- HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV HGV -->

  <!--div type="figure">
    <p>
      <figure>
        <graphic url="http://www.ville-ge.ch/musinfo/imageZoom/?iip=bgeiip/papyrus/pgen181a-1ri.ptif"/>
      </figure>
      <figure>
        <graphic url="https://archives.bge-geneve.ch/ark:/17786/vtae3bfef9dc023d072"/>
      </figure>
    </p>
  </div-->

  <xsl:template match="tei:body[not(tei:div[@type='figure'])]" mode="copy">
    <xsl:param name="data"/>
    <xsl:copy>
      <xsl:for-each select="@*|node()">
        <xsl:apply-templates select="." mode="copy"/>
      </xsl:for-each>
      <div type="figure">
        <p>
          <xsl:call-template name="hgvImage">
            <xsl:with-param name="data" select="$data"/>
          </xsl:call-template>
        </p>
      </div>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:div[@type='figure']/tei:p" mode="copy">
    <xsl:param name="data"/>
    <xsl:copy>
      <xsl:for-each select="tei:figure">
        <xsl:message select="$data//tei:cell[@name=$IMAGE_KEY]/string(.)"></xsl:message>
        <xsl:if test="not(tei:graphic/@url = $data//tei:cell[@name=$IMAGE_KEY]/string(.))">
          <xsl:apply-templates select="." mode="copy"/>
        </xsl:if>
      </xsl:for-each>
      <xsl:call-template name="hgvImage">
        <xsl:with-param name="data" select="$data"/>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="hgvImage">
    <xsl:param name="data"/>
    <xsl:for-each select="$data">
      <xsl:variable name="row" select="."/>
      <xsl:variable name="firstLink" select="$row//tei:cell[@name=$IMAGE_KEY]"/>
      <xsl:for-each select="($firstLink, $firstLink/following-sibling::tei:cell[matches(., '^https?://.+\..+$')])">
        <figure>
          <graphic url="{.}"/>
        </figure>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <!-- DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP DCLP -->

   <!--div type="bibliography" subtype="illustrations">
      <listBibl>
         <bibl type="printed">P.Gen. 3, pl.5</bibl>
         <bibl type="printed">Proceedings 20th Congress, pl.28</bibl>
         <bibl type="online">
            <ptr target="http://www.ville-ge.ch/fcgi-bin/fcgi-axn?launchpad&amp;/home/minfo/bge/papyrus/pgen432-vi.axs&amp;550&amp;550"/>
         </bibl>
         <bibl type="online">
            <ptr target="https://archives.bge-geneve.ch/ark:/17786/vtab44b3b169c5ea7a5"/>
         </bibl>
      </listBibl>
   </div-->

  <xsl:template match="tei:body[not(tei:div[@type='bibliography'][@subtype='illustrations']/tei:listBibl)]" mode="copy_dclp">
      <xsl:param name="data"/>
      <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="copy_dclp"/>
        <div type="bibliography" subtype="illustrations">
          <listBibl>
           <xsl:call-template name="dclpImage">
             <xsl:with-param name="data" select="$data"/>
           </xsl:call-template>
          </listBibl>
        </div>
      </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:div[@type='bibliography'][@subtype='illustrations']/tei:listBibl" mode="copy_dclp">
    <xsl:param name="data"/>
    <xsl:copy>
      <xsl:for-each select="tei:bibl[@type='printed']">
        <xsl:apply-templates select="." mode="copy_dclp"/>
      </xsl:for-each>
      <xsl:for-each select="tei:bibl[@type='online']">
        <xsl:if test="not(tei:ptr/@target = $data//tei:cell[@name=$IMAGE_KEY]/string(.))">
          <xsl:apply-templates select="." mode="copy_dclp"/>
        </xsl:if>
      </xsl:for-each>
      <xsl:call-template name="dclpImage">
        <xsl:with-param name="data" select="$data"/>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="dclpImage">
    <xsl:param name="data"/>
    <xsl:for-each select="$data">
      <xsl:variable name="row" select="."/>
      <xsl:variable name="firstLink" select="$row//tei:cell[@name=$IMAGE_KEY]"/>
      <xsl:for-each select="($firstLink, $firstLink/following-sibling::tei:cell[matches(., '^https?://.+\..+$')])">
       <bibl type="online">
           <ptr target="{.}"/>
       </bibl>
      </xsl:for-each>
    </xsl:for-each>
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