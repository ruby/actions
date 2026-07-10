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
| `mswin-snapshot` | Daily 19:30 UTC | Build a relocatable Windows (mswin) binary zip from the master branch and upload it as an Actions artifact |
| `mswin-release` | Manual | Build a relocatable Windows (mswin) binary zip from an official release tarball (Ruby 3.3 or later) |
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

Releases are built from the official release tarball on cache.ruby-lang.org, verified against `pub/ruby/index.txt`. Snapshots are built from a fresh clone of the master branch. Ruby 3.3 has no in-tree `vcpkg.json`, so the builder supplies `tool/mswin/vcpkg-ruby_3_3.json` instead. Packaging is done by `tool/mswin/binary-package.rb`, a vendored copy of the script proposed for ruby/ruby. Before archiving, the script scrubs build-machine paths (such as the `--with-opt-dir` vcpkg path) from the staged `rbconfig.rb` `configure_args`, since mkmf feeds those to every extension build and a leaked absolute path would break gem compilation on the destination machine. Only the staged copy is touched, never the build machine's own installation. Once the in-tree `nmake binary-package` target is available on all target branches, the workflows should switch to it.

Every built zip is smoke-tested in the workflow. The zip is extracted, the root name, layout and checksum are checked, the packaged `ruby.exe` is run with PATH restricted to System32 while loading openssl, fiddle, psych and zlib, and its `configure_args` is asserted to carry no absolute path. A native gem (`json`) is then compiled against the package under the VS toolchain to confirm the extension build pulls in no vcpkg path. The zip and its checksum are uploaded as an Actions artifact. Publishing to cache.ruby-lang.org is not wired up yet.

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

1. Open <https://github.com/ruby/actions/actions/workflows/mswin-release.yml>
2. Click **Run workflow**
3. Enter the released version (e.g. `3.4.5`) in **Packaging target version**
4. Click **Run workflow**
5. Download the zip and `.sha256` from the run's artifacts

## Remove temporary release packages

1. Open <https://github.com/ruby/actions/actions/workflows/remove-tmp-package.yml>
2. Click **Run workflow**
3. Enter the version to remove (e.g. `3.4.0-rc1-draft`) in **Target version**
4. Click **Run workflow**
