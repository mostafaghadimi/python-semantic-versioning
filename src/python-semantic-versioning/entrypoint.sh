#!/bin/bash
set -e

echo "Debug: Current directory and files:"
echo "PWD: $PWD"
ls -lah

echo "Debug: GitHub workspace contents:"
echo "GITHUB_WORKSPACE: $GITHUB_WORKSPACE"
ls -lah "$GITHUB_WORKSPACE" 2>/dev/null || echo "Failed to list workspace contents"

DRY_RUN=${INPUT_DRY_RUN:-false}
BRANCH=${INPUT_BRANCH:-main}
PRERELEASE=${INPUT_PRERELEASE:-false}
SEMANTIC_RELEASE_CONFIG=${INPUT_SEMANTIC_RELEASE_CONFIG:-/app/python-semantic-release-config.toml}

git config --global --add safe.directory "$GITHUB_WORKSPACE"
git config --global user.name "${INPUT_COMMIT_AUTHOR%% *}"
git config --global user.email "${INPUT_COMMIT_AUTHOR##* }"

echo "Debug: Changing to workspace directory..."
cd "$GITHUB_WORKSPACE"

if [ -n "${INPUT_GH_TOKEN:-}" ]; then
    export GH_TOKEN="${INPUT_GH_TOKEN}"
    echo "✅ GitHub token configured for releases"
elif [ -n "${GITHUB_ACTIONS:-}" ]; then
    echo "⚠️ Warning: No GitHub token provided. Releases may not work."
fi

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
