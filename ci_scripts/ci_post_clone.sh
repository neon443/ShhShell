#!/bin/sh

#  ci_post_clone.sh
#  ShhShell
#
#  Created by neon443 on 07/06/2025.
#  

#working dir starts at /Volumes/workspace/repository/ci_scripts
cd ..
git submodule init
rm -rf SwiftTerm
git clone https://github.com/neon443/SwiftTerm -b jelly
mkdir Frameworks; cd Frameworks
curl -o frameworks.tar.xz https://files.catbox.moe/buydq9.xz
tar xzf frameworks.tar.xz
rm frameworks.tar.xz
