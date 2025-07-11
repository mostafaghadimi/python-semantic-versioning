#!/bin/bash
set -e

echo "Debug: Current directory and files:"
echo "PWD: $PWD"
ls -lah

echo "Debug: GitHub workspace contents:"
echo "GITHUB_WORKSPACE: $GITHUB_WORKSPACE"
ls -lah "$GITHUB_WORKSPACE" 2>/dev/null || echo "Failed to list workspace contents"

# Environment variables
DRY_RUN=${INPUT_DRY_RUN:-false}
BRANCH=${INPUT_BRANCH:-main}
PRERELEASE=${INPUT_PRERELEASE:-false}
SEMANTIC_RELEASE_CONFIG=${INPUT_SEMANTIC_RELEASE_CONFIG:-/app/python-semantic-release-config.toml}

# Git configuration
git config --global --add safe.directory "$GITHUB_WORKSPACE"
git config --global user.name "${INPUT_COMMIT_AUTHOR%% *}"
git config --global user.email "${INPUT_COMMIT_AUTHOR##* }"

echo "Debug: Changing to workspace directory..."
cd "$GITHUB_WORKSPACE"

# Check if this is actually a git repository
if [ ! -d ".git" ]; then
    echo "❌ ERROR: No .git directory found in $GITHUB_WORKSPACE"
    echo "This suggests the repository was not properly checked out."
    echo "Make sure your workflow includes 'actions/checkout@v4' before calling this action."
    echo ""
    echo "Example workflow step:"
    echo "  - name: Checkout code"
    echo "    uses: actions/checkout@v4"
    echo "    with:"
    echo "      fetch-depth: 0"
    echo ""
    exit 1
fi

# Check if this is a shallow clone which is not supported
if [ -f ".git/shallow" ]; then
    echo "❌ ERROR: The repository is a shallow clone."
    echo "semantic-release requires a full git history to determine the version."
    echo "Please fetch the full history by setting 'fetch-depth: 0' in your checkout action."
    echo ""
    echo "Example:"
    echo "  - uses: actions/checkout@v4"
    echo "    with:"
    echo "      fetch-depth: 0"
    echo ""
    exit 1
fi

echo "Debug: Git repository status:"
git status || echo "Git status failed"
git log --oneline -5 || echo "Git log failed"
git remote -v || echo "Git remote failed"

# Check if repository has any tags and create initial one if needed
echo "Debug: Checking for existing tags..."
existing_tags=$(git tag -l)
if [ -z "$existing_tags" ]; then
    echo "⚠️ No tags found in repository. Creating initial tag v0.0.0..."
    echo "This is required for semantic-release to work properly."
    
    # Create initial tag
    git tag v0.0.0
    
    # Only push if we have a remote and we're in CI
    if git remote get-url origin >/dev/null 2>&1 && [ -n "${GITHUB_ACTIONS:-}" ]; then
        git push origin v0.0.0 || echo "Warning: Failed to push initial tag"
    fi
    
    echo "✅ Created initial tag v0.0.0"
else
    echo "✅ Found existing tags:"
    echo "$existing_tags" | head -5
    if [ $(echo "$existing_tags" | wc -l) -gt 5 ]; then
        echo "... and $(( $(echo "$existing_tags" | wc -l) - 5 )) more"
    fi
fi

# Set up GitHub token for releases (only in GitHub Actions)
if [ -n "${INPUT_GH_TOKEN:-}" ]; then
    export GH_TOKEN="${INPUT_GH_TOKEN}"
    echo "✅ GitHub token configured for releases"
elif [ -n "${GITHUB_ACTIONS:-}" ]; then
    echo "⚠️ Warning: No GitHub token provided. Releases may not work."
fi

# Initialize outputs
echo "released=false" >> $GITHUB_OUTPUT
echo "version=" >> $GITHUB_OUTPUT
echo "tag=" >> $GITHUB_OUTPUT

echo "🚀 Starting semantic release..."

if [[ "$DRY_RUN" == "true" ]]; then
  echo "Running semantic-release in dry-run mode..."
  output=$(PYTHONPATH=/app /app/.venv/bin/semantic-release -vv --dry-run --config $SEMANTIC_RELEASE_CONFIG version 2>&1) || true
  echo "$output"
  
  if echo "$output" | grep -q "would be released"; then
    version=$(echo "$output" | grep -oP "would be released as \K[0-9]+\.[0-9]+\.[0-9]+") || true
    if [[ -n "$version" ]]; then
      echo "version=$version" >> $GITHUB_OUTPUT
      echo "tag=v$version" >> $GITHUB_OUTPUT
      echo "released=true" >> $GITHUB_OUTPUT
      echo "✅ Would create release v$version"
    fi
  else
    echo "ℹ️ No release would be made - no significant changes since last release"
  fi
else
  echo "Running semantic-release..."
  set +e
  output=$(PYTHONPATH=/app /app/.venv/bin/semantic-release -vv --config $SEMANTIC_RELEASE_CONFIG version 2>&1)
  exit_code=$?
  set -e
  
  echo "$output"
  
  if [[ $exit_code -eq 0 ]]; then
    if echo "$output" | grep -q "Creating release"; then
      version=$(echo "$output" | grep -oP "Creating release v\K[0-9]+\.[0-9]+\.[0-9]+") || true
      if [[ -n "$version" ]]; then
        echo "version=$version" >> $GITHUB_OUTPUT
        echo "tag=v$version" >> $GITHUB_OUTPUT
        echo "released=true" >> $GITHUB_OUTPUT
        echo "✅ Successfully created release v$version"
      fi
    elif echo "$output" | grep -q "No release will be made"; then
      echo "ℹ️ No release needed - no significant changes since last release"
    else
      echo "✅ Semantic-release completed successfully"
    fi
  else
    echo "❌ Semantic-release failed with exit code $exit_code"
    echo "This might be due to:"
    echo "- No significant changes since last release"
    echo "- Missing GitHub token for creating releases"
    echo "- Repository permission issues"
    exit $exit_code
  fi
fi

echo "🎉 Semantic release completed!"
