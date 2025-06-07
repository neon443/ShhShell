#!/bin/sh

#  ci_post_clone.sh
#  ShhShell
#
#  Created by neon443 on 07/06/2025.
#  

#working dir starts at /Volumes/workspace/repository/ci_scripts
cd ..
cd Frameworks
wget -O frameworks.zip https://files.catbox.moe/8094yg.zip
unzip frameworks.zip
rm frameworks.zip
