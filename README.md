# gem-patch

A RubyGems plugin that patches gems.

## Description

`gem-patch` is a RubyGems plugin that helps to patch gems without manually opening and rebuilding them. It opens a given .gem file, extracts it, patches it with system `patch` command, clones its spec, updates the file list and builds the patched gem.

## Usage

`gem patch [options] name-version.gem PATCH [PATCH ...]`

Optionally with `-pNUMBER` or `--strip=NUMBER` option that sets the file name strip count to NUMBER
(same options as for `patch` command on Linux machines).

## Requirements

This version is build for both RubyGems 1.8  and RubyGems 2.0.
