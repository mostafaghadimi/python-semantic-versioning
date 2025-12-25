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

#### Option A: Using GITHUB_TOKEN (Recommended)

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
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: DataBurst Python Semantic Versioning
        uses: mostafaghadimi/python-semantic-versioning@<desired_version>
        with:
          gh_token: ${{ secrets.GITHUB_TOKEN }}
```

#### Option B: Using Personal Access Token

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
        uses: mostafaghadimi/python-semantic-versioning@<desired_version>
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
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: DataBurst Python Semantic Versioning
        uses: mostafaghadimi/python-semantic-versioning@<desired_version>
        id: semantic-release
        with:
          gh_token: ${{ secrets.GITHUB_TOKEN }}
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
| `prerelease_branch` | Branch name for pre-releases (e.g., dev, staging, beta). Only applies when prerelease is true. | ❌ No | `dev` |
| `prerelease_token` | Token/suffix to append to pre-release versions (e.g., rc, alpha, beta). Only applies when prerelease is true. | ❌ No | `rc` |
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

- 🚀 **Major version** (breaking changes): `🚀 feat!: breaking change`
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
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: DataBurst Python Semantic Versioning
        uses: mostafaghadimi/python-semantic-versioning@<desired_version>
        with:
          gh_token: ${{ secrets.GITHUB_TOKEN }}
```

### Dry Run Testing

```yaml
- name: Test Release (Dry Run)
  uses: mostafaghadimi/python-semantic-versioning@<desired_version>
  with:
    gh_token: ${{ secrets.GITHUB_TOKEN }}
    dry_run: 'true'
    debug: 'true'
```

### Prerelease Workflow

**Simple Prerelease (Using Defaults):**

```yaml
name: Pre-Release from Dev Branch

on:
  push:
    branches: [dev]

jobs:
  prerelease:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Create Prerelease with RC suffix
        uses: mostafaghadimi/python-semantic-versioning@<desired_version>
        with:
          gh_token: ${{ secrets.GITHUB_TOKEN }}
          branch: 'dev'
          prerelease: 'true'
          # Uses defaults: prerelease_branch='dev', prerelease_token='rc'
          # Result: v1.2.3-rc.1, v1.2.3-rc.2, etc.
```

**Custom Prerelease Tokens:**

```yaml
# Alpha releases from alpha branch
- name: Create Alpha Release
  uses: mostafaghadimi/python-semantic-versioning@<desired_version>
  with:
    gh_token: ${{ secrets.GITHUB_TOKEN }}
    branch: 'alpha'
    prerelease: 'true'
    prerelease_branch: 'alpha'
    prerelease_token: 'alpha'  # Creates: v1.2.3-alpha.1

# Beta releases from beta branch  
- name: Create Beta Release
  uses: mostafaghadimi/python-semantic-versioning@<desired_version>
  with:
    gh_token: ${{ secrets.GITHUB_TOKEN }}
    branch: 'beta'
    prerelease: 'true'
    prerelease_branch: 'beta'
    prerelease_token: 'beta'  # Creates: v1.2.3-beta.1

# RC releases from staging branch (overriding defaults)
- name: Create RC Release from Staging
  uses: mostafaghadimi/python-semantic-versioning@<desired_version>
  with:
    gh_token: ${{ secrets.GITHUB_TOKEN }}
    branch: 'staging'
    prerelease: 'true'
    prerelease_branch: 'staging'
    prerelease_token: 'rc'  # Creates: v1.2.3-rc.1
```

### Using Outputs

```yaml
- name: DataBurst Python Semantic Versioning
  uses: mostafaghadimi/python-semantic-versioning@<desired_version>
  id: semantic-release
  with:
    gh_token: ${{ secrets.GITHUB_TOKEN }}

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

### Pre-release Configuration

You can configure pre-release branches and their version suffixes dynamically using the action inputs. The action comes with sensible defaults (`dev` branch with `rc` suffix) that you can easily customize.

#### How It Works

When you set `prerelease: 'true'`, the action will:

1. Use your base configuration file
2. Dynamically add/override the pre-release branch configuration at runtime
3. Create versions with your specified token suffix
4. Use defaults (`dev` and `rc`) if you don't provide custom values

#### Default Behavior

The action has built-in defaults for convenience:

- Default `prerelease_branch`: `dev`
- Default `prerelease_token`: `rc`

This means you can simply set `prerelease: 'true'` and get `v1.2.3-rc.1` versions from the `dev` branch without any additional configuration.

#### Examples

**Example 1: Simple Dev Branch with RC Suffix (Using Defaults)**

```yaml
- uses: mostafaghadimi/python-semantic-versioning@<desired_version>
  with:
    gh_token: ${{ secrets.GITHUB_TOKEN }}
    branch: 'dev'
    prerelease: 'true'
    # prerelease_branch defaults to 'dev'
    # prerelease_token defaults to 'rc'
```

Result: `v1.2.3-rc.1`, `v1.2.3-rc.2`, etc.

**Example 2: Staging Branch with Beta Suffix (Custom)**

```yaml
- uses: mostafaghadimi/python-semantic-versioning@<desired_version>
  with:
    gh_token: ${{ secrets.GITHUB_TOKEN }}
    branch: 'staging'
    prerelease: 'true'
    prerelease_branch: 'staging'
    prerelease_token: 'beta'
