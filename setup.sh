#!/bin/bash
set -o nounset
set -e

# SDK URLs
FIREBASE_SDK_URL="https://cdn.firebase.com/ObjC/Firebase.framework-LATEST.zip"
GOOGLE_SDK_URL="https://developers.google.com/identity/sign-in/ios/sdk/google_signin_sdk_2_2_0.zip"

# Script directories
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SDK_DIR="$SCRIPT_DIR/sdk"

FIREBASE_SDK_ZIP_FILE="$SDK_DIR/firebase-sdk.zip"
FIREBASE_SDK_DIR="$SCRIPT_DIR/sdk/Firebase.framework"
GOOGLE_SDK_ZIP_FILE="$SDK_DIR/google-sdk.zip"
GOOGLE_SDK_DIR="$SCRIPT_DIR/sdk/google_signin_sdk_2_2_0"

echo "$SDK_DIR"

mkdir -p "$SDK_DIR"

# Firebase Setup
if [ -f "$FIREBASE_SDK_ZIP_FILE" ]; then
    echo "Firebase zip already present. Skipping download..." 1>&2
else
    echo "Downloading Firebase SDK..." 1>&2
    curl "$FIREBASE_SDK_URL" -o "$FIREBASE_SDK_ZIP_FILE"
fi


if [ -d "$FIREBASE_SDK_DIR" ]; then
    echo "Firebase SDK already installed" 1>&2
else
    echo "Extracting Firebase SDK..." 1>&2
    unzip "$FIREBASE_SDK_ZIP_FILE" -d "$SDK_DIR"
fi

# Google Setup
if [ -f "$GOOGLE_SDK_ZIP_FILE" ]; then
    echo "Google zip already present. Skipping download..." 1>&2
else
    echo "Downloading Google SDK..." 1>&2
    curl "$GOOGLE_SDK_URL" -o "$GOOGLE_SDK_ZIP_FILE"
fi


if [ -d "$GOOGLE_SDK_DIR" ]; then
    echo "Google SDK already installed" 1>&2
else
    echo "Extracting Google SDK..." 1>&2
    unzip "$GOOGLE_SDK_ZIP_FILE" -d "$SDK_DIR"
    echo "=========="
    pwd
    mv -r "$GOOGLE_SDK_DIR/*" "$SDK_DIR"
fi

echo "All done..." 1>&2
