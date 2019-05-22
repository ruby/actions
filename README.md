# ruby-snapshot

This repository is automation tool for ruby packaging workflow.

We use images build by Dockerfile of this repository for building snapshot packages on heroku environment. We are invoking following tasks by heroku scheduler periodically.

```
rake snapshot
rake snapshot:stable
```

# TODO

* Integrate Travis CI for continuously testing with `make-snapshot`
* Support version releasing like Ruby 2.6.0 or 2.5.2.
* Documentation :)
