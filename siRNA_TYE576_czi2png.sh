#! /bin/bash

#if [[ "$1" -eq '-h' ]]
#then
#    echo "Usage: siRNA_TYE567 {czi} where czi is a fluorescence image from a Zeiss microscope with the fluorescence in the second channel.\nNote that this will open an interactive session."
#else
    mkdir -p Images
   fiji -macro ~/bin/siRNA_TYE576_czi2png.ijm $1 2> /dev/null # Need some modules that are in fiji
#fi
