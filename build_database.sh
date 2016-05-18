# Copyright 2016 Google Inc. All Rights Reserved.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#!/bin/bash

set -e # Exit sub shell if anything errors
DIR="$(cd "$(dirname "$0")"; pwd)"
OUTPUT_DIR="${DIR}/target"
XCODE_PROJECT="${DIR}/FirebaseUI.xcodeproj"
XCODEBUILD=xcodebuild

echo "===> Cleaning target directory"
rm -rf $OUTPUT_DIR

echo "===> Building Database lib"
${XCODEBUILD} \
  -project ${XCODE_PROJECT} \
  -target Database \
  -configuration Release \
  -sdk iphoneos \
  BUILD_DIR=${OUTPUT_DIR}/Products \
  OBJROOT=${OUTPUT_DIR}/Intermediates \
  BUILD_ROOT=${OUTPUT_DIR} \
  SYMROOT=${OUTPUT_DIR} \
  IPHONEOS_DEPLOYMENT_TARGET=7.0 \
  ONLY_ACTIVE_ARCH=NO \
  ARCHS="armv7 armv7s arm64" \
  GCC_PREPROCESSOR_DEFINITIONS='${inherited}' \
  build

echo "===> Building database simulator lib"
${XCODEBUILD} \
  -project ${XCODE_PROJECT} \
  -target Database \
  -configuration Release \
  -sdk iphonesimulator \
  BUILD_DIR=${OUTPUT_DIR}/Products \
  OBJROOT=${OUTPUT_DIR}/Intermediates \
  BUILD_ROOT=${OUTPUT_DIR} \
  SYMROOT=${OUTPUT_DIR} \
  IPHONEOS_DEPLOYMENT_TARGET=7.0 \
  ONLY_ACTIVE_ARCH=NO \
  ARCHS="i386 x86_64" \
  GCC_PREPROCESSOR_DEFINITIONS='${inherited}'\
  build

echo "===> Using simulator binary as base project for headers and directory structure"
mkdir -p ${OUTPUT_DIR}/Products/Release-combined/FirebaseDatabaseUI.framework/{Headers,Modules}

echo -n "===> Combining all binaries into one ..."
lipo \
  -create \
    ${OUTPUT_DIR}/Products/Release-iphoneos/libDatabase.a \
    ${OUTPUT_DIR}/Products/Release-iphonesimulator/libDatabase.a \
  -output ${OUTPUT_DIR}/Products/Release-combined/FirebaseDatabaseUI.framework/FirebaseDatabaseUI
echo " done."

echo "===> Copying header files over"
cp ${DIR}/FirebaseUI/Database/API/*.h ${OUTPUT_DIR}/Products/Release-combined/FirebaseDatabaseUI.framework/Headers

echo "===> Copying modulemap"
cp ${DIR}/FirebaseUI/Database/API/module.modulemap ${OUTPUT_DIR}/Products/Release-combined/FirebaseDatabaseUI.framework/Modules

echo -n "===> Checking how the final binary looks ..."
EXPECTEDCOUNT=6
ARCHCOUNT=$(file ${OUTPUT_DIR}/Products/Release-combined/FirebaseDatabaseUI.framework/FirebaseDatabaseUI | wc -l)
if [[ $ARCHCOUNT -ne $EXPECTEDCOUNT ]]; then
  echo " bad."
  file ${OUTPUT_DIR}/Products/Release-combined/FirebaseDatabaseUI.framework/FirebaseDatabaseUI
  echo "===> The architecture count ($ARCHCOUNT) looks wrong. It should be $EXPECTEDCOUNT.";
  exit 1
else
  echo " good."
fi
