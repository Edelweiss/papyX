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
    java -Xms512m -Xmx1536m net.sf.saxon.Transform -o:data/GEO.xml -it:GET_GEO -xsl:xslt/getGeo.xsl > getGeo 2>&1
    java -Xms512m -Xmx1536m net.sf.saxon.Transform -o:data/GEO.html -it:GET_GEO_HTML -xsl:xslt/getGeo.xsl

    java -Xms512m -Xmx1536m net.sf.saxon.Transform -o:data/GEO.xml -it:GET_GEO -xsl:xslt/getGeo.xsl && java -Xms512m -Xmx1536m net.sf.saxon.Transform -o:data/GEO.html -it:GET_GEO_HTML -xsl:xslt/getGeo.xsl
-->

<xsl:output method="xml" media-type="text/xml" indent="yes" />
<xsl:include href="helper.xsl" />

<xsl:template name="GET_GEO">
    <xsl:call-template name="GEO">
        <xsl:with-param name="idp.data" select="'../idp.data/papyri/master'"/>
    </xsl:call-template>
</xsl:template>

<xsl:template name="GET_GEO_HTML">

    <html>
        <head>
            <title>HGV Geo</title>
            <meta name="description" content="all places from the HGV meta data corpus"/>
            <meta name="keywords" content="geo hgv"/>
            <style>
                table, tr, th, td {
                    border-collapse: collapse;
                    border-width: 1px;
                    border-style: solid;
                    border-color: grey;
                }
                td {
                    padding: 2px;
                }
                td.number, td.count {
                    text-align: right;
                }
            </style>
        </head>
        <body>
            <h1>Regions</h1>
            <ul>
                <xsl:for-each-group select="$GEO//tei:item[tei:geo[@type='region']]" group-by="string((./tei:geo[@type='region'])[1])">
                    <xsl:sort select="./tei:geo[@type='region']"/>
                    <li><xsl:value-of select="current-grouping-key()"/></li>
                </xsl:for-each-group>
            </ul>

            <h1>Nomes</h1>
            Nome, <i>Province</i> (Region)
            <ul>
                <xsl:for-each-group select="$GEO//tei:item[tei:geo[@type='nome']]" group-by="(./tei:geo[@type='nome'], ./tei:geo[@type='province'], (./tei:geo[@type='region'])[1])">
                    <xsl:sort select="(./tei:geo[@type='nome'])[1]"/>
                    <li>
                        <xsl:value-of select="current-group()[1]/tei:geo[@type='nome']"/>
                        <xsl:if test="current-group()[1]/tei:geo[@type='province']">
                            <xsl:text>, </xsl:text>    
                            <i>
                            <xsl:value-of select="current-group()[1]/tei:geo[@type='province']"/>
                            </i>
                        </xsl:if>
                        <xsl:if test="current-group()[1]/tei:geo[@type='region'][1]">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="current-group()[1]/tei:geo[@type='region']"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                    </li>
                </xsl:for-each-group>
            </ul>

            <h1>Provinces</h1>
            Provinces (Region)
            <ul>
                <xsl:for-each-group select="$GEO//tei:item[tei:geo[@type='province']]" group-by="(./tei:geo[@type='province'], (./tei:geo[@type='region'])[1])">
                    <xsl:sort select="./tei:geo[@type='province']"/>
                    <li>
                        <xsl:value-of select="current-group()[1]/tei:geo[@type='province']"/>
                        <xsl:if test="current-group()[1]/tei:geo[@type='region'][1]">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="current-group()[1]/tei:geo[@type='region']"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                    </li>
                </xsl:for-each-group>
            </ul>

            <h1>Places</h1>
                <table>
                    <tr>
                        <th class="number">#</th>
                        <th class="place">place</th>
                        <th class="nome">nome</th>
                        <th class="province">province</th>
                        <th class="region">region</th>
                        <th class="count">count</th>
                    </tr>
                    <xsl:for-each select="$GEO//tei:item">
                        <tr>
                            <td class="number"><a href="#place_{position()}"><xsl:value-of select="position()"/></a></td>
                            <td class="place"><xsl:value-of select="tei:geo[@type='ancient']"/></td>
                            <td class="nome"><xsl:value-of select="tei:geo[@type='nome']"/></td>
                            <td class="province"><xsl:value-of select="tei:geo[@type='province']"/></td>
                            <td class="region"><xsl:value-of select="tei:geo[@type='region']"/></td>
                            <td class="count"><xsl:value-of select="@count"/></td>
                        </tr> 
                    </xsl:for-each>
            </table>

            <h1>Places with more than one region</h1>
            <ul>
                <xsl:for-each-group select="$GEO//tei:item[count(tei:geo[@type='region']) > 1]" group-by="string((./tei:geo[@type='region'])[1])">
                    <li>
                        <xsl:call-template name="formatPlace">
                            <xsl:with-param name="place" select="."/>
                        </xsl:call-template>
                    </li>
                </xsl:for-each-group>
            </ul>

            <h1>Places with more than one nome</h1>
            <ul>
                <xsl:for-each-group select="$GEO//tei:item[count(tei:geo[@type='nome']) > 1]" group-by="string((./tei:geo[@type='nome'])[1])">
                    <li>
                        <xsl:call-template name="formatPlace">
                            <xsl:with-param name="place" select="."/>
                        </xsl:call-template>
                    </li>
                </xsl:for-each-group>
            </ul>

            <h1>Places with more than one ancient place name</h1>
            <ul>
                <xsl:for-each-group select="$GEO//tei:item[count(tei:geo[@type='ancient']) > 1]" group-by="string((./tei:geo[@type='ancient'])[1])">
                    <li>
                        <xsl:call-template name="formatPlace">
                            <xsl:with-param name="place" select="."/>
                        </xsl:call-template>
                    </li>
                </xsl:for-each-group>
            </ul>

            <h1>Details</h1>
            <ul>
                <xsl:for-each select="$GEO//tei:item">
                    <li>
                        <a name="place_{position()}">
                            <xsl:call-template name="formatPlace">
                                <xsl:with-param name="place" select="."/>
                            </xsl:call-template>
                        </a>
                        <xsl:text> [number of appearances: </xsl:text>
                        <xsl:value-of select="@count"/>
                        <xsl:text>]</xsl:text>
                        <ul>
                            <xsl:for-each select="./tei:geo">
                            <li>
                                <xsl:value-of select="@type"/>
                                <xsl:text>: </xsl:text>
                                <xsl:value-of select="."/>
                                <xsl:if test="string(@ref)">
                                    <ul>
                                        <xsl:for-each select="tokenize(@ref, ' ')">
                                            <li><a href="{.}"><xsl:value-of select="." /></a></li>
                                        </xsl:for-each>
                                    </ul>
                                </xsl:if>
                            </li>
                            </xsl:for-each>
                        </ul>
                        <p>
                            <xsl:for-each select="tokenize(@hgv, ' ')">
                                <a href="https://papyri.info/hgv/{.}"><xsl:value-of select="." /></a>
                            </xsl:for-each>
                        </p>
                    </li> 
                </xsl:for-each>
            </ul>
        </body>
    </html>

