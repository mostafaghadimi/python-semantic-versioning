#!/bin/bash
set -e

DEBUG=${INPUT_DEBUG:-false}
DRY_RUN=${INPUT_DRY_RUN:-false}
BRANCH=${INPUT_BRANCH:-main}
PRERELEASE=${INPUT_PRERELEASE:-false}
PRERELEASE_BRANCH=${INPUT_PRERELEASE_BRANCH:-dev}
PRERELEASE_TOKEN=${INPUT_PRERELEASE_TOKEN:-rc}
SEMANTIC_RELEASE_CONFIG=${INPUT_SEMANTIC_RELEASE_CONFIG:-/app/python-semantic-release-config.toml}
export GIT_COMMIT_AUTHOR="${INPUT_COMMIT_AUTHOR}"

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

# Always create a runtime config to handle version file detection
RUNTIME_CONFIG="/tmp/runtime-semantic-release-config.toml"
cp "$SEMANTIC_RELEASE_CONFIG" "$RUNTIME_CONFIG"

# Detect version files and configure semantic-release to manage them natively
# The version_toml setting must be under [tool.semantic_release] section
if [ -f "pyproject.toml" ] && grep -q "^version = " pyproject.toml; then
    echo "📦 Detected pyproject.toml - will be updated automatically"
    # Insert version_toml right after the [tool.semantic_release] header using awk
    awk '/^\[tool\.semantic_release\]$/ { print; print "version_toml = [\"pyproject.toml:project.version\"]"; next } 1' "$RUNTIME_CONFIG" > "${RUNTIME_CONFIG}.tmp" && mv "${RUNTIME_CONFIG}.tmp" "$RUNTIME_CONFIG"
fi

# Add prerelease branch configuration if enabled
if [[ "$PRERELEASE" == "true" ]] && [[ -n "$PRERELEASE_BRANCH" ]] && [[ -n "$PRERELEASE_TOKEN" ]]; then
    echo "📝 Configuring prerelease branch: $PRERELEASE_BRANCH with token: $PRERELEASE_TOKEN"
    
    cat >> "$RUNTIME_CONFIG" << EOF

[tool.semantic_release.branches."$PRERELEASE_BRANCH"]
match = "$PRERELEASE_BRANCH"
prerelease_token = "$PRERELEASE_TOKEN"
prerelease = true
EOF
elif [[ "$PRERELEASE" == "true" ]] && ([[ -z "$PRERELEASE_BRANCH" ]] || [[ -z "$PRERELEASE_TOKEN" ]]); then
    echo "⚠️ Warning: prerelease is enabled but prerelease_branch or prerelease_token is not set."
    echo "   To configure dynamic prerelease, set both 'prerelease_branch' and 'prerelease_token' inputs."
fi

SEMANTIC_RELEASE_CONFIG="$RUNTIME_CONFIG"

if [[ "$DEBUG" == "true" ]]; then
    echo "Debug: Runtime config content:"
    cat "$RUNTIME_CONFIG"
fi

echo "released=false" >> $GITHUB_OUTPUT
echo "version=" >> $GITHUB_OUTPUT
echo "tag=" >> $GITHUB_OUTPUT

echo "🚀 Starting semantic release..."

if [[ "$DRY_RUN" == "true" ]]; then
  echo "Running semantic-release in dry-run mode..."
  output=$(PYTHONPATH=/app /app/.venv/bin/semantic-release -vv --dry-run --config $SEMANTIC_RELEASE_CONFIG version 2>&1) || true
  
  if echo "$output" | grep -q "would be released"; then
    version=$(echo "$output" | grep -oE "would be released as ([0-9]+\.[0-9]+\.[0-9]+)" | sed 's/would be released as //') || true
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
  
  if [[ "$DEBUG" == "true" ]]; then
    echo output: $output
    echo exit_code: $exit_code
  fi

  if [[ $exit_code -eq 0 ]]; then
    if echo "$output" | grep -q "Creating release"; then
      # Extract version from the semantic-release output (e.g., "The next version is: 0.4.6!")
      version=$(echo "$output" | grep -oE "The next version is: ([0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?)" | sed 's/The next version is: //')
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
