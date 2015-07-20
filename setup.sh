#!/bin/bash
set -o nounset
set -e

FIREBASE_SDK_URL="https://cdn.firebase.com/ObjC/Firebase.framework-LATEST.zip"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SDK_DIR="$SCRIPT_DIR/sdk"
FIREBASE_SDK_ZIP_FILE="$SDK_DIR/firebase-sdk.zip"
FIREBASE_SDK_DIR="$SCRIPT_DIR/sdk/Firebase.framework"

echo "$SDK_DIR"

mkdir -p "$SDK_DIR"

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

echo "All done..." 1>&2
