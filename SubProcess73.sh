#!/bin/bash
set -uo pipefail
IFS=$'\n\t'

function exit_on_failure() {
	local status=$1;
	local message=$2;
	local goodstatus=${3:-};
	local goodmessage=${4:-};
	if [[ $status -ne 0 && -z "$goodstatus" && $status -ne $goodstatus ]]
	then
		echo "Failure status $status:$message" 1>&2
		exit $status
	elif [[ "$status" = "$goodstatus" ]]
	then
		echo $goodmessage 1>&2
	fi
}


# rm -r $INPUTDIR $OUTPUTDIR $PROCESSDIR

mkdir -p $INPUTDIR
mkdir -p $OUTPUTDIR
mkdir -p $PROCESSDIR
# Download zip
#cp "$INPUTZIP" ${INPUTDIR}
#exit_on_failure $? "Failed to copy ${INPUTZIP} to ${INPUTDIR}"
pushd ${INPUTDIR}
# we modified what's in the zip
# unzip "$ZIPNAME"
# exit_on_failure $? "install unzip" 2 "Possible success"
popd

#cp "$DOWNLOADS"/"$VERTFILE" "${VERTICES}"
#exit_on_failure $? "Failed to copy ${DOWNLOADS}/${VERTFILE} to ${VERTICES}"
#cp "$DOWNLOADS"/"$TRIANGLEFILE" "${TRIANGLES}"
#exit_on_failure $? "Failed to copy ${DOWNLOADS}/${TRIANGLEFILE} to ${TRIANGLES}"
#cp "$DOWNLOADS"/"$WEIGHTSFILE" "${WEIGHTS}"
#exit_on_failure $? "Failed to copy ${DOWNLOADS}/${WEIGHTSFILE} to ${WEIGHTS}"
#cp "$DOWNLOADS"/"$CENTERSFILE" "${CENTERS}"
#exit_on_failure $? "Failed to copy ${DOWNLOADS}/${CENTERSFILE} to ${CENTERS}"

#
# Patch zip output
#
perl -p -i -e 's/Sacroiliac/sacroiliac/' "${WEIGHTS}"
echo "compare vertices after sorting. should see top line"
tail +2 "$VERTICES" | sort -n | diff - "$VERTICES"
exit_on_failure $? "Sorted ${VERTICES} don't match original" 1 "There may be a significant difference, but probably not"
tail +2 "$TEXTURES" | sort -n | diff - "$TEXTURES"
exit_on_failure $? "Sorted ${TEXTURES} don't match original" 1 "There may be a significant difference, but probably not"

# unix2dos "${WEIGHTS}" 

# create the mapping file of joints
cat "${EXTRAWEIGHTS}" "${WEIGHTS}" | grep '<' > "${MAPPINGFILE}"
#cat "${WEIGHTS}" | grep '<' > "${MAPPINGFILE}"
exit_on_failure $? "Couldn't create ${MAPPINGFILE} from ${WEIGHTS}"

# create weights statistics
unix2dos "${WEIGHTS}"
exit_on_failure $? "install unix2dos"
perl WeightsProcess.pl "${WEIGHTS}" > "$WEIGHTSOUT"
exit_on_failure $? "Couldn't create statistics with WeightsProcess.pl from  ${WEIGHTS} in ${WEIGHTSOUT}"
# unix2dos "$WEIGHTSOUT"

# produces sums from statistics
sed -n 's/Index .* sum: *\(.*\)=.*/\1/p' < "$WEIGHTSOUT" > "$PROCESSDIR"/sums.txt
exit_on_failure $? "Couldn't search sums in ${WEIGHTSOUT} to place in  ${PROCESSDIR}/sums.txt"
# unix2dos "$PROCESSDIR"/sums.txt

# produce expressions from statistics
sed -n 's/Index .* sum:.*=\(.*\)/\1/p' < "$WEIGHTSOUT" > "$PROCESSDIR"/expression.txt
exit_on_failure $? "Couldn't search expressions in ${WEIGHTSOUT} to place in  ${PROCESSDIR}/expression.txt"
# unix2dos "$PROCESSDIR"/expression.txt

