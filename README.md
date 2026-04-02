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
| `Remove pub/tmp/ruby-*` | Manual | Remove temporary draft release packages from S3 and purge CDN caches |
| `coverage` | Every 3 hours | Run the test suite with gcov coverage and upload reports to S3 |
| `Make HTML for docs.r-l.o/en/` | Daily 13:00 UTC | Build HTML documentation for each Ruby version and upload to S3 |
| `doxygen` | Every 3 hours | Generate C API documentation with Doxygen and upload to S3 |
| `Update bundled_gems` | Daily 15:07 UTC | Check for bundled gem updates in ruby/ruby |
| `ruby_versions` | Reusable workflow | Generate a matrix of Ruby versions for use in other workflows |
| `update_ci_versions` | Daily 16:27 UTC | Update CI version configuration |
| `update_index` | Hourly | Update the release index |

All snapshot and draft-release workflows also support `repository_dispatch` and `workflow_dispatch` triggers for manual execution.

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

## Remove temporary release packages

1. Open <https://github.com/ruby/actions/actions/workflows/remove-tmp-package.yml>
2. Click **Run workflow**
3. Enter the version to remove (e.g. `3.4.0-rc1-draft`) in **Target version**
4. Click **Run workflow**
