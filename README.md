# gem-patch

A RubyGems plugin that patches gems.

## Description

`gem-patch` is a RubyGems plugin that helps to patch gems without manually opening and rebuilding them. It opens a given .gem file, extracts it, patches it with system `patch` command, clones its spec, updates the file list and builds the patched gem.

## Installation

Run:
`gem install gem-patch`

## Usage

`gem patch [options] name-version.gem PATCH [PATCH ...]`

Options:

`-pNUMBER` or `--strip=NUMBER` sets the file name strip count to NUMBER (same options as for `patch` command on Linux machines).
`--verbose` prints additional info and STDOUT from `patch` command

## Requirements

This version is build for both RubyGems 1.8  and RubyGems 2.0.

## Copyright

See LICENCE