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
        java -Xms512m -Xmx1536m net.sf.saxon.Transform -o:data/IDNOS.xml -it:GET_IDNOS -xsl:xslt/getIdnos.xsl > getIdnos 2>&1

    xwalk
        java -Xms512m -Xmx1536m net.sf.saxon.Transform -s:data/oKrok_Claud_Images.fods -o:data/oKrok_Claud_Images.xml -it:FODS -xsl:xslt/xWalkFromFods.xsl > xWalkFromFods 2>&1

    -->

    <xsl:output method="xml" media-type="text/xml" />
    <xsl:include href="helper.xsl" />

    <xsl:template name="FODS">
      <xsl:variable name="fods">
        <xsl:call-template name="papy:fodsIndexData">
          <xsl:with-param name="fodsDocument" select="."/>
          <xsl:with-param name="tableName" select="'4oKrok1_oClaud1_4'"/>
          <xsl:with-param name="dataLine" select="3"/>
          <!--xsl:with-param name="headerLine" select="1"/-->
          <xsl:with-param name="headerKey" select="'TM_number'"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:for-each select="$fods//tei:row[matches(tei:cell[@name='TM_number'], '^\d+$')]">
        <xsl:variable name="data" select="."/>
        <xsl:variable name="tm" select="string(tei:cell[@name='TM_number'])"/>
        <xsl:variable name="hgv" select="$IDNOS//tei:item[@tm=$tm][@hgv]/@hgv"/>
        <xsl:variable name="dclp" select="$IDNOS//tei:item[@tm=$tm][@dclp]/@dclp"/>
        <xsl:for-each select="$dclp">
          <xsl:variable name="in" select="concat('../idp.data/papyri/master/', papy:dclpFilePath($tm))"/>
          <xsl:variable name="out" select="replace($in, 'master', 'xwalk')"/>
          <xsl:result-document href="{$out}" method="xml" media-type="text/xml" indent="yes">
            <xsl:apply-templates select="doc($in)" mode="copy">
              <xsl:with-param name="data" select="$data"/>
            </xsl:apply-templates>
          </xsl:result-document>
          <xsl:message select="concat('_____ ', $tm, '/', .)"/>
        </xsl:for-each>
      </xsl:for-each>
      <!--xsl:message select="$fods"/-->
    </xsl:template>

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

  <xsl:template match="tei:body[not(tei:div[@type='bibliography'][@subtype='illustrations']/tei:listBibl)]" mode="copy">
      <xsl:param name="data"/>
      <xsl:copy>
        <xsl:for-each select="@*|node()">
          <xsl:apply-templates select="." mode="copy"/>
        </xsl:for-each>
        <div type="bibliography" subtype="illustrations">
          <listBibl>
           <xsl:call-template name="dclpImage">
             <xsl:with-param name="data" select="$data"/>
           </xsl:call-template>
          </listBibl>
        </div>
      </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:div[@type='bibliography'][@subtype='illustrations']/tei:listBibl" mode="copy">
      <xsl:param name="data"/>
      <xsl:copy>
        <xsl:for-each select="tei:bibl">
          <xsl:apply-templates select="." mode="copy"/>
        </xsl:for-each>
         <xsl:call-template name="dclpImage">
           <xsl:with-param name="data" select="$data"/>
         </xsl:call-template>
      </xsl:copy>
  </xsl:template>

  <xsl:template name="dclpImage">
    <xsl:param name="data"/>
    <xsl:variable name="firstLink" select="$data//tei:cell[@name='nakala0']"/>
    <xsl:for-each select="($firstLink, $firstLink/following-sibling::tei:cell[string(.)])">
     <bibl type="online">
         <ptr target="{.}"/>
     </bibl>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>