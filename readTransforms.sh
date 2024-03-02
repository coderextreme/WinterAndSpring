#!/bin/bash -x
set -euo pipefail
IFS=$'\n\t'
#

# convert  VRML skeleton by multiplying out transforms to create centers without transforms
# by way of X3D JSON

# perl takes.json.pl < 0MainStageTotal_7Saved.txt > takes.json

npx x3d-tidy@1.0.91 -i "`pwd`""/InputDir73/lily 7_3_animate.wrl" -o "`pwd`"/"/InputDir73/lily 7_3_animate.x3dv"
npx x3d-tidy@1.0.91 -i "`pwd`""/InputDir73/lily 7_3_animate.wrl" -o "`pwd`"/"/InputDir73/lily 7_3_animate.x3dj"
node convertTransformsToCenters.js < "InputDir73/lily 7_3_animate.x3dj" > "InputDir73/lily 7_3_animate.txt" 

npx x3d-tidy@1.0.91 -i "`pwd`"/"OldTemplate.x3dv" -o "`pwd`"/"OldTemplate.x3dj"
node convertTransformsToCenters.js < "`pwd`"/"OldTemplate.x3dj" > "`pwd`"/"InputDir73/OldTemplate.txt" 

perl haveTransformDEFaddName.pl < "InputDir73/lily 7_3_animate.wrl"> "ProcessDir73/lily 7_3_animate.x3dv"
perl haveIFSmoveToSkin.pl < "ProcessDir73/lily 7_3_animate.x3dv" > "ProcessDir73/lily_7_3_movedskin.x3dv"
# add centers, then add real centers
perl haveSkeletonAddZeroCenters.pl < "ProcessDir73/lily_7_3_movedskin.x3dv" | perl haveSkeletonAddCenters.pl "InputDir73/7_3 joint location.txt" > "ProcessDir73/lily_7_3_template.x3dv"
perl haveSkeletonAddSkinCoord.pl "InputDir73/7_3_WEIGHTS.txt" < "ProcessDir73/lily_7_3_template.x3dv" > "ProcessDir73/lily_7_3_withskincoord.x3dv"
perl haveSkeletonAddBoxes.pl "InputDir73/7_3_WEIGHTS.txt" < "ProcessDir73/lily_7_3_withskincoord.x3dv" > "ProcessDir73/lily_7_3_withboxes.x3dv" 




# egrep 'l_carpal_proximal_interphalangeal_5|l_carpal_distal_interphalangeal_5|r_metatarsophalangeal_2|l_metatarsophalangeal_2|r_carpal_proximal_interphalangeal_5|r_carpal_distal_interphalangeal_5' "InputDir73/lily 7_3_animate.x3dj" "InputDir73/lily 7_3_animate.x3dj"  "InputDir73/lily 7_3_animate.txt" | grep -v KEY
