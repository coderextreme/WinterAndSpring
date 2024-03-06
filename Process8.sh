#!/bin/bash
set -euo pipefail
export IFS=$'\n\t'

export VERSION=8
# Change where zips are found
export DOWNLOADS="C:/Users/john/Downloads"
export X3DJSONLD="C:/Users/john/X3DJSONLD/src/main"
export VIEW3DSCENE="C:/Users/john/Downloads/view3dscene-4.3.0-win64-x86_64/view3dscene"

# zip is copyed to input folder, then unpacked
#export ZIPNAME="lily RV6_IPOSE.zip"
#export INPUTZIP="${DOWNLOADS}"/"$ZIPNAME"

# Here's where inputs are placed
export INPUTDIR="InputDir${VERSION}"
export ALTINPUTDIR="InputDir${VERSION}"

# This is a debugging folder
export PROCESSDIR="ProcessDir${VERSION}"

# this is wher to picu up output
export OUTPUTDIR="OutputDir${VERSION}"

# This is the Classic VRML Template
#export METATEMPLATE="NewTemplate.x3dv"
export METATEMPLATE="New2Template.x3dv"
#export METATEMPLATE="New3Template.x3dv"
#export METATEMPLATE="Old2Template.x3dv"   # note, no boxes

export GENERATION=Toddler
export ANIMATIONS="${GENERATION}.Everything.txt" # where to pick up remaining animations and Everything stuff

export WEIGHTSFILE="7_3_WEIGHTS.txt"  # joint index and a weight for skinCoord*
export CENTERSFILE="7_3 joint location.txt"  # Joint locations and rotations
export VERTFILE="lily_7_3_points.txt"  # incdex of point and metter based values
export TRIANGLEFILE="lily_7_3_polygon.txt"  # list of polygons, by number and 3 indexes into point array
export TEXTUREFILE="lily_6_1_UVW.txt"  # UV file for constructing 2D triangles on texture, U and V are between 0 and 1

# extra file for humanoid to append to weights file
#export EXTRAWEIGHTS=humanoid_root_weights.txt  # appended to weights file
export EXTRAWEIGHTS=/dev/null  # no extra weights


# Input files with folder
export WEIGHTS="${INPUTDIR}/${WEIGHTSFILE}"
export VERTICES="${INPUTDIR}/${VERTFILE}"
export TRIANGLES="${INPUTDIR}/${TRIANGLEFILE}"
export TEXTURES="${INPUTDIR}/${TEXTUREFILE}"
export CENTERS="${INPUTDIR}/${CENTERSFILE}"

export WEIGHTSOUT="${PROCESSDIR}"/WeightsOut.txt   # summary file of weights
export MAPPINGFILE="${PROCESSDIR}"/mapping.txt  # joint listing table
export WEIGHTSOUTPUT="${OUTPUTDIR}"/WeightsIndexes.txt  # indexes in weights
export SKELETONOUTPUT="${OUTPUTDIR}"/SkeletonIndexes.txt # indexes in skeleton
export ROUNDTRIPWEIGHTSDIR="${OUTPUTDIR}"/WeightsOut  # folder for output weights
export SKELETONWEIGHTSDIR="${OUTPUTDIR}"/SkeletonOut  # folder for skeleton weights

# Let's do Tufani
export CHARACTER=Tufani # name of character
export TEMPLATE="${PROCESSDIR}/${CHARACTER}${VERSION}.x3dv"   # note, no boxes
export JOINTOUTPUT="${PROCESSDIR}/${CHARACTER}${VERSION}Jointed.x3dv"  # preliminary joint output
export POSTZAPBOXOUTPUT="${PROCESSDIR}/${CHARACTER}${VERSION}PostZap.x3dv" # after zaping boxes
export MIDCENTEROUTPUT="${PROCESSDIR}/${CHARACTER}${VERSION}Midcenter.x3dv"  # preliminary center output
export CENTEROUTPUT="${PROCESSDIR}/${CHARACTER}${VERSION}Center.x3dv"  # preliminary center output
export BOXOUTPUT="${PROCESSDIR}/${CHARACTER}${VERSION}Boxed.x3dv"  # preliminary boxed output
export REVISEDOUTPUT="${PROCESSDIR}/${CHARACTER}${VERSION}Revised.x3dv"  # preliminary output
export FINAL="${OUTPUTDIR}/${CHARACTER}${VERSION}Final.x3dv"  # final output
# export ANIMATIONS="${CHARACTER}".txt # where to pick up animations.
export TAKES="takes.${CHARACTER}.txt"
export TIMERS="takes.${CHARACTER}.timers.txt"
export TAKESJSON="takes.json"
export TIMERS="takes.${CHARACTER}.timers.txt"
export IMAGE="TufaniAvatarBasecolor.png" # name of texture image, replaces IMAGE in X3DV
export IMAGE="TUFANI SKIN 2.png" # name of texture image, replaces IMAGE in X3DV
bash "SubProcess${VERSION}.sh" # run the drive script for Tufani

