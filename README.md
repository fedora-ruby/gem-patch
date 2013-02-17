# gem-patch

A RubyGems plugin that patches gems.

## Description

`gem-patch` is a RubyGems plugin that helps to patch gems without manually opening and rebuilding them. It opens a given `.gem` file, extracts it, patches it with system `patch` command, clones its spec, updates the file list and builds the patched gem.

## Installation

Run `gem install gem-patch` and you are done.

### Fedora

On Fedora you can use YUM:

`sudo yum install rubygem-gem-patch`

## Usage

`gem patch [options] name-version.gem PATCH [PATCH ...]`

### Supported options

| option | alternative syntax | description |
| ------ | ------ | ------ |
| -pNUMBER | --strip-numberNUMBER | Sets the file name strip count to NUMBER. |
| -FNUMBER | --fuzz=NUMBER | Set NUMBER of lines to ignore in looking for places to install a hunk. |
| -oFILE | --output=FILE | Set output FILE. |
| --dry-run | | Print the results from patching, but do not change any files. |
| --verbose | --output=FILE | Print additional info and STDOUT from `patch` command. |

## Requirements

This version is build for both RubyGems 1.8  and RubyGems 2.0.

## Copyright

See LICENCE. Feel free to contribute!