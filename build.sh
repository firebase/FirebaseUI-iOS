#!/bin/bash

set -e # Exit sub shell if anything erro
DIR="$(cd "$(dirname "$0")"; pwd)"
OUTPUT_DIR="${DIR}/target/"
XCODE_PROJECT="${DIR}/FirebaseUI.xcodeproj"
XCODEBUILD=xcodebuild

echo "===> Cleaning target directory"
rm -rf $OUTPUT_DIR

echo "===> Building iOS binary"
${XCODEBUILD} \
  -project ${XCODE_PROJECT} \
  -target FirebaseUI \
  -configuration Release \
  -sdk iphoneos \
  BUILD_DIR=${OUTPUT_DIR}/Products \
  OBJROOT=${OUTPUT_DIR}/Intermediates \
  BUILD_ROOT=${OUTPUT_DIR} \
  SYMROOT=${OUTPUT_DIR} \
  IPHONEOS_DEPLOYMENT_TARGET=7.0 \
  ONLY_ACTIVE_ARCH=NO \
  ARCHS="armv7 armv7s arm64" \
  GCC_PREPROCESSOR_DEFINITIONS='${inherited} LOCAL_BUILD=1 FIREBASE_ENABLE_FACEBOOK_AUTH=1 FIREBASE_ENABLE_GOOGLE_AUTH=1 FIREBASE_ENABLE_TWITTER_AUTH=1 FIREBASE_ENABLE_PASSWORD_AUTH=1'\
  build

echo "===> Building simulator binary"
${XCODEBUILD} \
  -project ${XCODE_PROJECT} \
  -target FirebaseUI \
  -configuration Release \
  -sdk iphonesimulator \
  BUILD_DIR=${OUTPUT_DIR}/Products \
  OBJROOT=${OUTPUT_DIR}/Intermediates \
  BUILD_ROOT=${OUTPUT_DIR} \
  SYMROOT=${OUTPUT_DIR} \
  IPHONEOS_DEPLOYMENT_TARGET=7.0 \
  ONLY_ACTIVE_ARCH=NO \
  ARCHS="i386 x86_64" \
  GCC_PREPROCESSOR_DEFINITIONS='${inherited} LOCAL_BUILD=1 FIREBASE_ENABLE_FACEBOOK_AUTH=1 FIREBASE_ENABLE_GOOGLE_AUTH=1 FIREBASE_ENABLE_TWITTER_AUTH=1 FIREBASE_ENABLE_PASSWORD_AUTH=1'\
  build

echo "===> Using simulator binary as base project for headers and directory structure"
cp -a ${OUTPUT_DIR}/Products/Release-iphonesimulator ${OUTPUT_DIR}/Products/Release-combined

echo -n "===> Combining all binaries into one ..."
lipo \
  -create \
    ${OUTPUT_DIR}/Products/Release-iphoneos/libFirebaseUI.a \
    ${OUTPUT_DIR}/Products/Release-iphonesimulator/libFirebaseUI.a \
  -output ${OUTPUT_DIR}/Products/Release-combined/FirebaseUI.framework/Versions/A/FirebaseUI
echo " done."

echo -n "===> Checking how the final binary looks ..."
EXPECTEDCOUNT=6
ARCHCOUNT=$(file ${OUTPUT_DIR}/Products/Release-combined/FirebaseUI.framework/Versions/A/FirebaseUI | wc -l)
if [[ $ARCHCOUNT -ne $EXPECTEDCOUNT ]]; then
  echo " bad."
  file ${OUTPUT_DIR}/Products/Release-combined/FirebaseUI.framework/Versions/A/FirebaseUI
  echo "===> The architecture count ($ARCHCOUNT) looks wrong. It should be $EXPECTEDCOUNT.";
  exit 1
else
  echo " good."
fi

echo "===> Creating zip of final framework"
pushd ${OUTPUT_DIR}/Products/Release-combined
zip -ry ../../FirebaseUI.framework.zip FirebaseUI.framework
popd

ls -l target/FirebaseUI.framework.zip
