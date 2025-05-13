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

    <!--
    java -Xms512m -Xmx1536m net.sf.saxon.Transform -o:../data/GET_INFO_FROM_EPIDOC.xml -it:GET_INFO_FROM_EPIDOC -xsl:009_getInfoFromEpiDoc.xsl > 009_getInfoFromEpiDoc 2>&1

    REPRINTS
    1.) reprint information sammeln
    java -Xms1024m -Xmx2048m net.sf.saxon.Transform -o:data/REPRINT.xml -it:COLLECT_REPRINTS -xsl:xslt/getInfoFromEpiDoc.xsl > getInfoFromEpiDoc 2>&1
    2.) reprint information in Graphen gruppieren
    java -Xms512m -Xmx1536m net.sf.saxon.Transform -o:data/REPRINT_CLUSTER.xml -s:data/REPRINT.xml -it:CLUSTER_REPRINTS -xsl:xslt/getInfoFromEpiDoc.xsl > getInfoFromEpiDoc 2>&1
    3.) Graphen für graphviz aufbereiten und einzelne Dateien rausschreiben und ein Gesamt HTML erzeugen
    java -Xms512m -Xmx1536m net.sf.saxon.Transform -o:data/REPRINT_GRAPHVIZ.xml -s:data/REPRINT_CLUSTER.xml -it:GRAPHVIZ -xsl:xslt/getInfoFromEpiDoc.xsl > getInfoFromEpiDoc 2>&1
    4.) SVGs erstellen (dot -Tsvg test.gv -o test.svg)
    find data/reprint/ -name "*.gv" -type f -exec dot -Tsvg '{}' -o '{}'.svg ";"

    Probleme:
    CPR 17A,19
    SB 10,10236
    WChr 273
    ChLA 41,1194
    PCairMasp 3,
    PCairMasp 3,
    TVindol 2,231
    PZenPestm 20

    -->

    <xsl:output method="xml" media-type="text/xml" />
    <xsl:include href="helper.xsl" />

    <xsl:template name="GET_INFO_FROM_EPIDOC">
      <xsl:call-template name="PROVENANCE"/>
      <!--xsl:call-template name="COLLECTION"/-->
      <!--xsl:call-template name="DDB_COLLECTION_NAME"/-->
    </xsl:template>

    <xsl:template name="COLLECT_REPRINTS">
      <list>
        <xsl:for-each select="collection(concat('../idp.data/papyri/xwalk/DDB_EpiDoc_XML', '?select=*.xml;recurse=yes'))[//tei:head/tei:ref[@type = ('reprint-in', 'reprint-from')]]">
            <xsl:variable name="ddb" select="//tei:idno[@type = 'ddb-hybrid']"/>
            <xsl:variable name="hgv" select="//tei:idno[@type = 'HGV']"/>
            <item ddb="{$ddb}" hgv="{$hgv}">
              <xsl:for-each select="//tei:head/tei:ref[@type = ('reprint-in', 'reprint-from')]">
                <xsl:variable name="reprintType" select="if(@type = 'reprint-in')then('in')else('from')"/>
                <xsl:variable name="tagContent" select="string(.)"/>
                <xsl:variable name="reprintInfo" select="string(@n)"/>
                <xsl:choose>
                  <xsl:when test="starts-with($reprintInfo, 'dclp:')">
                      <reprint type="{$reprintType}" ddb="$reprintInfo"><xsl:value-of select="$tagContent"/></reprint>
                  </xsl:when>
                  <xsl:when test="$reprintInfo">
                    <xsl:for-each select="tokenize($reprintInfo, '\|')">
                      <reprint type="{$reprintType}" ddb="{.}"><xsl:value-of select="$tagContent"/></reprint>
                    </xsl:for-each>
                  </xsl:when>
                  <xsl:otherwise>
                    <reprint type="{$reprintType}"><xsl:value-of select="$tagContent"/></reprint>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </item>
        </xsl:for-each>
      </list>
    </xsl:template>

    <xsl:template name="CLUSTER_REPRINTS">
      <list>
          <xsl:for-each select="//tei:item[not(tei:reprint[@type = 'from'])]">
              <xsl:variable name="cluster_start">
                <list>
                  <xsl:copy>
                    <xsl:copy-of select="@ddb|@hgv"/>
                      <xsl:attribute name="mark" select="'loose_end'"/>
                    <xsl:copy-of select="./node()"/>
                  </xsl:copy>
                </list>
              </xsl:variable>
              <xsl:message select="concat(position(), ': ____ ', @ddb)"/>
              <xsl:variable name="cluster" select="papy:cluster_r($cluster_start, /tei:list)"/>
              <xsl:message select="$cluster"/>
              <xsl:copy-of select="$cluster"/>
          </xsl:for-each>
        </list>
    </xsl:template>

    <xsl:template name="GRAPHVIZ">
      <html>
        <head>
          <meta http-equiv="Content-Type" content="text/html" charset="UTF-8"/>
          <title>Reprints</title>
          <!-- based off of https://www.cs.tut.fi/~jkorpela/www/testel.html, with additions of newer features --> 
        </head>
        <body>
          <ul>
            <xsl:for-each select="/tei:list/tei:list">
              <xsl:variable name="name" select="concat('Graph_', position())"/>
              <xsl:message select="position()"/>
              <li>
                <a href="https://papyri.info/ddbdp/{tei:item[1]/@ddb}" targe="_blank"><xsl:value-of select="tei:item[1]/@ddb"/></a>
                <br />
                <img src="reprint/{$name}.gv.svg" />
              </li>
              <!--xsl:result-document href="../data/reprint/{$name}.gv" method="text" media-type="text/plain">
                <xsl:call-template name="graphviz_graph">
                  <xsl:with-param name="list" select="."/>
                  <xsl:with-param name="name" select="$name"/>
                </xsl:call-template>
              </xsl:result-document-->
            </xsl:for-each>
          </ul>
        </body>
      </html>
    </xsl:template>

    <xsl:template name="graphviz_graph">
      <xsl:param name="list"/>
      <xsl:param name="name"/>

      digraph <xsl:value-of select="$name"/> {
        label="Reprint-Information"
        edge [fontsize = 10]

        <xsl:for-each select="$list//tei:item">
          <xsl:call-template name="graphviz_node">
            <xsl:with-param name="node" select="."/>
          </xsl:call-template>
        </xsl:for-each>

        <xsl:for-each select="$list//tei:item">
          <xsl:variable name="gNode" select="."/>

          <xsl:for-each select="$gNode//tei:reprint[@type='in']">
            <xsl:call-template name="graphviz_edge">
              <xsl:with-param name="from" select="$gNode"/>
              <xsl:with-param name="to" select="."/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:for-each>

        edge [style = "dotted" color="steelblue" arrowhead="empty" fontcolor = "lightsteelblue" labelangle = -50]

        <xsl:for-each select="$list//tei:item">
          <xsl:variable name="gNode" select="."/>
          <xsl:for-each select="$gNode//tei:reprint[@type='from']">
            <xsl:call-template name="graphviz_edge">
              <xsl:with-param name="from" select="$gNode"/>
              <xsl:with-param name="to" select="."/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:for-each>
      }
    </xsl:template>
    <xsl:template name="graphviz_node">
      <xsl:param name="node"/>
      "<xsl:value-of select="$node/@ddb"/>" [shape = <xsl:value-of select="if(not($node[tei:reprint[@type='from']]))then('rect')else(if(not($node[tei:reprint[@type='in']]))then('diamond')else('ellipse'))"/>    href = "https://papyri.info/ddbdp/<xsl:value-of select="$node/@ddb"/>" label = &lt;<b><xsl:value-of select="$node/@ddb"/></b><br/>HGV <xsl:value-of select="$node/@hgv"/>&gt; tooltip="click to view on papyri.info"]
    </xsl:template>
    <xsl:template name="graphviz_edge">
      <xsl:param name="from"/>
      <xsl:param name="to"/>
      "<xsl:value-of select="$from/@ddb"/>" -&gt; "<xsl:value-of select="$to/@ddb"/>" [label = "<xsl:value-of select="$to"/>"]
    </xsl:template>

    <xsl:template name="graphviz_">
      <xsl:param name="list"/>
      <xsl:param name="name"/>

      digraph <value-of select="$name"/> {
        label="Reprint-Information"
        edge [fontsize = 10]

        "p.oxy;44;3208" [shape = rect    href = "https://papyri.info/ddbdp/p.oxy;44;3208" label = &lt;<b>p.oxy;44;3208</b><br/>HGV 78573&gt; tooltip="click to view on papyri.info"]
        "chla;47;1420"  [shape = ellipse href = "https://papyri.info/ddbdp/chla;47;1420"  label = &lt;<b>chla;47;1420</b><br/><sub>HGV 78573</sub>&gt; tooltip="click to view on papyri.info"]
        "c.ep.lat;;10"  [shape = diamond href = "https://papyri.info/ddbdp/c.ep.lat;;10"  label = &lt;<b>c.ep.lat;;10</b><br/><sub>HGV 78573</sub>&gt; tooltip="click to view on papyri.info"]

        "p.oxy;44;3208" -&gt; "chla;47;1420" [label = "Ch.L.A. 47,1420"]
        "p.oxy;44;3208" -&gt; "c.ep.lat;;10" [label = "C.Epist.Lat. 10"]
      
        "chla;47;1420" -&gt; "c.ep.lat;;10" [label = "C.Epist.Lat. 10"]

        edge [style = "dotted" color="steelblue" arrowhead="empty" fontcolor = "lightsteelblue" labelangle = -50]
        "chla;47;1420" -&gt; "p.oxy;44;3208" [label = "P.Oxy. 44 3208"]
        "c.ep.lat;;10" -&gt; "chla;47;1420"  [label = "Ch.L.A. 47 1420"]
        "c.ep.lat;;10" -&gt; "p.oxy;44;3208" [label = "P.Oxy. 44 3208"]
      }
    </xsl:template>

    <xsl:function name="papy:cluster_r">
      <xsl:param name="list_cluster"/>
      <xsl:param name="list_complete"/>
      <xsl:variable name="loose_ends" select="$list_cluster//tei:item[@mark='loose_end']"/>
      
      <xsl:message select="$loose_ends"></xsl:message>
      
      <xsl:choose>
        <xsl:when test="count($list_cluster//tei:item) &gt; 30"><!-- terminate -->
          <list count="31" terminate="safety_net">
            <xsl:copy-of select="$list_cluster//tei:item"/>
          </list>
        </xsl:when>
        <xsl:when test="not($loose_ends)"><!-- terminate -->
          <list count="{count($list_cluster//tei:item)}" terminate="reached_end">
            <xsl:copy-of select="$list_cluster//tei:item"/>
          </list>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="next_chain_links" select="$list_complete//tei:item[@ddb = $loose_ends//tei:reprint[@type='in']/@ddb]"/>
          <xsl:choose>
            <xsl:when test="$next_chain_links">
              <xsl:variable name="new_list_cluster">
                <list>
                  <xsl:for-each select="$list_cluster//tei:item">
                    <xsl:copy>
                      <xsl:copy-of select="@ddb|@hgv"/>
                      <xsl:copy-of select="./node()"/>
                    </xsl:copy>
                  </xsl:for-each>
                  <xsl:for-each select="$next_chain_links">
                    <xsl:if test="not(@ddb = $list_cluster//tei:item/@ddb)">
                      <xsl:copy>
                        <xsl:copy-of select="@ddb|@hgv"/>
                        <xsl:if test="tei:reprint[@type='in']">
                          <xsl:attribute name="mark" select="'loose_end'"/>
                        </xsl:if>
                        <xsl:copy-of select="./node()"/>
                      </xsl:copy>
                    </xsl:if>
                  </xsl:for-each>
                </list>
              </xsl:variable>
              <xsl:message select="$new_list_cluster"></xsl:message>
              <xsl:copy-of select="papy:cluster_r($new_list_cluster, $list_complete)"/>
            </xsl:when>
            <xsl:otherwise>
              <list count="{count($list_cluster//tei:item)}" terminate="no_reprintFrom_found">
                <xsl:copy-of select="$list_cluster//tei:item"/>
              </list>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:function>

    <xsl:template name="DDB_COLLECTION_NAME">
      <list>
          <xsl:for-each-group select="collection(concat('../idp.data/papyri/xwalk/HGV_meta_EpiDoc', '?select=*.xml;recurse=yes'))//tei:idno[@type='ddb-hybrid']" group-by="string(tokenize(., ';')[1])">
              <xsl:sort select="current-grouping-key()" />
              <xsl:variable name="info" select="current-grouping-key()"/>
              <item>
                <info><xsl:value-of select="$info"/></info>
              </item>
              <xsl:message select="concat('', $info)"/>
          </xsl:for-each-group>
        </list>
    </xsl:template>

    <xsl:template name="PROVENANCE">
      <list>
          <xsl:for-each-group select="collection(concat('../idp.data/papyri/xwalk/HGV_meta_EpiDoc', '?select=*.xml;recurse=yes'))//tei:collection" group-by="string(.)">
              <xsl:sort select="string(.)" />
              <xsl:variable name="info" select="current-grouping-key()"/>
              <item>
                <info><xsl:value-of select="$info"/></info>
              </item>
              <xsl:message select="concat('', $info)"/>
          </xsl:for-each-group>
        </list>
    </xsl:template>
<!-- placeName[@type='ancient'][@subtype='region'] -->
    <xsl:template name="COLLECTION">
      <list>
          <xsl:for-each select="collection(concat('../idp.data/papyri/xwalk/HGV_meta_EpiDoc', '?select=*.xml;recurse=yes'))[count(.//tei:msIdentifier/tei:collection) &gt; 1]">
            <xsl:variable name="info" select="count(.//tei:msIdentifier/tei:collection)"/>
              <item>
                <info><xsl:value-of select="$info"/></info>
              </item>
            <xsl:message select="concat(.//tei:idno[@type='filename'], ' - ', $info, ' - ', string-join(.//tei:msIdentifier/tei:collection, '|'))"/>
          </xsl:for-each>
        </list>
    </xsl:template>

</xsl:stylesheet>