# Compute sums
echo "WARNING!!!!!!!!!!!!! TODO This line executes sums generated from ${WEIGHTSOUT} and ${PROCESSDIR}/expression.txt (above).  Use with care!"
sed 's/^\([-0-9.\+][-0-9.\+]*\)$/print (\1); print "\n";/' < "$PROCESSDIR"/expression.txt | perl > "$PROCESSDIR"/calculated.txt
exit_on_failure $? "Error adding up sums from ${PROCESSDIR}/expression.txt to produce ${PROCESSDIR}/calculated.txt from ${PROCESSDIR}/expression.txt"
# unix2dos "$PROCESSDIR"/calculated.txt

# strip off unnecessary digits from calculations
sed -e 's/\.000$//' -e 's/\.00$//' -e 's/\.0$//' -e 's/\([1-9]\)0+$/$1/' -e 's/^\./0./' -e 's/\([1-9]\)00$/\1/' -e 's/\([1-9]\)0$/\1/' < "$PROCESSDIR"/calculated.txt > "$PROCESSDIR"/stripped.txt
exit_on_failure $? "Couldn't create stripped.txt:  ${PROCESSDIR}/stripped.txt from ${PROCESSDIR}/calculated.txt"
# unix2dos "$PROCESSDIR"/expression.txt
sed -e 's/\.000$//' -e 's/\.00$//' -e 's/\.0$//' -e 's/\([1-9]\)0+$/$1/' -e 's/^\./0./' < "$PROCESSDIR"/sums.txt > "$PROCESSDIR"/strippedsums.txt
exit_on_failure $? "Couldn't create strippedsums.txt:  ${PROCESSDIR}/strippedsum.txt from ${PROCESSDIR}/sums.txt"
# unix2dos "$PROCESSDIR"/stripped.txt

# produce final comparison

diff -s "$PROCESSDIR"/stripped.txt "$PROCESSDIR"/strippedsums.txt > "$PROCESSDIR"/final.txt
exit_on_failure $? "Couldn't create final.txt:  ${PROCESSDIR}/final.txt differences of ${PROCESSDIR}/stripped.txt and ${PROCESSDIR}/strippedsums.txt"
cat  "$PROCESSDIR"/final.txt
# unix2dos "$PROCESSDIR"/final.txt


# TODO make this a pipeline

# This adds boxes
# cat "${METATEMPLATE}" | perl SkeletonParse.pl | perl -p -e s/Toddler/"${CHARACTER}"/g > "$TEMPLATE"
# this does not add boxes
cat "${METATEMPLATE}" | perl -p -e s/MODIFYDATE/"`date +'%d %b %Y'`"/g | perl -p -e s/Toddler/"${CHARACTER}"/g | perl -p -e s/TODDLER/"${CHARACTER}${VERSION}"/g > "$TEMPLATE"
exit_on_failure $? "Problems substituting $CHARACTER ${VERSION} ${METATEMPLATE} to $TEMPLATE"

unix2dos "$TEMPLATE"
exit_on_failure $? "install unix2dos"

perl replacejoints.pl < "$TEMPLATE" | sed -e "s/IMAGE.png/${IMAGE}/" > "$JOINTOUTPUT"
exit_on_failure $? "Couldn't create ${JOINTOUTPUT} using perl replacejoints.pl < $TEMPLATE | sed -e s/IMAGE.png/${IMAGE}/ > $JOINTOUTPUT"
# GOOD # perl haveSkeletonAddZeroCenters.pl < "$JOINTOUTPUT" | perl centers.pl "${CENTERS}" > "$CENTEROUTPUT"
# exit_on_failure $? "Couldn't create ${CENTEROUTPUT} using perl centers.pl ${CENTERS} < ${JOINTOUTPUT} > ${CENTEROUTPUT}"
#perl SkeletonParseLine.pl "$CENTEROUTPUT" "${WEIGHTS}" "${CENTERS}" | sed -e "s/IMAGE.png/${IMAGE}/" > "${REVISEDOUTPUT}"
#exit_on_failure $? "Couldn't create ${REVISEDOUTPUT} using perl SkeletonParseLine.pl ${CENTEROUTPUT} ${WEIGHTS} ${CENTERS}"
# GOOD # # perl haveSkeletonAddBoxes.pl "${WEIGHTS}" < "${CENTEROUTPUT}" > "${BOXOUTPUT}"
# exit_on_failure $? "Couldn't create ${BOXOUTPUT} using perl haveSkeletonAddBoxes.pl ${WEIGHTS} < ${CENTEROUTPUT} > ${BOXOUTPUT}"
# GOOD # # perl haveSkeletonAddSkinCoord.pl "${WEIGHTS}" <  "${BOXOUTPUT}" > "${REVISEDOUTPUT}"
# exit_on_failure $? "Couldn't create ${REVISEDOUTPUT} using perl haveSkeletonAddSkinCoord.pl ${WEIGHTS} < $BOXOUTPUT > ${REVISEDOUTPUT}"
# perl haveSkeletonAddSkinCoord.pl "${WEIGHTS}" <  "${JOINTOUTPUT}" > "${REVISEDOUTPUT}"
# exit_on_failure $? "Couldn't create ${REVISEDOUTPUT} using perl haveSkeletonAddSkinCoord.pl ${WEIGHTS} < $JOINTOUTPUT > ${REVISEDOUTPUT}"

