# composite-apt-repo-action
Action to download released debian packages from other github repositories and provide them in a apt repo through github pages.

## Inputs
### `github_token`

**Required** Github token with commit and push scope.

### `github_repositories`

**Required** Newline-delimited list of github repositories to search for new release to deploy to apt repo.

### `file_pattern`

Pattern to define deb files to include in apt repository.

### `target_os_release`

**Required** Newline-delimited list of target OS releases.

### `repo_supported_arch`

**Required** Newline-delimited list of supported architecture.

### `repo_supported_version`

**Required** Newline-delimited list of supported OS versions.

### `public_key`

GPG public key for APT repo.

### `private_key`

**Required** GPG private key for signing APT repo.

### `key_passphrase`

Passphrase of GPG private key.

### `page_branch`

Branch of Github pages. Defaults to `gh-pages`

### `repo_folder`

Location of APT repo folder relative to root of Github pages. Defaults to `repo`

## Example usage
```
uses: malaupa/composite-apt-repo-action@v0.0.1
with:
  github_token: ${{ secrets.GITHUB_TOKEN }}
  github_repositories: |
    <repo-owner>/<repo-slug>
  target_os_release: |
    focal
    jammy
  repo_supported_arch: |
    amd64
    i386
  repo_supported_version: |
    focal
    jammy
  public_key: ${{ secrets.PUBLIC_KEY }}
  private_key: ${{ secrets.PRIVATE_KEY }}
  key_passphrase: "${{ secrets.PASSPHRASE }}
```
