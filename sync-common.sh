#!/bin/bash

# sync-common.sh
# Manages shared resources within the agent-skills repository.
# Can symlink or copy files from skills/_common to specific skill directories.

set -e

COMMON_DIR=".agent/skills/_common"
MODE="symlink" # Default mode

# Helper: Print usage
usage() {
  echo "Usage: $0 [skill_name] [--copy]"
  echo ""
  echo "Arguments:"
  echo "  skill_name    The name of the skill directory (e.g., nextjs-security-scan)."
  echo "  --copy        Copy files instead of symlinking (useful for export)."
  echo ""
  echo "Examples:"
  echo "  $0 nextjs-security-scan          # Symlink _common files to nextjs-security-scan"
  echo "  $0 nextjs-security-scan --copy   # Copy _common files to nextjs-security-scan"
  exit 1
}

# Parse arguments
if [ -z "$1" ]; then
  usage
fi

SKILL_NAME="$1"
TARGET_DIR=".agent/skills/$SKILL_NAME"

# Check if target skill exists
if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: Skill directory '$TARGET_DIR' does not exist."
  exit 1
fi

if [ "$2" == "--copy" ]; then
  MODE="copy"
fi

echo "Syncing common resources to $TARGET_DIR in $MODE mode..."

# Define common resources mapping
# Format: "common_file_path:target_relative_path"
# Currently empty as we are just setting up the infrastructure
# Example: RESOURCES=("audit.sh:scripts/audit.sh")
RESOURCES=()

# Example logic for when resources are added (commented out for now)
# for res in "${RESOURCES[@]}"; do
#   IFS=':' read -r src dest <<< "$res"
#   SRC_PATH="$COMMON_DIR/$src"
#   DEST_PATH="$TARGET_DIR/$dest"
#   
#   if [ "$MODE" == "symlink" ]; then
#      # Create relative symlink
#      # ... logic to calculate relative path ...
#      ln -sf "$(realpath --relative-to="$(dirname "$DEST_PATH")" "$SRC_PATH")" "$DEST_PATH"
#   else
#      cp -r "$SRC_PATH" "$DEST_PATH"
#   fi
# done

echo "Done. (No resources defined yet, but infrastructure is ready)"
