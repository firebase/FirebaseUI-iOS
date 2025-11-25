#!/usr/bin/env bash

# Script to version FirebaseAuthSwiftUI package
# This script will:
# 1. Check we're on main branch with clean working directory
# 2. Get latest git tag
# 3. Prompt for new version
# 4. Update Version.swift
# 5. Commit, tag, and push changes
#
# Usage:
#   ./release-swift.sh           # Normal mode (actually commits and pushes)
#   ./release-swift.sh --dry-run # Dry run mode (simulates without pushing)

set -euo pipefail

# Check for dry-run flag
DRY_RUN=false
if [ "${1:-}" = "--dry-run" ]; then
  DRY_RUN=true
  echo -e "\033[1;33m⚠️  DRY RUN MODE - No changes will be pushed to remote ⚠️\033[0m"
  echo ""
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

VERSION_FILE="FirebaseSwiftUI/FirebaseAuthSwiftUI/Sources/Version.swift"

echo -e "${GREEN}=== FirebaseAuthSwiftUI Version Release Script ===${NC}"
echo ""

# Check if we're on main branch
echo "Checking current branch..."
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
  echo -e "${RED}Error: Not on main branch (currently on: $CURRENT_BRANCH)${NC}"
  echo "Please switch to main branch before running this script."
  exit 1
fi
echo -e "${GREEN}✓ On main branch${NC}"
echo ""

# Check if working directory is clean
echo "Checking working directory status..."
if ! git diff-index --quiet HEAD --; then
  echo -e "${RED}Error: Working directory is not clean${NC}"
  echo "Please commit or stash your changes before running this script."
  echo ""
  echo "Current status:"
  git status --short
  exit 1
fi
echo -e "${GREEN}✓ Working directory is clean${NC}"
echo ""

# Get the latest tag
echo "Fetching latest tags from remote..."
git fetch --tags --quiet

LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [ -z "$LATEST_TAG" ]; then
  echo -e "${YELLOW}No existing tags found${NC}"
  LATEST_VERSION="none"
else
  echo "Latest tag: $LATEST_TAG"
  # Remove 'v' prefix if present
  LATEST_VERSION="${LATEST_TAG#v}"
fi
echo ""

# Prompt for new version
echo -e "${YELLOW}Enter the new version number (e.g., 15.0.2):${NC}"
read -r NEW_VERSION

# Validate semantic versioning format
if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo -e "${RED}Error: Invalid version format${NC}"
  echo "Version must follow semantic versioning (X.Y.Z where X, Y, Z are numbers)"
  exit 1
fi
echo -e "${GREEN}✓ Valid semantic version format${NC}"
echo ""

# Add 'v' prefix and confirm
NEW_TAG="v${NEW_VERSION}"
echo -e "${YELLOW}Version will be tagged as: ${GREEN}${NEW_TAG}${NC}"
echo "Previous version: ${LATEST_VERSION}"
echo ""
echo -e "${YELLOW}Confirm this version? (y/n):${NC}"
read -r CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
  echo -e "${RED}Version release cancelled${NC}"
  exit 0
fi
echo ""

# Check if tag already exists
if git rev-parse "$NEW_TAG" >/dev/null 2>&1; then
  echo -e "${RED}Error: Tag $NEW_TAG already exists${NC}"
  echo "Please choose a different version number."
  exit 1
fi
echo -e "${GREEN}✓ Tag $NEW_TAG does not exist${NC}"
echo ""

# Update Version.swift file
echo "Updating $VERSION_FILE..."
if [ ! -f "$VERSION_FILE" ]; then
  echo -e "${RED}Error: $VERSION_FILE not found${NC}"
  exit 1
fi

# Create backup
cp "$VERSION_FILE" "${VERSION_FILE}.bak"

# Update the version in the file
sed -i.tmp "s/public static let version = \".*\"/public static let version = \"${NEW_VERSION}\"/" "$VERSION_FILE"
rm "${VERSION_FILE}.tmp"

# Show the changes
echo ""
echo -e "${YELLOW}Changes to be committed:${NC}"
echo "---"
git diff "$VERSION_FILE"
echo "---"
echo ""

echo -e "${YELLOW}Proceed with commit, tag, and push? (y/n):${NC}"
read -r FINAL_CONFIRM

if [ "$FINAL_CONFIRM" != "y" ] && [ "$FINAL_CONFIRM" != "Y" ]; then
  echo -e "${YELLOW}Restoring backup and cancelling...${NC}"
  mv "${VERSION_FILE}.bak" "$VERSION_FILE"
  exit 0
fi

# Remove backup
rm "${VERSION_FILE}.bak"

# Commit the changes
echo ""
echo "Committing changes..."
git add "$VERSION_FILE"
git commit -m "chore: update FirebaseAuthSwiftUI version"
echo -e "${GREEN}✓ Changes committed${NC}"
echo ""

# Create annotated tag
echo "Creating annotated tag $NEW_TAG..."
git tag -a "$NEW_TAG" -m "Release $NEW_TAG"
echo -e "${GREEN}✓ Tag created${NC}"
echo ""

if [ "$DRY_RUN" = true ]; then
  echo -e "${YELLOW}DRY RUN: Skipping push operations${NC}"
  echo ""
  echo "Would push:"
  echo "  - Commit to origin/main"
  echo "  - Tag $NEW_TAG to origin"
  echo ""
  echo -e "${YELLOW}Cleaning up (removing commit and tag)...${NC}"
  git tag -d "$NEW_TAG"
  git reset --soft HEAD~1
  git restore --staged "$VERSION_FILE"
  echo -e "${GREEN}✓ Local changes cleaned up${NC}"
  echo ""
  echo -e "${GREEN}=== Dry Run Complete ===${NC}"
  echo "Version: $NEW_VERSION"
  echo "Tag: $NEW_TAG"
  echo ""
  echo "Everything looks good! Run without --dry-run to actually release."
else
  # Push commit
  echo "Pushing commit to remote..."
  git push origin main
  echo -e "${GREEN}✓ Commit pushed${NC}"
  echo ""

  # Push tag
  echo "Pushing tag to remote..."
  git push origin "$NEW_TAG"
  echo -e "${GREEN}✓ Tag pushed${NC}"
  echo ""

  echo -e "${GREEN}=== Release Complete ===${NC}"
  echo "Version: $NEW_VERSION"
  echo "Tag: $NEW_TAG"
  echo ""
  echo "Next steps:"
  echo "1. Verify the tag on GitHub: https://github.com/firebase/FirebaseUI-iOS/releases"
  echo "2. Create release notes if needed"
fi