</xsl:template>

<xsl:template name="formatPlace">
    <xsl:param name="place"/>
    <xsl:if test="string(string-join($place/tei:geo[@type='ancient'], ' / '))">
        <b><xsl:value-of select="string-join($place/tei:geo[@type='ancient'], ' / ')"/></b>
    </xsl:if>
    <xsl:if test="$place/tei:geo[@type='nome']">
        <xsl:if test="$place/tei:geo[@type='ancient']">
            <xsl:text>, </xsl:text>    
        </xsl:if>
        <xsl:value-of select="string-join($place/tei:geo[@type='nome'], ' / ')"/>
    </xsl:if>
    <xsl:if test="$place/tei:geo[@type='province']">
        <i>
            <xsl:if test="$place/tei:geo[@type='ancient'] or $place/tei:geo[@type='nome']">
                <xsl:text>, </xsl:text>    
            </xsl:if>
            <xsl:value-of select="string-join($place/tei:geo[@type='province'], ' / ')"/>
        </i>
    </xsl:if>
    <xsl:if test="$place/tei:geo[@type='region']">
        <xsl:text> (</xsl:text>
        <xsl:value-of select="string-join($place/tei:geo[@type='region'], ' / ')"/>
        <xsl:text>)</xsl:text>
    </xsl:if>
</xsl:template>

</xsl:stylesheet>