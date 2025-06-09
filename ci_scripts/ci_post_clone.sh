#!/bin/sh

#  ci_post_clone.sh
#  ShhShell
#
#  Created by neon443 on 07/06/2025.
#  

#working dir starts at /Volumes/workspace/repository/ci_scripts
cd CI_PRIMARY_REPOSITORY_PATH
mkdir Frameworks; cd Frameworks
curl -o frameworks.zip https://files.catbox.moe/8094yg.zip
unzip frameworks.zip
rm frameworks.zip
