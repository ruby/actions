[![Actions Status: coverage](https://github.com/ruby/actions/workflows/coverage/badge.svg)](https://github.com/ruby/actions/actions?query=workflow%3A"coverage")
[![Actions Status: doxygen](https://github.com/ruby/actions/workflows/doxygen/badge.svg)](https://github.com/ruby/actions/actions?query=workflow%3A"doxygen")
[![Actions Status: Make draft release package](https://github.com/ruby/actions/workflows/Make%20draft%20release%20package/badge.svg)](https://github.com/ruby/actions/actions?query=workflow%3A"Make+draft+release+package")
[![Actions Status: Remove pub\/tmp\/ruby-\*](https://github.com/ruby/actions/workflows/Remove%20pub%2Ftmp%2Fruby-*/badge.svg)](https://github.com/ruby/actions/actions?query=workflow%3A"Remove+pub/tmp/ruby-*")
[![Actions Status: snapshot-master](https://github.com/ruby/actions/workflows/snapshot-master/badge.svg)](https://github.com/ruby/actions/actions?query=workflow%3A"snapshot-master")
[![Actions Status: snapshot-ruby\_2\_6](https://github.com/ruby/actions/workflows/snapshot-ruby_2_6/badge.svg)](https://github.com/ruby/actions/actions?query=workflow%3A"snapshot-ruby_2_6")
[![Actions Status: snapshot-ruby\_2\_7](https://github.com/ruby/actions/workflows/snapshot-ruby_2_7/badge.svg)](https://github.com/ruby/actions/actions?query=workflow%3A"snapshot-ruby_2_7")
[![Actions Status: snapshot-ruby\_3\_0](https://github.com/ruby/actions/workflows/snapshot-ruby_3_0/badge.svg)](https://github.com/ruby/actions/actions?query=workflow%3A"snapshot-ruby_3_0")
[![Actions Status: update\_index](https://github.com/ruby/actions/workflows/update_index/badge.svg)](https://github.com/ruby/actions/actions?query=workflow%3A"update_index")

# ruby/actions

This repository is automation tool for ruby workflows.

# TODO

* Documentation :)

# Documentation for [release managers](https://bugs.ruby-lang.org/projects/ruby/wiki/ReleaseEngineering)

See <https://bugs.ruby-lang.org/projects/ruby/wiki/HowToReleaseJa>

# How to run tests of snapshot tarball with patch

* Open <https://github.com/ruby/actions/actions/workflows/snapshot-master.yml> or `snapshot-ruby_X_Y`
* Click `Run workflow` (right of `This workflow has a workflow_dispatch event trigger.`)
* DO NOT CHANGE: Use workflow from Branch: `master` means [ruby/actions](https://github.com/ruby/actions)'s master branch
* Input diff URL to `Patch URL:` (for example: <https://patch-diff.githubusercontent.com/raw/ruby/ruby/pull/4369.diff> (redirect from <https://github.com/raw/ruby/ruby/pull/4369.diff>)) (Workflow downloads it and uses by `git apply`)
* Click `Run workflow`
