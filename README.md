[![Actions Status: Update bundled\_gems](https://github.com/ruby/actions/workflows/Update%20bundled_gems/badge.svg)](https://github.com/ruby/actions/actions?query=workflow%3A"Update+bundled_gems")
[![Actions Status: coverage](https://github.com/ruby/actions/workflows/coverage/badge.svg)](https://github.com/ruby/actions/actions?query=workflow%3A"coverage")
[![Actions Status: Make HTML for docs.r-l.o\/en\/](https://github.com/ruby/actions/workflows/Make%20HTML%20for%20docs.r-l.o%2Fen%2F/badge.svg)](https://github.com/ruby/actions/actions?query=workflow%3A"Make+HTML+for+docs.r-l.o/en/")
[![Actions Status: doxygen](https://github.com/ruby/actions/workflows/doxygen/badge.svg)](https://github.com/ruby/actions/actions?query=workflow%3A"doxygen")
[![Actions Status: Make draft release package](https://github.com/ruby/actions/workflows/Make%20draft%20release%20package/badge.svg)](https://github.com/ruby/actions/actions?query=workflow%3A"Make+draft+release+package")
[![Actions Status: Remove pub\/tmp\/ruby-\*](https://github.com/ruby/actions/workflows/Remove%20pub%2Ftmp%2Fruby-*/badge.svg)](https://github.com/ruby/actions/actions?query=workflow%3A"Remove+pub/tmp/ruby-*")
[![Actions Status: ruby\_versions](https://github.com/ruby/actions/workflows/ruby_versions/badge.svg)](https://github.com/ruby/actions/actions?query=workflow%3A"ruby_versions")
[![Actions Status: snapshot-master](https://github.com/ruby/actions/workflows/snapshot-master/badge.svg)](https://github.com/ruby/actions/actions?query=workflow%3A"snapshot-master")
[![Actions Status: snapshot-ruby\_3\_3](https://github.com/ruby/actions/workflows/snapshot-ruby_3_3/badge.svg)](https://github.com/ruby/actions/actions?query=workflow%3A"snapshot-ruby_3_3")
[![Actions Status: snapshot-ruby\_3\_4](https://github.com/ruby/actions/workflows/snapshot-ruby_3_4/badge.svg)](https://github.com/ruby/actions/actions?query=workflow%3A"snapshot-ruby_3_4")
[![Actions Status: snapshot-ruby\_4\_0](https://github.com/ruby/actions/workflows/snapshot-ruby_4_0/badge.svg)](https://github.com/ruby/actions/actions?query=workflow%3A"snapshot-ruby_4_0")
[![Actions Status: Test ruby\_versions workflow](https://github.com/ruby/actions/workflows/Test%20ruby_versions%20workflow/badge.svg)](https://github.com/ruby/actions/actions?query=workflow%3A"Test+ruby_versions+workflow")
[![Actions Status: update\_ci\_versions](https://github.com/ruby/actions/workflows/update_ci_versions/badge.svg)](https://github.com/ruby/actions/actions?query=workflow%3A"update_ci_versions")
[![Actions Status: update\_index](https://github.com/ruby/actions/workflows/update_index/badge.svg)](https://github.com/ruby/actions/actions?query=workflow%3A"update_index")

# ruby/actions

This repository hosts GitHub Actions workflows that automate CRuby's release engineering, daily snapshot builds, documentation generation, and CI infrastructure.

For release managers, see <https://bugs.ruby-lang.org/projects/ruby/wiki/HowToReleaseJa>.

# Workflows

| Workflow | Schedule | Description |
|----------|----------|-------------|
| `snapshot-master` | Daily 18:30 UTC | Build a snapshot tarball from the master branch, run tests on Ubuntu/macOS/Windows, and upload to S3 |
| `snapshot-ruby_X_Y` | Daily 18:30 UTC | Same as above, but for each maintenance branch (ruby\_3\_3, ruby\_3\_4, ruby\_4\_0) |
| `draft-release` | On `draft/v*` tag push | Create a draft release package, run multi-platform tests, upload to S3, and open a release PR on ruby/www.ruby-lang.org |
| `mswin-snapshot` | Daily 19:30 UTC | Build a relocatable Windows (mswin) binary zip from the master branch, publish it unsigned under `pub/ruby/binaries/mswin64/dev/`, and prune to the newest 30 |
| `mswin-release` | Manual | Build a relocatable Windows (mswin) binary zip from an official release tarball (Ruby 3.3 or later), sign it, and publish it. Used to backfill versions released before this pipeline existed, and to reissue a package under a new revision |
| `Publish mswin binary package` | On `publish-binaries` dispatch | Promote the staged zip from `pub/tmp/` to `pub/ruby/binaries/mswin64/` and regenerate the binaries index |
| `Remove pub/tmp/ruby-*` | Manual | Remove temporary draft release packages from S3 and purge CDN caches |
| `coverage` | Every 3 hours | Run the test suite with gcov coverage and upload reports to S3 |
| `Make HTML for docs.r-l.o/en/` | Daily 13:00 UTC | Build HTML documentation for each Ruby version and upload to S3 |
| `doxygen` | Every 3 hours | Generate C API documentation with Doxygen and upload to S3 |
| `Update bundled_gems` | Daily 15:07 UTC | Check for bundled gem updates in ruby/ruby |
| `ruby_versions` | Reusable workflow | Generate a matrix of Ruby versions for use in other workflows |
| `update_ci_versions` | Daily 16:27 UTC | Update CI version configuration |
| `update_index` | Hourly | Update the release index |

All snapshot and draft-release workflows also support `repository_dispatch` and `workflow_dispatch` triggers for manual execution.

# mswin binary packages

The `mswin-snapshot` and `mswin-release` workflows build relocatable binary zip packages for Windows (x64-mswin64\_140) through the shared `mswin-build` reusable workflow. The zip layout is a public contract for tooling that consumes these packages. Each zip has a single root directory named after the package, holding `bin/`, `lib/`, `include/`, `share/` and `LICENSES/`. The `bin/` directory bundles the vcpkg runtime DLLs. The VC runtime (`vcruntime140*.dll`) is deliberately not bundled, because app-local copies are never serviced by Windows Update. The package assumes the VC++ Redistributable is installed on the destination machine. The `LICENSES/` directory collects the license terms of everything redistributed. CA certificates are not bundled either. A `<package>.zip.sha256` checksum file is generated next to each zip.

Package names:

- Release: `ruby-<version>-x64-mswin64_140` (e.g. `ruby-3.4.5-x64-mswin64_140`)
- Snapshot: `ruby-<version>dev-<yyyymmdd>-<commit>-x64-mswin64_140`, so that a dev build can never collide with a release package name

Releases are built from the official release tarball on cache.ruby-lang.org, verified against `pub/ruby/index.txt`. Snapshots are built from a fresh clone of the master branch. Ruby 3.3 has no in-tree `vcpkg.json`, so the builder supplies `tool/mswin/vcpkg-ruby_3_3.json` instead. Ruby 3.3 also predates ruby/ruby `091c7d4a54`, which makes the mswin C4013 warning an error, so the builder appends `-we4013` to its warnflags. Without it `mkmf`'s `have_func` probe for a compiler builtin like `__builtin_clzll` compiles a bare implicit declaration, reports a false positive, and then fails to link, which breaks `gem install json` on the packaged 3.3. Both overrides target only the older trees that need them and no-op on 3.4 and later. Packaging is done by `tool/binary-package.rb` from ruby/ruby, downloaded at the commit pinned in `BINARY_PACKAGE_REF` in `mswin-build.yml`. Bumping that SHA is the whole sync with upstream. The script is applied from the outside to the staged install rather than via the in-tree `nmake binary-package` target, so that already-released tarballs (which predate the script) can be packaged and the snapshot naming stays under this repository's control. Before archiving, the script scrubs build-machine paths (such as the `--with-opt-dir` vcpkg path) from the staged `rbconfig.rb` `configure_args`, since mkmf feeds those to every extension build and a leaked absolute path would break gem compilation on the destination machine. Only the staged copy is touched, never the build machine's own installation.

Every built zip is smoke-tested in the workflow. The zip is extracted, the root name, layout and checksum are checked, the packaged `ruby.exe` is run with PATH restricted to System32 while loading openssl, fiddle, psych and zlib, and its `configure_args` is asserted to carry no absolute path. A native gem (`json`) is then compiled against the package under the VS toolchain to confirm the extension build pulls in no vcpkg path. The zip and its checksum are uploaded as an Actions artifact, which is how to get a build before it is signed and published.

## Publishing

Release packages ride along with the source release. `draft-release` builds the zip from the same draft tarball, signs it through SignPath under the `signing` environment, and stages it as `pub/tmp/ruby-<version>-x64-mswin64_140-draft.zip`. These jobs are deliberately absent from the release job's `needs`, so a packaging or signing failure never holds back the source release. When ruby/ruby's publish workflow dispatches `publish-binaries`, the staged zip is promoted to `pub/ruby/binaries/mswin64/`. That destination is append-only: an existing zip is never overwritten, and a package that has to be replaced is reissued under a revisioned name such as `ruby-3.4.5-1-x64-mswin64_140.zip`. Daily snapshots are published unsigned under `dev/`, keeping the newest 30 builds. See [SIGNING.md](SIGNING.md) for what is signed and how to verify it.

`tool/update_binaries_index.rb` regenerates `pub/ruby/binaries/index.json` after every publish. The index is a flat list of builds in the shape of PEP 773 (pymanager) feeds, newest first, each carrying resolution tags that follow ruby-build naming. A release resolves by `4.0.5`, `4.0` and `4`, a prerelease only by its exact `4.1.0-rc1`, and a dev build by `4.1-dev`, `4.1-dev-<yyyymmdd>` or its full `4.1.0dev-<yyyymmdd>-<commit>`, with `ruby-dev` aliasing the newest dev series. Each entry carries `url`, `sha256`, `size`, `date` and a `signed` flag. The index is always generated from scratch by listing S3 and reading the `.sha256` sidecars, so a lost or corrupt index heals on the next run.

### Required setup

Signing and publishing need repository configuration that does not live in this repository:

- A `signing` environment with required reviewers. Without it GitHub silently creates an unprotected environment on first use, and the approval gate that `SIGNING.md` describes does not exist.
- Repository variables `SIGNPATH_ORGANIZATION_ID`, `SIGNPATH_PROJECT_SLUG`, `SIGNPATH_SIGNING_POLICY_SLUG` and `SIGNPATH_ARTIFACT_CONFIGURATION_SLUG`.
- A `SIGNPATH_API_TOKEN` secret on the `signing` environment.
- The SignPath GitHub App installed on this repository, which is how SignPath verifies build provenance.

While `SIGNPATH_ORGANIZATION_ID` is unset the signing step is skipped, packages ship unsigned, and the index records `signed: false` for them. The workflow logs a warning in that case.

# How to trigger workflows

## Run snapshot tests with a patch

1. Open the workflow page, e.g. <https://github.com/ruby/actions/actions/workflows/snapshot-master.yml> or `snapshot-ruby_X_Y`
2. Click **Run workflow** (next to "This workflow has a workflow\_dispatch event trigger.")
3. Leave "Use workflow from" as `master` — this refers to the [ruby/actions](https://github.com/ruby/actions) branch, not ruby/ruby
4. Enter a diff URL in **Patch URL** (e.g. `https://patch-diff.githubusercontent.com/raw/ruby/ruby/pull/4369.diff`). The workflow downloads it and applies it with `git apply`
5. Click **Run workflow**

## Create a draft release package

1. Open <https://github.com/ruby/actions/actions/workflows/draft-release.yml>
2. Click **Run workflow**
3. Enter the target version (e.g. `3.4.0-rc1`) in **Target version**
4. Click **Run workflow**

## Build a mswin release package

Use this to backfill a version released before this pipeline existed, or to reissue a package. Regular releases publish through `draft-release` and `publish-binaries` instead.

1. Open <https://github.com/ruby/actions/actions/workflows/mswin-release.yml>
2. Click **Run workflow**
3. Enter the released version (e.g. `3.4.5`) in **Packaging target version**
4. Leave **Reissue revision** empty for a first publication. To replace an already published package, enter the next integer (`1`, `2`, ...), which publishes `ruby-<version>-<revision>-x64-mswin64_140.zip` and makes the index resolve `<version>` to it
5. Click **Run workflow**
6. Approve the `signing` environment deployment when the `publish` job requests it
7. The zip is published under `pub/ruby/binaries/mswin64/` and the index is regenerated

To get the zip without publishing it, download the `build` job's artifact and do not approve the deployment.

## Remove temporary release packages

1. Open <https://github.com/ruby/actions/actions/workflows/remove-tmp-package.yml>
2. Click **Run workflow**
3. Enter the version to remove (e.g. `3.4.0-rc1-draft`) in **Target version**
4. Click **Run workflow**
