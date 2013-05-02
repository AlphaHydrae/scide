# scide [![Build Status](https://secure.travis-ci.org/AlphaHydrae/scide.png?branch=develop)](http://travis-ci.org/AlphaHydrae/scide)

**[GNU Screen](http://www.gnu.org/software/screen/) IDE.**

The `scide` command wraps `screen` to automatically use `.screenrc` files in the current directory or in project directories.

## Installation

    gem install scide

## Usage

Assuming your project screen configuration is in `~/src/my-project/.screenrc`.

    cd ~/src/my-project
    scide

With the **-p, --projects PROJECTS_DIR** option, `scide` will know your project directory so you can open from elsewhere.

    cd /elsewhere
    scide -p ~/src my-project

You can also set the `$SCIDE_PROJECTS` environment variable:

    export SCIDE_PROJECTS=~/src
    scide my-project

### Without a .screenrc file

If you don't already have a .screenrc configuration file, `scide` can open your project with a default configuration.

    cd ~/other-project
    scide --auto

This will open `screen` with two named windows:

* **editor** will launch your favorite editor (`$PROJECT_EDITOR` or `$EDITOR`);
* **shell** will launch a new shell.

### Add a .screenrc file

To add a .screenrc file to your project:

    cd ~/other-project
    scide setup
    cat .screenrc

## Screen options

* **-b BIN, --bin BIN**

  Use the bin option to give the path to your screen binary if it's not in the PATH or has a different name.
  This can also be set with the `$SCIDE_BIN` environment variable.

* **-s OPTIONS, --screen OPTIONS**

  Customize screen options (`-U` by default).
  This can also be set with the `$SCIDE_SCREEN` environment variable.

## Meta

* **Author:** Simon Oulevay (Alpha Hydrae)
* **License:** MIT (see [LICENSE.txt](https://raw.github.com/AlphaHydrae/scide/master/LICENSE.txt))
