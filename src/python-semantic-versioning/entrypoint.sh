#!/bin/bash
set -e

DEBUG=${INPUT_DEBUG:-false}
DRY_RUN=${INPUT_DRY_RUN:-false}
BRANCH=${INPUT_BRANCH:-main}
PRERELEASE=${INPUT_PRERELEASE:-false}
SEMANTIC_RELEASE_CONFIG=${INPUT_SEMANTIC_RELEASE_CONFIG:-/app/python-semantic-release-config.toml}

if [[ "$DEBUG" == "true" ]]; then
    echo "Debug: GitHub workspace contents:"
    ls -lah "$GITHUB_WORKSPACE" 2>/dev/null
fi

git config --global --add safe.directory "$GITHUB_WORKSPACE"
git config --global user.name "${INPUT_COMMIT_AUTHOR%% *}"
git config --global user.email "${INPUT_COMMIT_AUTHOR##* }"

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
    exit $exit_code
  fi
fi

echo "🎉 Semantic release completed!"
