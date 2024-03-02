#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
#
# A way to pull weights out of the skeleton
#
export INPUTDIR=InputDir
export PROCESSDIR=ProcessDir
export OUTPUTDIR=OutputDir
export MAPPINGFILE="${PROCESSDIR}"/mapping.txt
export SKELETONWEIGHTSDIR="${OUTPUTDIR}/Skeleton2Out"

#export  INPOLYGONS="${INPUTDIR}/polygon location_r4.txt"
export  INPOLYGONS="${INPUTDIR}/lily rev5 fbx_poly count_location.txt"
export OUTPOLYGONS="${OUTPUTDIR}/polygon_locationR0.txt"
export CMPPOLYGONS="${OUTPUTDIR}/polygon_compareR0.txt"

export  INVERTICES="${INPUTDIR}/lily rev 5 fbx_verticecount.txt"
export OUTVERTICES="${OUTPUTDIR}/vertex_locationsR0.txt"
export CMPVERTICES="${OUTPUTDIR}/vertex_compareR0.txt"

export REVERSE="${OUTPUTDIR}/ToddlerFinal.x3dv"

function exit_on_failure() {
	local status=$1;
	local message=$2;
	local goodstatus=$3;
	local goodmessage=$4;
	if [[ $status -ne 0 && -z "$goodstatus" && $status -ne $goodstatus ]]
	then
		echo "Failure status $status:$message" 1>&2
		exit $status
	elif [[ "$status" = "$goodstatus" ]]
	then
		echo $goodmessage 1>&2
	fi
}

rm -r "${SKELETONWEIGHTSDIR}"
mkdir -p "${SKELETONWEIGHTSDIR}"

# Generate Skeleton Weights File from 
perl SkeletonParseLineValidate.pl "${REVERSE}" "${SKELETONWEIGHTSDIR}" "$MAPPINGFILE"
exit_on_failure $? "Failed to produce weights file from skeleton.  Command line was: SkeletonParseLineValidate.pl ${REVERSE} ${SKELETONWEIGHTSDIR} $MAPPINGFILE"
dos2unix "${SKELETONWEIGHTSDIR}"/*_weights.txt 
perl extractpointsvertices.pl "$REVERSE" "$OUTPOLYGONS" "$OUTPUTDIR"/points.txt  "$OUTPUTDIR"/triangles.txt "$OUTVERTICES"
exit_on_failure $? "Extracting points and triangles failed. Command line was: perl extractpointsvertices.pl ${REVERSE} ${OUTPUTDIR}/points.txt  ${OUTPUTDIR}/triangles.txt"
dos2unix "${INPOLYGONS}"
dos2unix "${OUTPOLYGONS}"
echo "Comparing input polygons to output polygons, diff -sw ${INPOLYGONS} ${OUTPOLYGONS}"
diff -sw "${INPOLYGONS}" "${OUTPOLYGONS}"
paste -d"\t" "$INPOLYGONS" "$OUTPOLYGONS" > "$CMPPOLYGONS"
exit_on_failure $? "Comparing polygon files with paste failed.  Command was: paste -d'\t' '$INPOLYGONS' '$OUTPOLYGONS' > '$CMPPOLYGONS'"
echo "Comparing input polygons to output vertices, diff -sw ${INVERTICES} ${OUTVERTICES}"
diff -sw "${INVERTICES}" "${OUTVERTICES}"
paste -d"\t" "$INVERTICES" "$OUTVERTICES" > "$CMPVERTICES"
exit_on_failure $? "Comparing vertices files with paste failed.  Command was: paste -d'\t' '$INVERTICES' '$OUTVERTICES' > '$CMPVERTICES'"
