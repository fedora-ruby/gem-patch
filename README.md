# gem-patch

A RubyGems plugin that patches gems.

## Description

`gem-patch` is a RubyGems plugin that helpes to patch gems without manually opening and rebuilding them. It openes a given .gem file, extracts it, patches it with system `patch` command, clones its spec, updates the file list and builds the patched gem.

## Usage

gem patch [options] name-version.gem PATCH [PATCH ...]

Optionally with -pNUMBER or --strip=NUMBER option that sets the file name strip count to NUMBER
(same options as for 'patch' command on Linux machines).

## Requirements

This version is build for RubyGems 2.0.a, a branch for RubyGems 1.8 is also available.