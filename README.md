# DataBurst Python Semantic Versioning

A GitHub Action for automated semantic versioning using custom emoji commit parser. This action automatically determines the next version based on conventional commits and creates releases.

## Features

- 🚀 **Automated versioning** based on conventional commits
- 🎯 **Custom emoji parser** for commit analysis
- 📦 **pyproject.toml integration** - automatically updates version after release
- 🔄 **Git tag management** - creates and pushes version tags
- 🎭 **Dry-run mode** for testing without making changes
- 🐛 **Debug mode** for troubleshooting
- 📤 **GitHub releases** - creates releases with changelog
- 🔄 **Automatic version sync** - commits updated pyproject.toml with new version

## Quick Start

### Basic Usage

```yaml
name: Release

on:
  push:
    branches: [main]

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ secrets.GH_TOKEN }}


      - name: DataBurst Python Semantic Versioning
        uses: mostafaghadimi/python-semantic-versioning@v2.2.5
        with:
          gh_token: ${{ secrets.GH_TOKEN }}
```

### Advanced Usage

```yaml
name: Release

on:
  push:
    branches: [main, develop]

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ secrets.GH_TOKEN }}

      - name: DataBurst Python Semantic Versioning
        uses: mostafaghadimi/python-semantic-versioning@v2.2.5
        id: semantic-release
        with:
          gh_token: ${{ secrets.GH_TOKEN }}
          dry_run: 'false'
          branch: 'main'
          prerelease: 'false'
          commit_author: 'github-actions[bot] <github-actions[bot]@users.noreply.github.com>'
          debug: 'false'

      - name: Use release outputs
        if: steps.semantic-release.outputs.released == 'true'
        run: |
          echo "New version: ${{ steps.semantic-release.outputs.version }}"
          echo "New tag: ${{ steps.semantic-release.outputs.tag }}"
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `gh_token` | GitHub token with write permissions to push releases and tags | ✅ Yes | - |
| `dry_run` | Perform a dry run without making changes | ❌ No | `false` |
| `branch` | Branch to release from | ❌ No | `main` |
| `prerelease` | Create a prerelease | ❌ No | `false` |
| `commit_author` | Commit author for release commits | ❌ No | `github-actions[bot] <github-actions[bot]@users.noreply.github.com>` |
| `semantic_release_config` | Semantic release config file name | ❌ No | `/app/python-semantic-release-config.toml` |
| `debug` | Enable debug output | ❌ No | `false` |

## Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `version` | The new version number | `1.2.3` |
| `released` | Whether a new release was created | `true` or `false` |
| `tag` | The new git tag | `v1.2.3` |

## Commit Convention

This action uses a custom emoji-based commit parser. Your commits should follow this pattern:

> **Note**: After a successful release, the action will automatically update your `pyproject.toml` version and commit the change to keep it in sync with your git tags.

### Version Bumps

- 🚀 **Major version** (breaking changes): `🚀 feat: breaking change`
- ✨ **Minor version** (new features): `✨ feat: new feature`
- 🐛 **Patch version** (bug fixes): `🐛 fix: bug fix`

### Other Commits

- 📝 **Documentation**: `📝 docs: update README`
- ♻️ **Refactoring**: `♻️ refactor: improve code structure`
- ⚡ **Performance**: `⚡ perf: optimize algorithm`
- 🧪 **Tests**: `🧪 test: add unit tests`

## Examples

### Basic Release Workflow

```yaml
name: Release

on:
  push:
    branches: [main]

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ secrets.GH_TOKEN }}

      - name: DataBurst Python Semantic Versioning
        uses: mostafaghadimi/python-semantic-versioning@v2.2.5
        with:
          gh_token: ${{ secrets.GH_TOKEN }}
```

### Dry Run Testing

```yaml
- name: Test Release (Dry Run)
  uses: mostafaghadimi/python-semantic-versioning@v2.2.5
  with:
    gh_token: ${{ secrets.GH_TOKEN }}
    dry_run: 'true'
    debug: 'true'
