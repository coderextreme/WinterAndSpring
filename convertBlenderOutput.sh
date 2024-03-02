#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# ~/Downloads/view3dscene-4.3.0-win64-x86_64/view3dscene/tovrmlx3d.exe --encoding classic "${PREFIX}".gltf > "${PREFIX}".gltfsource.x3dv 
export WORKDIR=lily_73
export PREFIX="${WORKDIR}"/"${WORKDIR}"
mkdir "${WORKDIR}"
cp  "${WORKDIR}".gltf "$WORKDIR"
export VIEW3DSCENE=~/Downloads/view3dscene-4.3.0-win64-x86_64/view3dscene/
export TOVRMLX3D="${VIEW3DSCENE}"tovrmlx3d.exe
export PROCESSDIR=ProcessDir73
export INPUTDIR=InputDir73
export VALIDATE=1

echo "The main inputs are ${PREFIX}.gltf and ${PREFIX}.x3d as exported from Blender"

echo "${TOVRMLX3D} --encoding classic ${PREFIX}.gltf > ${PREFIX}.gltfsource.x3dv"
"${TOVRMLX3D}" --encoding classic "${PREFIX}".gltf > "${PREFIX}".gltfsource.x3dv 
echo "${TOVRMLX3D} --validate ${PREFIX}.gltfsource.x3dv"
if [ $VALIDATE -eq 1 ]; then "${TOVRMLX3D}" --validate "${PREFIX}".gltfsource.x3dv; else echo "Validate disabled"; fi

echo "${TOVRMLX3D} --encoding classic ${PREFIX}.x3d > ${PREFIX}.x3dsource.x3dv"
"${TOVRMLX3D}" --encoding classic "${PREFIX}".x3d > "${PREFIX}".x3dsource.x3dv 
echo "${TOVRMLX3D} --validate ${PREFIX}.x3dsource.x3dv"
if [ $VALIDATE -eq 1 ]; then "${TOVRMLX3D}" --validate "${PREFIX}".x3dsource.x3dv; else echo "Validate disabled"; fi

echo "perl moveupchildren.pl < "${PREFIX}".gltfsource.x3dv > "${PREFIX}"notranschild.x3dv"
perl moveupchildren.pl < "${PREFIX}".gltfsource.x3dv > "${PREFIX}"notranschild.x3dv 
# shouldn't validate
# if [ $VALIDATE -eq 1 ]; then ~/Downloads/view3dscene-4.3.0-win64-x86_64/view3dscene/tovrmlx3d.exe --validate "${PREFIX}"notranschild.x3dv; else echo "Validate disabled"; else echo "Validate disabled"; fi

echo "perl haveTransformDEFaddName.pl < "${PREFIX}"notranschild.x3dv > "${PREFIX}"named.x3dv"
perl haveTransformDEFaddName.pl < "${PREFIX}"notranschild.x3dv > "${PREFIX}"named.x3dv
echo "${TOVRMLX3D} --validate ${PREFIX}named.x3dv"
if [ $VALIDATE -eq 1 ]; then "${TOVRMLX3D}" --validate "${PREFIX}"named.x3dv; else echo "Validate disabled"; fi

echo "perl replacejoints.pl < "${PREFIX}"named.x3dv > "${PREFIX}"jointed.x3dv"
perl replacejoints.pl < "${PREFIX}"named.x3dv > "${PREFIX}"jointed.x3dv
echo "${TOVRMLX3D} --validate ${PREFIX}jointed.x3dv"
if [ $VALIDATE -eq 1 ]; then "${TOVRMLX3D}" --validate "${PREFIX}"jointed.x3dv; else echo "Validate disabled"; fi

echo "perl replacescale.pl < "${PREFIX}"jointed.x3dv > "${PREFIX}"scaled.x3dv"
perl replacescale.pl < "${PREFIX}"jointed.x3dv > "${PREFIX}"scaled.x3dv
echo "${TOVRMLX3D} --validate ${PREFIX}scaled.x3dv"
if [ $VALIDATE -eq 1 ]; then "${TOVRMLX3D}" --validate "${PREFIX}"scaled.x3dv; else echo "Validate disabled"; fi

echo "perl Newcenters.pl ${INPUTDIR}/7_3\ joint\ location.txt < ${PREFIX}scaled.x3dv > ${PREFIX}centered.x3dv"
perl Newcenters.pl "${INPUTDIR}/7_3 joint location.txt" < "${PREFIX}"scaled.x3dv > "${PREFIX}"centered.x3dv
echo "${TOVRMLX3D} --validate ${PREFIX}centered.x3dv"
if [ $VALIDATE -eq 1 ]; then "${TOVRMLX3D}" --validate "${PREFIX}"centered.x3dv; else echo "Validate disabled"; fi

