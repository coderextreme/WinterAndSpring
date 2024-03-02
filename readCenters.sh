#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

#

# convert  VRML skeleton by multiplying out transforms to create centers without transforms
# by way of X3D JSON

npx x3d-tidy -i `pwd`/Edited0721.x3dv -o `pwd`/Edited0721.x3dj
# node convertJsonToCenters.js < Edited0721.x3dj > Edited0721.centers.txt
unix2dos Edited0721.centers.txt
node convertJsonToCenters.js < `pwd`/Edited0721.x3dj > Edited0721.rotated.txt
unix2dos Edited0721.rotated.txt
