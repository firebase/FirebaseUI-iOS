#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Generating appledocs..."
appledoc --project-name "FirebaseUI for iOS" \
--project-company "Firebase" \
--company-id com.firebase \
--no-create-docset \
--create-html \
--keep-intermediate \
--output ./docs/output/ \
--templates=./docs/template/ \
--output "$DIR/site/" \
--search-undocumented-doc \
--exit-threshold 2 \
"$DIR"/FirebaseUI/**/API/*.h

echo "Copying docs to FirebaseUI site..."
cp -r site/html/* ../FirebaseUI/docs/ios
