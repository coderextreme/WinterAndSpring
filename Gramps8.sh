#!/bin/bash
set -euo pipefail
export IFS=$'\n\t'

export VERSION=8
# Change where zips are found
export DOWNLOADS="C:/Users/john/Downloads"

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
# export METATEMPLATE="NewTemplate.x3dv"
# export METATEMPLATE="New3Template.x3dv"
#export METATEMPLATE="blenderGramps.x3dv"
# export METATEMPLATE="GrampsBetterSkin.x3dv"
# export METATEMPLATE="GrampsTemplate.x3dv"
export METATEMPLATE="GrampsSkipKneeHip.x3dv"
# export METATEMPLATE="GrampsSkipKneeHipAltText.x3dv"
# export METATEMPLATE="GrampsVRMLOurSkeleton.x3dv"
# export METATEMPLATE="fooGrampsVRML.closer.x3dv"
#export METATEMPLATE="fooGrampsVRML.x3dv"
#export METATEMPLATE="fooGrampsVRMLbadcenter.x3dv"

# export METATEMPLATE="IPose.x3dv"
# export METATEMPLATE="lily 7_3_animate.x3dv"   # note, no boxes
# export METATEMPLATE="lily_7_3_movedskin.x3dv"
#

export GENERATION=Gramps
export ANIMATIONS="${GENERATION}.Everything.txt" # where to pick up remaining animations and Everything stuff

#export WEIGHTSFILE="GRAMPS_WEIGHTS.txt"  # joint index and a weight for skinCoord*
#export WEIGHTSFILE="GRAMPS_WIEGHTS.txt"  # joint index and a weight for skinCoord*
#export WEIGHTSFILE="gramps_weight.txt"  # joint index and a weight for skinCoord*
export WEIGHTSFILE="gramps_weights_final.txt"  # joint index and a weight for skinCoord*

export CENTERSFILE="gramps_joint_location.txt"  # Joint locations and rotations
#export CENTERSFILE="gramps_joint_location.txt.katy"  # Joint locations and rotations

# export CENTERSFILE="lily 7_3_animate.txt"  # Joint locations and rotations (Don't use)
# export CENTERSFILE="OldTemplate.txt"  # Joint locations and rotations (Don't use)


export VERTFILE="gramps_vertice.txt"  # incdex of point and metter based values
export TRIANGLEFILE="gramps_poly.txt"  # list of polygons, by number and 3 indexes into point array
export ALTINPUTDIR="InputDir8"
#export VERTFILE="gramps_points.txt"  # incdex of point and metter based values
#export TRIANGLEFILE="gramps_polygons.txt"  # list of polygons, by number and 3 indexes into point array
export TEXTUREFILE="gramps_uvw.txt"  # UV file for constructing 2D triangles on texture, U and V are between 0 and 1

# lily 7_3_animate.wrl
# LILY_7_3_BLEND.blend

# extra file for humanoid to append to weights file
#export EXTRAWEIGHTS=humanoid_root_weights.txt  # appended to weights file
export EXTRAWEIGHTS=/dev/null  # no extra weights


# Input files with folder
export WEIGHTS="${INPUTDIR}/${WEIGHTSFILE}"
export VERTICES="${ALTINPUTDIR}/${VERTFILE}"
export TRIANGLES="${ALTINPUTDIR}/${TRIANGLEFILE}"
export TEXTURES="${INPUTDIR}/${TEXTUREFILE}"
export CENTERS="${INPUTDIR}/${CENTERSFILE}"

export WEIGHTSOUT="${PROCESSDIR}"/WeightsOut.txt   # summary file of weights
export MAPPINGFILE="${PROCESSDIR}"/mapping.txt  # joint listing table
export WEIGHTSOUTPUT="${OUTPUTDIR}"/WeightsIndexes.txt  # indexes in weights
export SKELETONOUTPUT="${OUTPUTDIR}"/SkeletonIndexes.txt # indexes in skeleton
export ROUNDTRIPWEIGHTSDIR="${OUTPUTDIR}"/WeightsOut  # folder for output weights
export SKELETONWEIGHTSDIR="${OUTPUTDIR}"/SkeletonOut  # folder for skeleton weights

# Let's do Gramps
export CHARACTER=Gramps # name of character
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
export TAKESJSON="takes.json.new"
#export IMAGE=gramps_uv.png # name of texture image, replaces IMAGE in X3DV
# export IMAGE=gramps_outfit_2.png # name of texture image, replaces IMAGE in X3DV
export IMAGE=gramps_2_outfit1_diffuse.png # name of texture image, replaces IMAGE in X3DV

bash "SubGramps${VERSION}".sh # run the drive script for Gramps