```

### Prerelease Workflow

```yaml
- name: Create Prerelease
  uses: mostafaghadimi/python-semantic-versioning@v2.2.5
  with:
    gh_token: ${{ secrets.GH_TOKEN }}
    prerelease: 'true'
    branch: 'develop'
```

### Using Outputs

```yaml
- name: DataBurst Python Semantic Versioning
  uses: mostafaghadimi/python-semantic-versioning@v2.2.5
  id: semantic-release
  with:
    gh_token: ${{ secrets.GH_TOKEN }}

- name: Deploy if new release
  if: steps.semantic-release.outputs.released == 'true'
  run: |
    echo "Deploying version ${{ steps.semantic-release.outputs.version }}"
    # Your deployment logic here

- name: Notify team
  if: steps.semantic-release.outputs.released == 'true'
  run: |
    echo "New release: ${{ steps.semantic-release.outputs.tag }}"
    # Your notification logic here
```

## Configuration

### Repository Settings

1. **Workflow Permissions**: Go to your repository → Settings → Actions → General → Workflow permissions
   - Set to "Read and write permissions"
   - Enable "Allow GitHub Actions to create and approve pull requests"

2. **Token Setup**: Use either:
   - **Default `GH_TOKEN`** (recommended for most cases)
   - **Personal Access Token** (if you need more permissions)

### pyproject.toml Integration

The action automatically updates your `pyproject.toml` file after a successful release and commits the change:

```toml
[project]
name = "my-package"
version = "1.0.0"  # This gets updated automatically to match the new release
description = "My awesome package"
```

**What happens after a release:**

1. ✅ Creates the new version tag and GitHub release
2. ✅ Updates the version in `pyproject.toml` to match the new release
3. ✅ Commits and pushes the updated `pyproject.toml` with `[skip ci]` to prevent loops
4. ✅ Keeps your package version in sync with your git tags

**Example commit message:**

```bash
:bookmark: chore: bump version to 1.2.3 [skip ci]
```

## Troubleshooting

### Common Issues

#### 1. "SHA could not be resolved" Error

**Cause**: Shallow git clone
**Solution**: Add `fetch-depth: 0` to your checkout action

```yaml
- name: Checkout code
  uses: actions/checkout@v4
  with:
    fetch-depth: 0
    token: ${{ secrets.GH_TOKEN }}
```

#### 2. "Write access to repository not granted" Error

**Cause**: Token doesn't have write permissions
**Solution**:

- For `GH_TOKEN`: Enable write permissions in repository settings
- For custom token: Ensure it has `repo` scope

#### 3. "No GitHub token provided" Warning

**Cause**: Token not passed correctly
**Solution**: Use `with:` instead of `env:`

```yaml
# ❌ Wrong
env:
  gh_token: ${{ secrets.GH_TOKEN }}

# ✅ Correct
with:
  gh_token: ${{ secrets.GH_TOKEN }}
```

#### 4. "GitPushError: Failed to push branch (main) to remote"

> stderr: 'remote: Write access to repository not granted.
> fatal: unable to access
> The requested URL returned error: 403'

Add `token` to checkout action as input.

```yaml
      - name: Checkout repo
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ secrets.GH_TOKEN }}  # This line
```

### Debug Mode

Enable debug output to troubleshoot issues:

```yaml
- name: DataBurst Python Semantic Versioning
  uses: mostafaghadimi/python-semantic-versioning@v2.2.5
  with:
    gh_token: ${{ secrets.GH_TOKEN }}
    debug: 'true'
```

## Version Bumping Rules

| Commit Type | Emoji | Version Bump | Example |
|-------------|-------|--------------|---------|
| Breaking Change | 🚀 | Major (1.0.0 → 2.0.0) | `🚀 feat: breaking API change` |
| New Feature | ✨ | Minor (1.0.0 → 1.1.0) | `✨ feat: add new endpoint` |
| Bug Fix | 🐛 | Patch (1.0.0 → 1.0.1) | `🐛 fix: resolve login issue` |
| Documentation | 📝 | None | `📝 docs: update README` |
| Refactoring | ♻️ | None | `♻️ refactor: improve code` |

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
