#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

export VERSION=73
# Change where zips are found
export DOWNLOADS="C:/Users/john/Downloads"

export GENERATION=Toddler

# zip is copyed to input folder, then unpacked
#export ZIPNAME="lily RV6_IPOSE.zip"
#export INPUTZIP="${DOWNLOADS}"/"$ZIPNAME"

# Here's where inputs are placed
export INPUTDIR="InputDir${VERSION}"

# This is a debugging folder
export PROCESSDIR="ProcessDir${VERSION}"

# this is wher to picu up output
export OUTPUTDIR="OutputDir${VERSION}"

# This is the Classic VRML Template
# default template, characters are below
# Don't use the next line, see far below
#  export TEMPLATEXXXX="LiefSibling4d2dR4.5NoSkinNoWeightsNoTriangles.x3dv"   # note, no boxes.  Don't use this
# export METATEMPLATE="OldTemplate.x3dv"   # note, no boxes, A Pose
#export METATEMPLATE="NewTemplate.x3dv"
#export METATEMPLATE="New2Template.x3dv"
export METATEMPLATE="New3Template.x3dv"
# export METATEMPLATE="NewToddlerApprovedCenters.x3dv"

# export METATEMPLATE="IPose.x3dv"
# export METATEMPLATE="lily 7_3_animate.x3dv"   # note, no boxes
# export METATEMPLATE="lily_7_3_movedskin.x3dv"

export ANIMATIONS="${GENERATION}.Everything.txt" # where to pick up remaining animations and Everything stuff

export WEIGHTSFILE="7_3_WEIGHTS.txt"  # joint index and a weight for skinCoord*
export CENTERSFILE="7_3 joint location.txt"  # Joint locations and rotations
# export CENTERSFILE="lily 7_3_animate.txt"  # Joint locations and rotations (Don't use)
# export CENTERSFILE="OldTemplate.txt"  # Joint locations and rotations (Don't use)


export VERTFILE="lily_7_3_points.txt"  # incdex of point and metter based values
export TRIANGLEFILE="lily_7_3_polygon.txt"  # list of polygons, by number and 3 indexes into point array
export TEXTUREFILE="lily_6_1_UVW.txt"  # UV file for constructing 2D triangles on texture, U and V are between 0 and 1

# lily 7_3_animate.wrl
# LILY_7_3_BLEND.blend



# extra file for humanoid to append to weights file
export EXTRAWEIGHTS=humanoid_root_weights.txt  # appended to weights file
# export EXTRAWEIGHTS=/dev/null  # no extra weights


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

# Let's do Gramps
export CHARACTER=Gramps # name of character
export TEMPLATE="${PROCESSDIR}/${CHARACTER}${VERSION}.x3dv"   # note, no boxes
export JOINTOUTPUT="${PROCESSDIR}/${CHARACTER}${VERSION}Jointed.x3dv"  # preliminary joint output
export CENTEROUTPUT="${PROCESSDIR}/${CHARACTER}${VERSION}Center.x3dv"  # preliminary center output
export BOXOUTPUT="${PROCESSDIR}/${CHARACTER}${VERSION}Boxed.x3dv"  # preliminary boxed output
export REVISEDOUTPUT="${PROCESSDIR}/${CHARACTER}${VERSION}Revised.x3dv"  # preliminary output
export FINAL="${OUTPUTDIR}/${CHARACTER}${VERSION}Final.x3dv"  # final output
# export ANIMATIONS="${CHARACTER}".txt # where to pick up animations.
export TAKES="takes.${CHARACTER}.txt"
export TIMERS="takes.${CHARACTER}.timers.txt"
export TAKESJSON="takes.json"
export IMAGE=LeifAvatarBasecolor.png # name of texture image, replaces IMAGE in X3DV
# bash "SubProcess${VERSION}".sh # run the drive script for Gramps

# Let's do Gramps
export CHARACTER=John # name of character
export TEMPLATE="${PROCESSDIR}/${CHARACTER}${VERSION}.x3dv"   # note, no boxes
export JOINTOUTPUT="${PROCESSDIR}/${CHARACTER}${VERSION}Jointed.x3dv"  # preliminary joint output
export CENTEROUTPUT="${PROCESSDIR}/${CHARACTER}${VERSION}Center.x3dv"  # preliminary center output
export BOXOUTPUT="${PROCESSDIR}/${CHARACTER}${VERSION}Boxed.x3dv"  # preliminary boxed output
export REVISEDOUTPUT="${PROCESSDIR}/${CHARACTER}${VERSION}Revised.x3dv"  # preliminary output
export FINAL="${OUTPUTDIR}/${CHARACTER}${VERSION}Final.x3dv"  # final output
# export ANIMATIONS="${CHARACTER}".txt # where to pick up animations.
export TAKES="takes.${CHARACTER}.txt"
export TIMERS="takes.${CHARACTER}.timers.txt"
export TAKESJSON="${CHARACTER}.json"
export IMAGE=LeifAvatarBasecolor.png # name of texture image, replaces IMAGE in X3DV
#bash "SubProcess${VERSION}".sh # run the drive script for Gramps
