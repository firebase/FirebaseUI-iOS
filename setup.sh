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
set -o nounset
set -e

# SDK URLs
FIREBASE_SDK_URL="https://cdn.firebase.com/ObjC/Firebase.framework-LATEST.zip"

# Script directories
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SDK_DIR="$SCRIPT_DIR/sdk"

FIREBASE_SDK_ZIP_FILE="$SDK_DIR/firebase-sdk.zip"
FIREBASE_SDK_DIR="$SCRIPT_DIR/sdk/Firebase.framework"

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

echo "All done..." 1>&2