# Let's do Lily
export CHARACTER=Lily  # name of character
export TEMPLATE="${PROCESSDIR}/${CHARACTER}${VERSION}.x3dv"   # note, no boxes
export JOINTOUTPUT="${PROCESSDIR}/${CHARACTER}${VERSION}Jointed.x3dv"  # preliminary joint output
export POSTZAPBOXOUTPUT="${PROCESSDIR}/${CHARACTER}${VERSION}PostZap.x3dv" # after zaping boxes
export MIDCENTEROUTPUT="${PROCESSDIR}/${CHARACTER}${VERSION}Midcenter.x3dv"  # preliminary center output
export CENTEROUTPUT="${PROCESSDIR}/${CHARACTER}${VERSION}Center.x3dv"  # preliminary center output
export BOXOUTPUT="${PROCESSDIR}/${CHARACTER}${VERSION}Boxed.x3dv"  # preliminary boxed output
export REVISEDOUTPUT="${PROCESSDIR}/${CHARACTER}${VERSION}Revised.x3dv"  # preliminary output
export FINAL="${OUTPUTDIR}/${CHARACTER}${VERSION}Final.x3dv"  # final output
# export ANIMATIONS="${CHARACTER}".txt # where to pick up animations.
export TAKES="takes.${CHARACTER}.txt"
export TIMERS="takes.${CHARACTER}.timers.txt"
export TAKESJSON="takes.json"
#export IMAGE="seddi avatar_basecolor2.png" # name of texture image, replaces IMAGE in X3DV
# export IMAGE="LilyAvatarBasecolorNoTransp.png" # name of texture image, replaces IMAGE in X3DV
export IMAGE="lily_2t_BaseColor.png" # name of texture image, replaces IMAGE in X3DV

# seddi avatar_basecolor.png
bash "SubProcess${VERSION}.sh" # run the drive script for Lily

# Let's do Leif
export CHARACTER=Leif # name of character
export TEMPLATE="${PROCESSDIR}/${CHARACTER}${VERSION}.x3dv"   # note, no boxes
export JOINTOUTPUT="${PROCESSDIR}/${CHARACTER}${VERSION}Jointed.x3dv"  # preliminary joint output
export POSTZAPBOXOUTPUT="${PROCESSDIR}/${CHARACTER}${VERSION}PostZap.x3dv" # after zaping boxes
export MIDCENTEROUTPUT="${PROCESSDIR}/${CHARACTER}${VERSION}Midcenter.x3dv"  # preliminary center output
export CENTEROUTPUT="${PROCESSDIR}/${CHARACTER}${VERSION}Center.x3dv"  # preliminary center output
export BOXOUTPUT="${PROCESSDIR}/${CHARACTER}${VERSION}Boxed.x3dv"  # preliminary boxed output
export REVISEDOUTPUT="${PROCESSDIR}/${CHARACTER}${VERSION}Revised.x3dv"  # preliminary output
export FINAL="${OUTPUTDIR}/${CHARACTER}${VERSION}Final.x3dv"  # final output
# export ANIMATIONS="${CHARACTER}".txt # where to pick up animations.
export TAKES="takes.${CHARACTER}.txt"
export TIMERS="takes.${CHARACTER}.timers.txt"
export TAKESJSON="takes.json"
export IMAGE="leif bottom_basecolor.png" # name of texture image, replaces IMAGE in X3DV
bash "SubProcess${VERSION}".sh # run the drive script for Leif
