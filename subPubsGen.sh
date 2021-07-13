# requires the following arguments:
# $1: location of the base .bib file to be used for generating the publication list
# $2: location of the reference format to be used for generating references
# $3: the full URL to the page that will house the bibtex for each entry with escape characters for forward slashes
# $4: project tag as it appears in the Projects field in the source .bib file, used to identify which publications to include and to specify the anchor tag in the resulting HTML
# $5: section header title as it is to appear (usually requires enclosing in quotation marks to ensure spaces appear)
# $6: should be present if this is the LAST sub entry, otherwise not present, determines whether the bib2html trailer is cleaned up or deleted (intermediate ones are deleted)

# cleanup and filter the base .bib file and setup temporary files
genSubBib="bib2bib -c 'Projects : \""
genSubBib+=$3
genSubBib+="\"' --remove Address --remove Location --remove Publisher --remove url --remove Issn --remove Isbn --remove Date-Added --remove Date-Modified --remove Bdsk-Url-1 --remove Bdsk-Url-2 --remove Bdsk-File-1 -ob subPubsTemp.bib -oc subPubsTemp-cites "
genSubBib+=$1

echo $genSubBib
eval $genSubBib

# generate HTML
#genSubHTML="bibtex2html -style "
genSubHTML="bibtex2html "
#genSubHTML+=$2
genSubHTML+=" --macros-from macros.tex -d -nodoc -r -nokeywords -nf Authorizer \"full text via authorizer\" -nf Local-Full-Text \"full text\"  -nf Local-Poster \"poster\" -citefile subPubsTemp-cites subPubsTemp.bib"

echo $genSubHTML
eval $genSubHTML

sed -i.bak 's/>DOI</>doi</g' subPubsTemp.html

replaceBibLink="sed -i.bak 's/subPubsTemp_bib.html/"
replaceBibLink+=$2
replaceBibLink+="/g' subPubsTemp.html"

echo $replaceBibLink
eval $replaceBibLink

tr -d '\r\n' < subPubsTemp.html > subPubsTemp2.html 

# check to see if this is the last one and should have the final line
if [ $# -eq 6 ]; then
	echo "cleanup"
	sed -f cleanup.sed subPubsTemp2.html >subPubsTemp.html
else
	echo "delete"
	sed -f delete.sed subPubsTemp2.html >subPubsTemp.html
fi

headerLine="<a name=\""
headerLine+=$3
headerLine+="\">"
headerLine+="</a>"
headerLine+="<h2>"
headerLine+=$4
headerLine+="</h2>"

(echo $headerLine; cat subPubsTemp.html) > subPubsTemp2.html

rm subPubsTemp_bib.html
rm subPubsTemp.html.bak
rm subPubsTemp.html
#rm subPubsTemp2.html

filename=$3
filename+="SubPubs.html"

mv subPubsTemp2.html $filename
rm subPubsTemp-cites
rm subPubsTemp.bib

#cat $filename

#value=`cat subPubsTemp.html`
#echo $value
