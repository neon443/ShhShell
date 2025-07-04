#!/bin/sh

#  ci_post_clone.sh
#  ShhShell
#
#  Created by neon443 on 07/06/2025.
#  

#working dir starts at /Volumes/workspace/repository/ci_scripts
cd ..
mkdir Frameworks; cd Frameworks
curl -o frameworks.tar.xz https://hc-cdn.hel1.your-objectstorage.com/s/v3/213184c43ae1de48605436829771f04671af4a38_frameworks.tar.xz
tar xzf frameworks.tar.xz
rm frameworks.tar.xz
