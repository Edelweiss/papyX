# papyX
xslt scrips and xqueries

## helper

### hgv and dclp file names

### idp.data idnos

### identity transformation

### csv

### range

## update images

| Parameter         | Description | Example  |
| ----------------- |:-------------:| -----:|
| **DATA_FILE**     | FODS document containing TM number or HGV number and the corresponding image urls | *../data/imageUrls.fods* or *../data/Gießen.fods* |
| **TABLE**         | name of the table or tab which contains the image urls | *Tabelle 1* or *listFromMicucci* |
| **ID_COLUMN**     | number of the column containing the id (i.e. HGV or TM numbers) | *1* |
| **URL_COLUMN**    | number of the column containing the image urls (i.e. the http or https links) | *4* |
| **IDENTIFIER**    | whether id represents HGV or TM number | *HGV* or *TM* |
| **HEADER**        | number of header lines in the input document | *0*, *1*, *2* |
| **KILL_URL**      | all figure graphic urls Containing this String will be dropped during id transformation | *http* or *bl.uk.manuscript* |

sample calls to run script

```
java -Xms1024m -Xmx2536m net.sf.saxon.Transform -o:../data/updateImageUrls.csv -it:UPDATE_IMAGES -xsl:updateImageUrls.xsl DATA_FILE=../data/Gießen.fods KILL_URL=digibib.ub.uni-giessen.de > updateImageUrls 2>&1
    
java -Xms1024m -Xmx2536m net.sf.saxon.Transform -o:../data/updateImageUrls.csv -it:UPDATE_IMAGES -xsl:updateImageUrls.xsl DATA_FILE=../data/newBritishLibraryLinks.fods KILL_URL=bl.uk/manuscripts/FullDisplay TABLE=listFromMicucci ID_COLUMN=3 URL_COLUMN=5 IDENTIFIER=TM HEADER=2
```