echo "perl haveSkeletonAddSkinCoord.pl ${INPUTDIR}/7_3_WEIGHTS.txt <  "${PREFIX}"centered.x3dv > "${PREFIX}"revised.x3dv"
perl haveSkeletonAddSkinCoord.pl "${INPUTDIR}/7_3_WEIGHTS.txt" <  "${PREFIX}"centered.x3dv > "${PREFIX}"revised.x3dv
echo "${TOVRMLX3D} --validate ${PREFIX}revised.x3dv"
if [ $VALIDATE -eq 1 ]; then "${TOVRMLX3D}" --validate "${PREFIX}"revised.x3dv; else echo "Validate disabled"; fi


tail +2 "${INPUTDIR}/lily_7_3_points.txt" | sed -e 's/root //' |
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
	sed -e "s/^\(print([0-9][0-9]*);\tprint\)\(([^)][^)]*)\)\(;\tprint\)\(([^)][^)]*)\)\(;\tprint\)\(([^)][^)]*)\)\(.*\)/\1(\2)\3(\4)\5(\6)\7/" |
	sed -e 's/\t/print("\\t");\t/g' |
	sed -e 's/$/print("\\n");\t/g' |
	sed -e 's/[<>`|]//g' |
	perl |
	sed -e 's/\r$//' -e 's/^[0-9][0-9]*\t//' -e 's/\t$//' | tr '\t' ' ' > "$PROCESSDIR"/points.txt

tail +2 "${INPUTDIR}/lily_7_3_polygon.txt" | sed -e 's/\r//g' -e 's/\t$//' -e 's/[^\t]*\t\([-0-9]*\)\t\([-0-9]*\)\t\([-0-9]*\)$/\1 \2 \3 -1/' > "${PROCESSDIR}"/triangles.txt

tail +2 "${INPUTDIR}/lily_6_1_UVW.txt" | sed -n -e 's/^\([0-9][0-9]*\)\t\([0-9\.][0-9\.]*\)\t\([0-9\.][0-9\.]*\)\t\([0-9\.][0-9\.]*\)\t\([0-9\.][0-9\.]*\)\t\([0-9\.][0-9\.]*\)\t\([0-9\.][0-9\.]*\)\t\([0-9\.][0-9\.]*\)\t\([0-9\.][0-9\.]*\)\t\([0-9\.][0-9\.]*\)\t/\1 \2 \3 \5 \6 \8 \9/p' > "${PROCESSDIR}"/textures.txt

echo "perl replacepointsvertices.pl ${PREFIX}revised.x3dv ${PREFIX}pav.x3dv ${PROCESSDIR}/points.txt  ${PROCESSDIR}/triangles.txt ${PROCESSDIR}/textures.txt"
perl replacepointsvertices.pl "${PREFIX}"revised.x3dv "${PREFIX}"pav.x3dv "${PROCESSDIR}"/points.txt  "${PROCESSDIR}"/triangles.txt "${PROCESSDIR}"/textures.txt
echo "${TOVRMLX3D} --validate ${PREFIX}pav.x3dv"
if [ $VALIDATE -eq 1 ]; then "${TOVRMLX3D}" --validate "${PREFIX}"pav.x3dv; else echo "Validate disabled"; fi

echo "perl haveIFSmoveToSkin.pl < ${PREFIX}pav.x3dv > ${PREFIX}skinplaced.x3dv"
perl haveIFSmoveToSkin.pl < "${PREFIX}"pav.x3dv > "${PREFIX}"skinplaced.x3dv
echo "${TOVRMLX3D} --validate ${PREFIX}skinplaced.x3dv"
if [ $VALIDATE -eq 1 ]; then "${TOVRMLX3D}" --validate "${PREFIX}"skinplaced.x3dv; else echo "Validate disabled"; fi

echo "perl replaceSkin.pl  ${PREFIX}.x3dsource.x3dv ${PREFIX}skinplaced.x3dv > ${PREFIX}final.x3dv"
perl replaceSkin.pl  "${PREFIX}".x3dsource.x3dv "${PREFIX}"skinplaced.x3dv > "${PREFIX}"final.x3dv
echo "${TOVRMLX3D} --validate ${PREFIX}final.x3dv"
if [ $VALIDATE -eq 1 ]; then "${TOVRMLX3D}" --validate "${PREFIX}"final.x3dv; else echo "Validate disabled"; fi


echo "${VIEW3DSCENE}view3dscene.exe ${PREFIX}final.x3dv"
"${VIEW3DSCENE}"view3dscene.exe "${PREFIX}"final.x3dv
# perl haveSkeletonAddSkin.pl
# perl haveDEFaddName.pl < "${PREFIX}".gltfsource.x3dv > "${PREFIX}"named.x3dv
