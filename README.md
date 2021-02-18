# papyX
xslt scrips and xqueries

## setup

```
git clone git@github.com:Edelweiss/papyX.git
cd papyX/
ln -s ~/path/to/idp.data
mkdir data
```

## scripts

### helper

```
<xsl:include href="helper.xsl" />
```

#### hgv and dclp file names

```
papy:folder1000(TM or HGV)
papy:dclpFilePath(TM number)
papy:hgvFilePath(HGV id)
```

#### idp.data idnos

```
<xsl:template name="GET_IDNOS">
    <xsl:call-template name="IDNOS">
        <xsl:with-param name="idp.data" select="'../idp.data/papyri/master'"/>
        <xsl:with-param name="reference" select="'HGV'"/>
    </xsl:call-template>
</xsl:template>
```

#### identity transformation

```
<xsl:result-document href="../data/out.xml" method="xml" media-type="text/xml" indent="yes">
    <xsl:apply-templates select="$epiDoc" mode="copy"/>
</xsl:result-document>
```

#### csv

```
<xsl:call-template name="papy:csvLine">
    <xsl:with-param name="data" select="('string', 1, $variable)"/>
</xsl:call-template>
```

#### range

```
papy:range($from, $to)
```

### update images

| Parameter         | Description | Example  |
| ----------------- |:-------------:| -----:|
| **DATA_FILE**     | FODS document containing TM number or HGV number and the corresponding image urls | *../data/imageUrls.fods* or *../data/Gießen.fods* |
| **TABLE**         | name of the table or tab which contains the image urls | *Tabelle 1* or *listFromMicucci* |
| **ID_COLUMN**     | number of the column containing the id (i.e. HGV or TM numbers) | *1* |
| **URL_COLUMN**    | number of the column containing the image urls (i.e. the http or https links) | *4* |
| **IDENTIFIER**    | whether id represents HGV or TM number | *HGV* or *TM* |
| **HEADER**        | number of header lines in the input document | *0*, *1*, *2* |
| **KILL_URL**      | all figure graphic urls containing this string will be dropped during id transformation | *http* or *bl.uk.manuscript* |

sample commands to run script

```
java -Xms1024m -Xmx2536m net.sf.saxon.Transform -o:../data/updateImageUrls.csv -it:UPDATE_IMAGES -xsl:updateImageUrls.xsl DATA_FILE=../data/Gießen.fods KILL_URL=digibib.ub.uni-giessen.de > updateImageUrls 2>&1
    
java -Xms1024m -Xmx2536m net.sf.saxon.Transform -o:../data/updateImageUrls.csv -it:UPDATE_IMAGES -xsl:updateImageUrls.xsl DATA_FILE=../data/newBritishLibraryLinks.fods KILL_URL=bl.uk/manuscripts/FullDisplay TABLE=listFromMicucci ID_COLUMN=3 URL_COLUMN=5 IDENTIFIER=TM HEADER=2
```
