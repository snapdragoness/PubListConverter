# requires the following arguments:
# $1: location of the base .bib file to be used for generating the publication list
# $2: location of the reference format to be used for generating references
# $3: the full URL to the page that will house the bibtex for each entry with escape characters for forward slashes
# $4: any filter conditions for the source BibTeX (e.g., an author name) in quotes with escape characters for quotes that are part of the condition; see https://www.lri.fr/~filliatr/bibtex2html/doc/manual.html for details; to use the whole file, use ""
# remaining optional arguments go in pairs, the first is a Project tag the second is the human-readable header for the resulting HTML
# for each pair of remaining arguments, a header will be created that contains the subset of bibliographic entries that match the Project tag

# cleanup the base .bib file and setup temporary files
genWholeBib="bib2bib"
if [ ! -z "$3" ]
then
	genWholeBib+=" -c "
	genWholeBib+=$3
fi
genWholeBib+=" --remove Address --remove Location --remove Publisher --remove url --remove Issn --remove Isbn --remove Date-Added --remove Date-Modified --remove Bdsk-Url-1 --remove Bdsk-Url-2 --remove Bdsk-File-1 -ob "
genWholeBib+="mainPubs.bib"
genWholeBib+=" -oc mainPubs-cites "
genWholeBib+=$1

echo $genWholeBib
eval $genWholeBib

# generate HTML
#genWholeHTML="bibtex2html -style "
genWholeHTML="bibtex2html "
#genWholeHTML+=$2
genWholeHTML+=" --macros-from macros.tex -d -nodoc -r -nokeywords -t Publications -noabstract -nf Authorizer \"full text via authorizer\" -nf Local-Full-Text \"full text\"  -nf Local-Poster \"poster\" -citefile mainPubs-cites mainPubs.bib"

echo $genWholeHTML
eval $genWholeHTML

sed -i.bak 's/>DOI</>doi</g' mainPubs.html

replaceBibLink="sed -i.bak 's/mainPubs_bib.html/"
replaceBibLink+=$2
replaceBibLink+="/g' mainPubs.html"

echo $replaceBibLink
eval $replaceBibLink

tr -d '\r\n' < mainPubs.html > mainPubs-alt.html 

sed -f delete.sed mainPubs-alt.html >mainPubs.html

genBibPage="bib2bib --remove authorizer --remove Local-Full-Text --remove Local-Poster --remove Date-Added --remove Date-Modified --remove Bdsk-Url-1 --remove Bdsk-Url-2 --remove Authorizer --remove Bdsk-File-1 -ob mainPubs-bib.bib"
genBibPage+=$1

bibtex2html -style $2 --macros-from macros.tex -d -nodoc -r -nokeywords mainPubs-bib.bib 

sed -e '1,8d' -i '' mainPubs_bib.html

i="4"
while [ "$i" -lt "$#" ]
do
	subPubCmd="./subPubsGen.sh \""
	subPubCmd+=$1
	subPubCmd+="\" \""
	#subPubCmd+=$2
	#subPubCmd+="\" \""
	subPubCmd+=$2
	subPubCmd+="\" "	
	subPubCmd+=${!i}
	filename=${!i}
	subPubCmd+=" \""
	i=$[$i+1]
	subPubCmd+=${!i}
	subPubCmd+="\""
	i=$[$i+1]
	
	if [ "$i" -gt "$#" ] 
	then
		subPubCmd+=" 1"
	fi
	
	echo $subPubCmd
	eval $subPubCmd
	
	filename+="SubPubs.html"
	
	echo $filename
	
	cat $filename >> mainPubs.html
done

# cleanup
#rm mainPubs_bib.html
#rm mainPubs.html
#mv mainPubs-alt.html mainPubs.html
rm mainPubs-cites
rm mainPubs.bib
rm mainPubs.html.bak
rm mainPubs-alt.html

#rm mainPubs-bib.bib
#rm mainPubs.html.bak
#mv mainPubs-bib_bib.html mainPubs_bib.html
#rm mainPubs.html
#mv mainPubs-alt.html mainPubs.html

