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
| --patch-options=OPTIONS || Pass additional patch command options. |
| -cPATHS | --copy-in=PATHS | Copy in files or folders (separated by comma) |
| -rPATHS | --remove=PATHS | Remove files or folders before rebuild (separated by comma) |
| --dry-run | | Print the results from patching, but do not change any files. |
| --verbose | | Print additional info and STDOUT from `patch` command. |

For versions higher than 0.1.4 `--dry-run` switch behaviour has been changed and it's not the same as in original `patch` command. Instead, `gem-patch` lets `patch` command modify files, but doesn't override the gem to be patched nor the output file at the end. This way we can easily use dry run also for patches involving more diffs changing each other.

If you need to check patching files that are not part of .gem release (such as a separate test suite), you can do it with `--copy-in=test,folders` option. If you don't want to include those additional files then delete them with `--remove=test,folders`.

## Requirements

This version is build for both RubyGems 1.8  and RubyGems 2.0.

## Copyright

Released under the MIT license. Feel free to contribute!