cp  "${JOINTOUTPUT}" "${REVISEDOUTPUT}"
exit_on_failure $? "Couldn't copy from $JOINTOUTPUT to ${REVISEDOUTPUT}"

cp JointCoordinateAxes.x3dv *.png  "$OUTPUTDIR"
exit_on_failure $? "Couldn't add resources and textures JointCoordinateAxes.x3dv *.png to ${OUTPUTDIR}"

#=================================================================================================================
# Collect coordinates from vertices file into a single string and export to files

	# sed -e 's/^[0-9][0-9]*\t//' |
# get into TSV form then grab coordinate
echo "Processing ${VERTICES}"
echo "WARNING!!!!!!!!!!!!! TODO This line executes a perl script generated from ${VERTICES}.  Use with care!"
tail +2 "$VERTICES" | sed -e 's/root //' |
	sed -e 's/^(/0\t/' |
	sed -e 's/)//g' |
	sed -e 's/\r//g' |
	sed -e 's/, /\t/g' |
	sed -e 's/  / /g' |
	sed -e 's/[ \t][ \t][ \t]*/\t/g' |
	sed -e "s/^\([-0-9\.][0-9\.]*\)\t/print(\1);\t/" |
	sed -e "s/\t\([-0-9e\.][-0-9e\.]*\) \xB5m/\tprint(\1*0.000001);/g" |
	sed -e "s/\t\([-0-9e\.][-0-9e\.]*\) µm/\tprint(\1*0.000001);/g" |
	sed -e "s/\t\([-0-9e\.][-0-9e\.]*\) mm/\tprint(\1*0.001);/g" |
	sed -e "s/\t\([-0-9e\.][-0-9e\.]*\) cm/\tprint(\1*0.01);/g" |
	sed -e "s/\t\([-0-9e\.][-0-9e\.]*\) m/\tprint(\1*1.0);/g" |
	sed -e "s/\t\([-0-9e\.][-0-9e\.]*\)/\tprint(\1);/g" |
	sed -e "s/^\(print([0-9][0-9]*);\tprint\)\(([^)][^)]*)\)\(;\tprint\)\(([^)][^)]*)\)\(;\tprint\)\(([^)][^)]*)\)\(.*\)/\1(\2)\3(\4)\5(\6)\7/" | tee "${PROCESSDIR}"/debugPoints0.txt |
	sed -e 's/\t/print("\\t");\t/g' |
	sed -e 's/$/print("\\n");\t/g' |
	sed -e 's/[<>`|]//g' |
	tee "${PROCESSDIR}"/debugPoints1.txt |
	perl |
	sed -e 's/\r$//' -e 's/^[0-9][0-9]*\t//' -e 's/\t$//' |
	tee "${PROCESSDIR}"/debugPoints2.txt | tr '\t' ' ' > "$PROCESSDIR"/points.txt
exit_on_failure $? "Couldn't filter ${VERTICES} to create  ${PROCESSDIR}/points.txt"
echo "If you see output below, there's bad info (possibly very large numbers) in the ${VERTICES} file"
sed  -e 's/^[-0-9][-0-9e\. \t]*$//' "${PROCESSDIR}"/debugPoints2.txt|sort -u | tr '\n' ' '
echo "If you see output above, there's bad info (possibly very large numbers) in the ${VERTICES} file"


# collect up textures

