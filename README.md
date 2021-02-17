# papyX
xslt scrips and xqueries

## update images

```
    java -Xms1024m -Xmx2536m net.sf.saxon.Transform -o:../data/updateImageUrls.csv -it:UPDATE_IMAGES -xsl:updateImageUrls.xsl DATA_FILE=../data/Gießen.fods KILL_URL=digibib.ub.uni-giessen.de > updateImageUrls 2>&1
    
    java -Xms1024m -Xmx2536m net.sf.saxon.Transform -o:../data/updateImageUrls.csv -it:UPDATE_IMAGES -xsl:updateImageUrls.xsl DATA_FILE=../data/newBritishLibraryLinks.fods KILL_URL=bl.uk/manuscripts/FullDisplay TABLE=listFromMicucci ID_COLUMN=3 URL_COLUMN=5 IDENTIFIER=TM HEADER=2
```
