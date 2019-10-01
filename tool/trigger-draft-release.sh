#!/bin/sh
cd "$(dirname "$0")"
draft="draft/${1:?Usage: $0 v2_x_y}"
set -eux
git tag "$draft"
trap 'git tag -d "$draft"' 0 2
git push origin "$draft"
git push --delete origin "$draft"