tail +2 "$TEXTURES" | sed -n -e 's/^\([0-9][0-9]*\)\t\([0-9\.][0-9\.]*\)\t\([0-9\.][0-9\.]*\)\t\([0-9\.][0-9\.]*\)\t\([0-9\.][0-9\.]*\)\t\([0-9\.][0-9\.]*\)\t\([0-9\.][0-9\.]*\)\t\([0-9\.][0-9\.]*\)\t\([0-9\.][0-9\.]*\)\t\([0-9\.][0-9\.]*\)\t/\1 \2 \3 \5 \6 \8 \9/p' > "${PROCESSDIR}/textures.txt"
#tail +2 "$TEXTURES" | sed -n -e 's/^vt \([0-9\.][0-9\.]*\) \([0-9\.][0-9\.]*\)/\1 \2/p' > "${PROCESSDIR}/textures.txt"
exit_on_failure $? "Couldn't filter $TEXTURES} to create  ${PROCESSDIR}/textures.txt"
#awk 'BEGIN {for (j = 0; j < 1; j += 1/sqrt(20889)) for (i=1; i >= 0; i -= 1/sqrt(20889)) print i, j; }' > "${PROCESSDIR}/textures.txt"
#exit_on_failure $? "Couldn't create a list of number from 0 to 1 to place in ${PROCESSDIR}/textures.txt"

# collect triangles and add -1 to the end
tail +2 "$TRIANGLES" | sed -e 's/\r//g' -e 's/\t$//' -e 's/[^\t]*\t\([-0-9]*\)\t\([-0-9]*\)\t\([-0-9]*\)$/\1 \2 \3 -1/' | tee ${PROCESSDIR}/debugTriangles.txt > "$PROCESSDIR"/triangles.txt
exit_on_failure $? "Couldn't filter ${TRIANGLES} to create  ${PROCESSDIR}/triangles.txt"
perl replacepointsvertices.pl "$REVISEDOUTPUT" "$FINAL" "$PROCESSDIR"/points.txt  "$PROCESSDIR"/triangles.txt "$PROCESSDIR"/textures.txt
exit_on_failure $? "Replacing points failed. Command line was: perl replacepointsvertices.pl ${REVISEDOUTPUT} ${FINAL} ${PROCESSDIR}/points.txt  ${PROCESSDIR}/triangles.txt $PROCESSDIR/textures.txt"
echo Now append "${ANIMATIONS}" with substitutions to $FINAL to add animation
# we are adding Pitch, Roll, Stop and Touch because they are "standard" animations.  Also, Roll and Pitch are used as large Animations *and*  in granular ones
node.exe takes.js < ${TAKESJSON}
exit_on_failure $? "Couldn't create ${TAKES} usd takes.js < takes.json"
cat "${TIMERS}" >> "${FINAL}"
exit_on_failure $? "Couldn't append ${TIMERS} to ${FINAL}"
perl substitetimers.pl "${CHARACTER}" > ${PROCESSDIR}/Animations"${CHARACTER}${VERSION}".txt  
exit_on_failure $? "Couldn't write ${PROCESSDIR}/Animations${CHARACTER}${VERSION}.txt"
cat  "${PROCESSDIR}/Animations${CHARACTER}${VERSION}.txt" >> "${FINAL}"
exit_on_failure $? "Couldn't append ${PROCESSDIR}/Animations${VERSION}.txt to ${FINAL}"
cat "$ANIMATIONS" | perl -p -e s/Toddler/"${CHARACTER}"/g | sed -e s/"${CHARACTER}"_"${CHARACTER}"/"${CHARACTER}"/g  >> "$FINAL"
# cat "$ANIMATIONS" | perl -p -e s/Toddler/"${CHARACTER}"/g | sed -e s/Stop/"${CHARACTER}"_Stop01/g -e s/Default/"${CHARACTER}"_Stop01/g -e s/Stand02/"${CHARACTER}"_Stand02/g -e s/Stand03/"${CHARACTER}"_Stand03/g -e 's/Stand\([^0]\)/'"${CHARACTER}"'_Stand01\1/g' -e s/Pitch/"${CHARACTER}"_Pitch01/g -e s/Roll/"${CHARACTER}"_Roll01/g -e s/Kick/"${CHARACTER}"_Kick01/g -e s/Run/"${CHARACTER}"_Run01/g -e s/Yaw/"${CHARACTER}"_Turn01/g -e s/Jump/"${CHARACTER}"_Jump01/g -e s/Skip/"${CHARACTER}"_Skip01/g -e s/Walk02/"${CHARACTER}"_Walk02/g -e 's/Walk\([^0]\)/'"${CHARACTER}"'_Walk01\1/g' -e s/"${CHARARCTER}"_"${CHARACTER}"/"${CHARACTER}"/g  >> "$FINAL"
exit_on_failure $? "Couldn't append Common ${ANIMATIONS} to ${FINAL}"
cat "${TAKES}" >> "$FINAL" 
exit_on_failure $? "Couldn't append ${TAKES} to ${FINAL}"
unix2dos "$FINAL"
exit_on_failure $? "Couldn't convert ${FINAL} from unix to dos with unix2dos"

