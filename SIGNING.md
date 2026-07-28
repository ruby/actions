# Code signing for mswin binary packages

Free code signing provided by [SignPath.io](https://signpath.io), certificate by [SignPath Foundation](https://signpath.org).

The Windows binary packages (`ruby-<version>-x64-mswin64_140.zip`) published under `https://cache.ruby-lang.org/pub/ruby/binaries/mswin64/` are built on GitHub Actions in this repository and signed through SignPath. Signing requests run under the `signing` deployment environment with manual approval, and every signature carries an RFC 3161 timestamp. `index.json` in `pub/ruby/binaries/` records for each build whether it is signed.

## What is signed

Only PE files built from the Ruby source tree are signed:

- `bin/ruby.exe` and `bin/rubyw.exe`
- `bin/x64-vcruntime140-ruby*.dll`
- the bundled extension libraries (`lib/ruby/**/*.so`)

## What is not signed

- Third-party DLLs built by vcpkg (OpenSSL, libyaml, zlib, libffi, gmp). They are redistributed as built while we sign under the SignPath Foundation OSS program.
- Dev snapshot builds under `dev/`. Only tagged releases are signed.
- Extension gems compiled on the user's machine. Anything `gem install` builds locally is outside the package signature.

## Verifying a package

```
signtool verify /pa bin\ruby.exe
```

or with PowerShell:

```
Get-AuthenticodeSignature bin\ruby.exe
```

The certificate subject is `SignPath Foundation`, which lends its certificate to verified open source projects. A reissued package (for example after a packaging fix) is published under a revisioned name such as `ruby-3.4.5-1-x64-mswin64_140.zip` rather than replacing the original file.
