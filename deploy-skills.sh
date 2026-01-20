#!/bin/bash

# deploy-skills.sh
# Deploys skills from this repository to external agent directories via Symlinks.
# This makes this repository the "Master Source" for all your AI agents.

set -e

# Master source directory (Resolved dynamically)
SOURCE_REPO_PWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_AGENT_DIR="$SOURCE_REPO_PWD/.agent"
SOURCE_SKILLS_DIR="$SOURCE_AGENT_DIR/skills"

# Check if a custom target is provided
CUSTOM_TARGET="$1"

echo "============================================"
echo "      Agent Skills Deployment Utility       "
echo "============================================"
echo "Master Source: $SOURCE_AGENT_DIR"
echo "============================================"
echo ""

# Function to deploy skills only (for Agents like Claude/Cursor)
deploy_skills_only() {
  local target_name="$1"
  local target_path="$2"

  echo "Deploying [Skills] to [$target_name]..."
  echo "  Target: $target_path"

  # 1. Create target directory if it doesn't exist
  if [ ! -d "$target_path" ]; then
    echo "  -> Directory not found. Creating: $target_path"
    mkdir -p "$target_path"
  fi

  # 2. Iterate through each skill in the source folder
  for skill_path in "$SOURCE_SKILLS_DIR"/*; do
    if [ -d "$skill_path" ]; then
      skill_name=$(basename "$skill_path")
      
      # Skip _common and private/hidden folders
      if [[ "$skill_name" == _* ]] || [[ "$skill_name" == .* ]]; then
        continue
      fi

      target_skill_link="$target_path/$skill_name"
      update_symlink "$skill_path" "$target_skill_link"
    fi
  done
  echo ""
}

# Function to deploy the whole .agent structure (for Custom Projects)
deploy_agent_structure() {
  local target_name="$1"
  local target_path="$2" # This is the project root, e.g. ./my-project

  echo "Deploying [.agent structure] to [$target_name]..."
  echo "  Project Root: $target_path"
  
  target_agent_dir="$target_path/.agent"

  if [ ! -d "$target_agent_dir" ]; then
    echo "  -> .agent directory not found. Linking entire .agent folder..."
    echo "     (Ideally we link the folder itself, but for safety lets verify)"
    # Link the whole .agent folder
    update_symlink "$SOURCE_AGENT_DIR" "$target_agent_dir"
  else
    echo "  -> .agent directory exists. Linking sub-components (skills, workflows, rules)..."
    
    # Link sub-folders inside .agent
    for item in "skills" "workflows" "rules"; do
      source_item="$SOURCE_AGENT_DIR/$item"
      target_item="$target_agent_dir/$item"
      
      if [ -d "$source_item" ]; then
        if [ -d "$target_item" ] && [ ! -L "$target_item" ]; then
             echo "    - [WARNING] $target_item is a real directory. Skipping. (Consolidate manually if needed)"
        else
             update_symlink "$source_item" "$target_item"
        fi
      fi
    done
  fi
  echo ""
}

# Helper to safely create/update symlink
update_symlink() {
  local source="$1"
  local target="$2"
  local name=$(basename "$target")

  if [ -L "$target" ]; then
    current_source=$(readlink "$target")
    if [ "$current_source" == "$source" ]; then
      echo "    - [OK] $name is already linked."
    else
      echo "    - [UPDATE] Relinking $name..."
      rm "$target"
      ln -s "$source" "$target"
    fi
  elif [ -e "$target" ]; then
     echo "    - [WARNING] $name exists as a real file/dir. SKIPPING."
  else
     ln -s "$source" "$target"
     echo "    - [LINKED] $name -> $source"
  fi
}

if [ -n "$CUSTOM_TARGET" ]; then
  # Deploy to the custom target provided by the user (Project Mode)
  # Convert relative path to absolute
  if [[ "$CUSTOM_TARGET" != /* ]]; then
    CUSTOM_TARGET="$(pwd)/$CUSTOM_TARGET"
  fi
  deploy_agent_structure "Custom Project" "$CUSTOM_TARGET"
else
  # Default: Deploy to all known agents (Skills Only Mode)
  # List of Target Agents and their Skill Directories
  # Format: "Agent Name|Path"
  TARGETS=(
    "OpenCode|$HOME/.config/opencode/skills"
    "Claude Code|$HOME/.claude/skills"
    "Cursor|$HOME/.cursor/skills"
    "Gemini CLI|$HOME/.gemini/skills"
    "Antigravity|$HOME/.gemini/antigravity/skills"
    "GitHub Copilot|$HOME/.copilot/skills"
    "Windsurf|$HOME/.codeium/windsurf/skills"
  )

  for target in "${TARGETS[@]}"; do
    IFS='|' read -r AGENT_NAME TARGET_PATH <<< "$target"
    deploy_skills_only "$AGENT_NAME" "$TARGET_PATH"
  done
fi

echo "============================================"
echo "Deployment Complete!"
echo "All agents should now see your latest skills."