```

Result: `v1.2.3-beta.1`, `v1.2.3-beta.2`, etc.

**Example 3: Alpha Branch with Alpha Suffix (Custom)**

```yaml
- uses: mostafaghadimi/python-semantic-versioning@<desired_version>
  with:
    gh_token: ${{ secrets.GITHUB_TOKEN }}
    branch: 'alpha'
    prerelease: 'true'
    prerelease_branch: 'alpha'
    prerelease_token: 'alpha'
```

Result: `v1.2.3-alpha.1`, `v1.2.3-alpha.2`, etc.

**Example 4: Standard Release (No Prerelease)**

```yaml
- uses: mostafaghadimi/python-semantic-versioning@<desired_version>
  with:
    gh_token: ${{ secrets.GITHUB_TOKEN }}
    branch: 'main'
    prerelease: 'false'
    # No dynamic configuration generated
```

Result: `v1.2.3`, `v1.2.4`, etc. (standard releases)

#### Multi-Branch Workflow Example

```yaml
name: Release Workflow

on:
  push:
    branches: [main, dev, staging]

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ secrets.GITHUB_TOKEN }}

      # Production release from main
      - name: Production Release
        if: github.ref == 'refs/heads/main'
        uses: mostafaghadimi/python-semantic-versioning@<desired_version>
        with:
          gh_token: ${{ secrets.GITHUB_TOKEN }}
          branch: 'main'
          prerelease: 'false'

      # RC release from dev (using defaults)
      - name: RC Release from Dev
        if: github.ref == 'refs/heads/dev'
        uses: mostafaghadimi/python-semantic-versioning@<desired_version>
        with:
          gh_token: ${{ secrets.GITHUB_TOKEN }}
          branch: 'dev'
          prerelease: 'true'
          # Uses defaults: prerelease_branch='dev', prerelease_token='rc'

      # Beta release from staging (custom config)
      - name: Beta Release from Staging
        if: github.ref == 'refs/heads/staging'
        uses: mostafaghadimi/python-semantic-versioning@<desired_version>
        with:
          gh_token: ${{ secrets.GITHUB_TOKEN }}
          branch: 'staging'
          prerelease: 'true'
          prerelease_branch: 'staging'
          prerelease_token: 'beta'
```

### Repository Settings

1. **Workflow Permissions**: Go to your repository → Settings → Actions → General → Workflow permissions
   - Set to "Read and write permissions"
   - Enable "Allow GitHub Actions to create and approve pull requests"

2. **Token Setup**: Choose one of the following approaches:

   **Option A: GITHUB_TOKEN (Recommended)**
   - Use the default `GITHUB_TOKEN` that GitHub provides automatically
   - No additional setup required
   - Ensure repository has proper workflow permissions enabled
   - Go to repository → Settings → Actions → General → Workflow permissions
   - Set to "Read and write permissions"

   **Option B: Personal Access Token (PAT)**
   - Create a Personal Access Token for more control
   - Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Generate new token with these permissions:
     - ✅ `Contents` (Read and write access to repository contents)
     - ✅ `write:packages` (if you publish packages)
   - Add the token as a repository secret named `GH_TOKEN`
   - Use `${{ secrets.GH_TOKEN }}` in your workflow

   **Comparison:**

   | Aspect | GITHUB_TOKEN | Personal Access Token |
   |--------|--------------|---------------------|
   | Setup | ⚡ Automatic | 🔧 Manual creation |
   | Security | 🛡️ GitHub managed | 🔐 User managed |
   | Permissions | 📋 Limited to repo | 🎯 Contents read/write |
   | Expiration | ❌ Never expires | ⏰ User defined |
   | Use Case | ✅ Most projects | 🔧 Advanced needs |

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
```

#### 2. "Write access to repository not granted" Error

**Cause**: Token doesn't have write permissions
**Solution**:

**For GITHUB_TOKEN:**

- Go to repository → Settings → Actions → General → Workflow permissions
- Set to "Read and write permissions"
- Enable "Allow GitHub Actions to create and approve pull requests"

**For Personal Access Token:**

- Ensure your PAT has `Contents` (Read and write) permissions
- Verify the token is correctly added as `GH_TOKEN` secret

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
          token: ${{ secrets.GITHUB_TOKEN }}  # Option A
          token: ${{ secrets.GH_TOKEN }}  # Option B
```

### Debug Mode

Enable debug output to troubleshoot issues:

```yaml
- name: DataBurst Python Semantic Versioning
  uses: mostafaghadimi/python-semantic-versioning@<desired_version>
  with:
    gh_token: ${{ secrets.GITHUB_TOKEN }}
    debug: 'true'
```

## Version Bumping Rules

| Commit Type | Emoji | Version Bump | Example |
|-------------|-------|--------------|---------|
| Breaking Change | 🚀 | Major (1.0.0 → 2.0.0) | `🚀 feat!: breaking API change` |
| New Feature | ✨ | Minor (1.0.0 → 1.1.0) | `✨ feat: add new endpoint` |
| Bug Fix | 🐛 | Patch (1.0.0 → 1.0.1) | `🐛 fix: resolve login issue` |
| Documentation | 📝 | None | `📝 docs: update README` |
| Refactoring | ♻️ | None | `♻️ refactor: improve code` |

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