#
#===============================================================================
# Now comute missing weight indexes

# get the indexes from the weights file an sort them
cat "$WEIGHTS" | sed -n 's/.*(\(.*\)).*/\1/p' | sort -nu > "$WEIGHTSOUTPUT"
exit_on_failure $? "Couldn't get a list of indexes from ${WEIGHTS} to filter into ${WEIGHTSOUTPUT}"

# find points in skeleton
#
export numCoords=`cat "$FINAL" | perl findpoints.pl | wc | awk '{ print $1; }'`
exit_on_failure $? "Couldn't get a list of points from ${FINAL} with perl findpoints.pl, wc, and awk"
echo "If the number of of cooordinate indicies below is not correct, look at ${PROCESSDIR}/debugPoints1.txt  or ${PROCESSDIR}/debugPoints2.txt then finally look at ${PROCESSDIR}/points.txt. not with an editor that cannot handle long lines)"
echo "Look in ${EXTRAWEIGHTS} for any extra weights"
echo "Look in ${FINAL} to see if the IndexedFaceSet/Coordinate (skin) has the right point value if not correct"
echo "Number of coordinate indicies = $numCoords"

# create a file of dummy indexes for coord indexes
#
awk 'BEGIN {for (i=0; i < '${numCoords}'; i++) print i}' > $SKELETONOUTPUT
exit_on_failure $? "Couldn't create a list of number from 0 to $(($numCoords-1)) to place in ${SKELETONOUTPUT}"

# compare coord indexes to weights index
echo diff -s $SKELETONOUTPUT $WEIGHTSOUTPUT

# report differences
echo missing indexes not found in weights, '>' in the first column means there was an extra weight index
diff -s $SKELETONOUTPUT $WEIGHTSOUTPUT | grep -v , | sed 's/^<.//'
exit_on_failure $? "Couldn't compare differences between ${SKELETONOUTPUT} ${WEIGHTSOUTPUT}"

echo "Counts of polygons and points from ${FINAL} are below:"
sed -n -e 's/[^#]*\(.*\)/\1/p'  "$FINAL" | grep '#'|grep -v ROUTE|grep count
exit_on_failure $? "Couldn't get counts ${FINAL}"

echo "============================================================="
echo "Verifying..."

export ROUNDTRIPWEIGHTSDIR="${OUTPUTDIR}/WeightsOut"
export SKELETONWEIGHTSDIR="${OUTPUTDIR}/SkeletonOut"
rm -r "${ROUNDTRIPWEIGHTSDIR}"
rm -r "${SKELETONWEIGHTSDIR}"
mkdir -p "${ROUNDTRIPWEIGHTSDIR}"
mkdir -p "${SKELETONWEIGHTSDIR}"

dos2unix "${WEIGHTS}"
exit_on_failure $? "Couldn't convert weights files in ${WEIGHTS}/"

perl RoundTrip.pl "$WEIGHTSOUT" "${ROUNDTRIPWEIGHTSDIR}" "${MAPPINGFILE}"
dos2unix "${ROUNDTRIPWEIGHTSDIR}"/*_weights.txt
exit_on_failure $? "Couldn't convert weights files ${ROUNDTRIPWEIGHTSDIR}/*_weights.txt"

perl SkeletonParseLineValidate.pl "${FINAL}" "${SKELETONWEIGHTSDIR}" "$MAPPINGFILE"
dos2unix "${SKELETONWEIGHTSDIR}"/*_weights.txt 
exit_on_failure $? "Couldn't convert weights files in ${SKELETONWEIGHTSDIR}/*_weights.txt"
echo "Final is ${FINAL}"
