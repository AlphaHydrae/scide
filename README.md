# scide

**[GNU Screen](http://www.gnu.org/software/screen/) IDE.**

The `scide` command wraps `screen` to automatically use `.screenrc` files in the
current directory or in project directories.

[![Build](https://github.com/AlphaHydrae/scide/actions/workflows/build.yml/badge.svg)](https://github.com/AlphaHydrae/scide/actions/workflows/build.yml)
[![MIT License](https://img.shields.io/static/v1?label=license&message=MIT&color=informational)](https://opensource.org/licenses/MIT)

## Usage

Assuming your project screen configuration is in `~/src/my-project/.screenrc`.

    cd ~/src/my-project
    scide

## Screen options

* **-b BIN, --bin BIN**

  Use the bin option to give the path to your screen binary if it's not in the PATH or has a different name.
  This can also be set with the `$SCIDE_BIN` environment variable.

* **-s OPTIONS, --screen OPTIONS**

  Customize screen options (`-U` by default).
  This can also be set with the `$SCIDE_SCREEN` environment variable.
