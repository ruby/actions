set(VCPKG_TARGET_ARCHITECTURE arm64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)

# Mirrors .github/vcpkg-triplets/arm64-windows.cmake of ruby/ruby master,
# which release trees predate.  MSVC 14.51 for ARM64 calls __chkstk
# before saving x30 in some prologues, and OpenSSL built with /Gs0 then
# crashes in every TLS handshake.
set(VCPKG_PLATFORM_TOOLSET_VERSION 14.44)
