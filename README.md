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

__Interactive configuration will be introduced in v0.2.*.__
__Until then, the configuration file must be prepared manually before using scide.__

## Configuration File

The configuration file is expected to be at the following location by default:

    $HOME/.scide/config.yml

You can load another file by running scide with the `-c` flag:

    scide -c my_config.yml

### Basics

This is a simple scide configuration file:

    projects:
      chessmaster:
        path: /home/jdoe/projects/chessmaster
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

The format for a window is `NAME [COMMAND] [CONTENTS]`.
This opens a window with the given name. An optional command
can be run in the window, which can receive arguments/contents.

### Options

Projects can have a hash of options that commands can use:

    projects:
      chessmaster:
        path: /home/jdoe/projects/chessmaster
        options:
          log_dir: /var/log
          server: thin
        windows:
          - 'project EDIT'
          - 'db-log TAIL %{log_dir}/db.log'
          - 'app-log TAIL %{log_dir}/development.log'
          - 'server RUN %{server} start'
          - 'shell'

### Globals

You can configure a base path and options for all projects.

    global:
      path: /home/jdoe/projects
      options:
        log_dir: /var/log
    projects:
      chessmaster:
        path: chessmaster # this is now relative to the global path
        options:
          server: thin
        windows:
          - 'project EDIT'
          - 'db-log TAIL %{log_dir}/db.log'
          - 'app-log TAIL %{log_dir}/development.log'
          - 'server RUN %{server} start'
          - 'shell'

Options at the project level override global options if they have the same name.

### Commands

Scide currently provides four commands.

#### RUN

Runs the given contents in the window.

For example, `RUN rails server` launches a Ruby on Rails server in the project folder.

#### EDIT

Simply runs `$EDITOR`, your preferred editor.

If the `edit` option is present, it will be used as arguments to the editor.

    # project configuration:
    chessmaster:
      options:
        edit: '-c MyVimCommand'
      windows:
        - 'project EDIT app/controllers/application_controller.erb'

    # resulting command in "project" window:
    $EDITOR -c MyVimCommand app/controllers/application_controller.erb

#### TAIL

Runs the `tail` command with the given file as the `-f` argument.

For example, `TAIL log/db.log` would generate the following command:

    tail -f log/db.log

If the `tail` option is present, it will be used as arguments to tail.

    # project configuration:
    chessmaster:
      options:
        tail: '-n 1000'
      windows:
        - 'db.log TAIL log/db.log'

    # resulting command in "project" window:
    tail -n 1000 -f log/db.log

#### SHOW

Shows the given contents in the window, without running them.

For example, `SHOW ssh example.com` would pre-type this ssh command in the window, but not run it.
That way, you can have special commands ready to run in a separate window.

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

