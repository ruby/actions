# Code signing for mswin binary packages

Free code signing provided by [SignPath.io](https://signpath.io), certificate by [SignPath Foundation](https://signpath.org).

The Windows binary packages (`ruby-<version>-x64-mswin64_140.zip`) published under `https://cache.ruby-lang.org/pub/ruby/binaries/mswin64/` are built on GitHub Actions in this repository and signed through SignPath when the release is published. Two manual approvals gate every production signature: the `signing` deployment environment in this repository, and the signing request itself in the SignPath UI, where SignPath Foundation requires per-request approval for production certificates. The workflow waits up to an hour for the latter, so approve the SignPath request promptly after approving the environment. Every signature carries an RFC 3161 timestamp. `index.json` in `pub/ruby/binaries/` records for each build whether it is signed.

## What is signed

Only PE files built from the Ruby source tree are signed:

- `bin/ruby.exe` and `bin/rubyw.exe`
- `bin/x64-vcruntime140-ruby*.dll`
- the bundled extension libraries (`lib/ruby/**/*.so`)

## What is not signed

- Third-party DLLs built by vcpkg (OpenSSL, libyaml, zlib, libffi, gmp). They are redistributed as built while we sign under the SignPath Foundation OSS program.
- Dev snapshot builds under `dev/`. Only tagged releases are signed.
- Extension gems compiled on the user's machine. Anything `gem install` builds locally is outside the package signature.

The DLLs under `bin/` are a mix: `x64-vcruntime140-ruby*.dll` is signed, while `libssl-3-x64.dll`, `libcrypto-3-x64.dll`, `legacy.dll`, `yaml.dll`, `zlib1.dll`, `ffi-8.dll`, `gmp-10.dll` and `gmpxx-4.dll` come from vcpkg and are expected to report as unsigned.

## Verifying a package

Check the download against the `.zip.sha256` published next to it:

```
(Get-FileHash ruby-3.4.5-x64-mswin64_140.zip -Algorithm SHA256).Hash.ToLower()
```

Then check the signature. This works on any Windows machine:

```
Get-AuthenticodeSignature bin\ruby.exe
```

If you have the Windows SDK installed, `signtool` from a Developer Command Prompt reports more detail:

```
signtool verify /pa /v bin\ruby.exe
```

The certificate subject is `SignPath Foundation`, which lends its certificate to verified open source projects. A reissued package (for example after a packaging fix) is published under a revisioned name such as `ruby-3.4.5-1-x64-mswin64_140.zip` rather than replacing the original file.

Whether a given build is signed is recorded in <https://cache.ruby-lang.org/pub/ruby/binaries/index.json> as a `signed` field on each entry. Report a signature that does not verify to <https://bugs.ruby-lang.org/>, or to security@ruby-lang.org if you believe the package was tampered with.

## Required setup

Signing depends on repository configuration that does not live in this repository. See the "Required setup" section of the README for the `signing` environment, the SignPath repository variables and the API token secret. Until those are in place the signing step is skipped, packages ship unsigned, and the index records `signed: false` for them.
