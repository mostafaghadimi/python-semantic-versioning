#!/bin/bash
set -e

DRY_RUN=${INPUT_DRY_RUN:-false}
BRANCH=${INPUT_BRANCH:-main}
PRERELEASE=${INPUT_PRERELEASE:-false}
SEMANTIC_RELEASE_CONFIG=${INPUT_SEMANTIC_RELEASE_CONFIG:-python-semantic-release-config.toml}

git config --global --add safe.directory /github/workspace
git config --global user.name "${INPUT_COMMIT_AUTHOR%% *}"
git config --global user.email "${INPUT_COMMIT_AUTHOR##* }"

cd /github/workspace

echo "released=false" >> $GITHUB_OUTPUT
echo "version=" >> $GITHUB_OUTPUT
echo "tag=" >> $GITHUB_OUTPUT

echo "🚀 Starting semantic release..."

if [[ "$DRY_RUN" == "true" ]]; then
  echo "Running semantic-release in dry-run mode..."
  output=$(uv run semantic-release --dry-run --config /action/$SEMANTIC_RELEASE_CONFIG version 2>&1) || true
  echo "$output"
  
  if echo "$output" | grep -q "would be released"; then
    version=$(echo "$output" | grep -oP "would be released as \K[0-9]+\.[0-9]+\.[0-9]+") || true
    if [[ -n "$version" ]]; then
      echo "version=$version" >> $GITHUB_OUTPUT
      echo "tag=v$version" >> $GITHUB_OUTPUT
      echo "released=true" >> $GITHUB_OUTPUT
      echo "✅ Would create release v$version"
    fi
  fi
else
  echo "Running semantic-release..."
  set +e
  output=$(uv run semantic-release --config /action/$SEMANTIC_RELEASE_CONFIG version 2>&1)
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
    fi
  else
    echo "❌ Semantic-release failed with exit code $exit_code"
    exit $exit_code
  fi
fi

echo "🎉 Semantic release completed!"
