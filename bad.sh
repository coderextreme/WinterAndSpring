#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# egrep 'l_carpal_proximal_interphalangeal_5|l_carpal_distal_interphalangeal_5|r_metatarsophalangeal_2|l_metatarsophalangeal_2|r_carpal_proximal_interphalangeal_5|r_carpal_distal_interphalangeal_5' "InputDir73/lily 7_3_animate.wrl" | grep DEF | grep -v KEY
# bash readTransforms.sh 2>&1 | egrep 'l_carpal_proximal_interphalangeal_5|l_carpal_distal_interphalangeal_5|r_metatarsophalangeal_2|l_metatarsophalangeal_2|r_carpal_proximal_interphalangeal_5|r_carpal_distal_interphalangeal_5'
# npx x3d-tidy -i `pwd`"/InputDir73/lily 7_3_animate.wrl" -o `pwd`"/InputDir73/lily 7_3_animate.x3dj"
# npx x3d-tidy -i `pwd`"/InputDir73/lily 7_3_animate.x3d" -o `pwd`"/InputDir73/lily 7_3_animate.x3dj"
# /c/Users/john/Downloads/view3dscene-4.3.0-win64-x86_64/view3dscene/tovrmlx3d.exe --encoding xml "InputDir73/lily 7_3_animate.wrl" > "InputDir73/lily 7_3_animate.x3d"

#echo  copy "InputDir73/lily 7_3_animate.x3d" over to X3DJSONLD/src/main/data and run a translation in the shell folder,
#echo  bash several.sh "../data/lily 7_3_animate.x3d"
# npx x3d-tidy -i `pwd`"/InputDir73/lily 7_3_animate.x3d" -o `pwd`"/InputDir73/lily 7_3_animate.x3dj"
#egrep 'l_carpal_proximal_interphalangeal_5|l_carpal_distal_interphalangeal_5|r_metatarsophalangeal_2|l_metatarsophalangeal_2|r_carpal_proximal_interphalangeal_5|r_carpal_distal_interphalangeal_5' "InputDir73/lily 7_3_animate.json" "InputDir73/lily 7_3_animate.wrl" "InputDir73/lily 7_3_animate.x3d" | grep -v KEY
npx x3d-tidy@1.0.91 -i `pwd`"/InputDir73/lily 7_3_animate.wrl" -o `pwd`"/InputDir73/lily 7_3_animate.x3d"
npx x3d-tidy@1.0.91 -i `pwd`"/InputDir73/lily 7_3_animate.wrl" -o `pwd`"/InputDir73/lily 7_3_animate.x3dj"
egrep 'l_carpal_proximal_interphalangeal_5|l_carpal_distal_interphalangeal_5|r_metatarsophalangeal_2|l_metatarsophalangeal_2|r_carpal_proximal_interphalangeal_5|r_carpal_distal_interphalangeal_5' "InputDir73/lily 7_3_animate.x3dj" "InputDir73/lily 7_3_animate.wrl" "InputDir73/lily 7_3_animate.x3d" | grep -v KEY
# npx x3d-tidy -i `pwd`/"OldTemplate.x3dv" -o `pwd`"/OldTemplate.x3dj"
# egrep 'l_carpal_proximal_interphalangeal_5|l_carpal_distal_interphalangeal_5|r_metatarsophalangeal_2|l_metatarsophalangeal_2|r_carpal_proximal_interphalangeal_5|r_carpal_distal_interphalangeal_5' OldTemplate.x3dv OldTemplate.x3dj
