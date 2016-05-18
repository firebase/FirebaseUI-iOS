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

set -e # Exit sub shell if anything erro
DIR="$(cd "$(dirname "$0")"; pwd)"
OUTPUT_DIR="${DIR}/target/"
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

echo "===> Building Auth lib"
${XCODEBUILD} \
  -project ${XCODE_PROJECT} \
  -target Auth \
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

# Currently the facebook pod "builds"
# but it's not actually creating targets
# since I had to remove the libPods.a target.
# We should pull in the loginkit, corekit, and bolts
# framework for it to depend on from somewhere else.
echo "===> Building Facebook lib"
${XCODEBUILD} \
  -project ${XCODE_PROJECT} \
  -target Facebook \
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

echo "===> Building Google lib"
${XCODEBUILD} \
  -project ${XCODE_PROJECT} \
  -target Google \
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

# Each of these should also have simulator binaries

# Package all of these into "framework" folders

# Create modulemaps for each of these and add to the framework
