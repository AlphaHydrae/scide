# scide

GNU Screen IDE.

The purpose of this tool is to generate several GNU screen configurations from a single YAML configuration file.
This can be used to easily setup a multi-windows development environment with screen.

## Using

You can install scide with:

    gem install scide

Then use it on the command line:

    scide --version
    scide my_project

__Interactive configuration will be introduced in v0.2.*__
__Until then, the configuration file must be prepared manually before using scide__

## Configuration File

The configuration file is expected to be at the following location by default:

    $HOME/.scide/config.yml

You can load another file by running scide with the `-c` flag:

    scide -c my_config.yml

### Basics

This is a simple scide configuration file:

    projects:
      path: /home/jdoe/projects/chessmaster
      chessmaster:
        windows:
          - 'project EDIT'
          - 'db-log TAIL log/db.log'
          - 'server RUN rails server'
          - 'shell'

By running `scide chessmaster`, screen would open with four windows:

* a __project__ window with your favorite `$EDITOR` launched;
* a __db-log__ window with a tail of the project's database log;
* a __server__ window with your Ruby on Rails server launched;
* a __shell__ window with your shell running.

## Contributing to scide
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2011 AlphaHydrae. See LICENSE.txt for
further details.

