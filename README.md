# scide

**[GNU Screen](http://www.gnu.org/software/screen/) IDE.**

The `scide` command wraps `screen` to automatically use `.screenrc` files in the
current directory, in project directories, or automatically generated ones.

[![Version](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/AlphaHydrae/scide/main/badge.json)](https://github.com/AlphaHydrae/scide/releases)
[![Build](https://github.com/AlphaHydrae/scide/actions/workflows/build.yml/badge.svg)](https://github.com/AlphaHydrae/scide/actions/workflows/build.yml)
[![MIT License](https://img.shields.io/static/v1?label=license&message=MIT&color=informational)](https://opensource.org/licenses/MIT)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Requirements](#requirements)
- [Usage](#usage)
- [Installation](#installation)
- [Options](#options)
- [Exit codes](#exit-codes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Requirements

* [Bash](https://www.gnu.org/software/bash/) 3+

## Usage

Assuming your project has a screen configuration at
`~/src/my-project/.screenrc`:

```bash
cd ~/src/my-project
scide
```

> This will basically run the command `screen -U -c .screenrc`.

You can specify directory where your projects live:

```bash
cd ~
scide --projects ~/src my-project
```

You can do the same with the `$SCIDE_PROJECTS` environment variable, which you
can put in your `.bash_profile` shell configuration file to avoid repeating
yourself:

```bash
echo "export SCIDE_PROJECTS=~/src" >> ~/.bash_profile
scide my-project
```

For new projects, scide can run screen with an automatically generated
configuration for you:

```bash
mkdir ~/src/new-project
cd ~/src/new-project
scide --auto
```

> By default, this will open screen with a configuration that sources your own
> `~/.screenrc` configuration and that has two tabs: one that opens your
> favorite `$EDITOR`, and one with a shell.

You can customize this default configuration by creating the file
`~/.config/scide/.screenrc`:

```bash
cat > $FILE <<- EOM
source \$HOME/.screenrc
screen -t editor 0
stuff "\$EDITOR\\012"
screen -t shell 1
select editor
EOM
```

## Installation

With [Homebrew](https://brew.sh):

```bash
brew tap alphahydrae/tools
brew install scide
```

With [cURL](https://curl.se):

```bash
PREFIX=/usr/local/bin \
  FROM=https://github.com/AlphaHydrae/scide/releases/download && \
  curl -sSL $FROM/v2.1.2/scide_v2.1.2.gz | gunzip -c > $PREFIX/scide && \
  chmod +x $PREFIX/scide
```

With [Wget](https://www.gnu.org/software/wget/):

```bash
PREFIX=/usr/local/bin \
  FROM=https://github.com/AlphaHydrae/scide/releases/download && \
  wget -qO- $FROM/v2.1.2/scide_v2.1.2.gz | gunzip -c > $PREFIX/scide && \
  chmod +x $PREFIX/scide
```

Or [download it](https://github.com/AlphaHydrae/scide/releases) yourself.

## Options

```
General options:
  -h, --help     output usage information, then exit
  -v, --version  output current version, then exit

Scide options:
  -a, --auto            $SCIDE_AUTO=true       use an automatically generated .screenrc (see the -t, --default option)
  -d, --dry-run         $SCIDE_DRY_RUN=true    output the screen command that would be run, then exit
  -p, --projects <dir>  $SCIDE_PROJECTS=<dir>  also search for a .screenrc relative to the specified directory
  -t, --default <file>  $SCIDE_DEFAULT=<file>  use a custom default configuration (defaults to "~/.config/scide/.screenrc")

Screen options:
  -b, --bin <command>     $SCIDE_BIN=<bin>         use a custom screen binary (defaults to "screen")
  -s, --screen <options>  $SCIDE_SCREEN=<options>  use custom screen options (defaults to "-U")
```

## Exit codes

Scide will exist with the following exit codes when known errors occur:

| Code  | Description                                                                      |
| :---- | :------------------------------------------------------------------------------- |
| `100` | The `screen` binary cannot be found                                              |
| `101` | The specific `screen` binary is not executable                                   |
| `102` | The `.screenrc` configuration file cannot be found                               |
| `103` | The `.screenrc` configuration file cannot be read due to file system permissions |
| `104` | The path specified as the first argument is neither a file nor a directory       |
