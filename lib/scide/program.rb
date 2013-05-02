require 'commander'

module Scide
  
  class Program < Commander::Runner

    BACKTRACE_NOTICE = ' (use --trace to view backtrace)'

    include Commander::UI
    include Commander::UI::AskForClass

    def initialize argv = ARGV
      super argv

      program :name, 'scide'
      program :version, Scide::VERSION
      program :description, 'GNU Screen IDE. Scide is a wrapper to launch screen with a .screenrc configuration file in the current directory or in project directories.'
      program :help, 'H4LP', 'https://github.com/AlphaHydrae/scide/issues'

      global_option '-p', '--projects PROJECTS_DIR', 'Use a custom projects directory (defaults to $SCIDE_PROJECTS or ~/src)'

      command :open do |c|

        c.syntax = 'scide open [PROJECT_NAME]'
        c.description = 'Open the project in PROJECTS_DIR/PROJECT_NAME or the project in the current directory.'

        c.option '-p', '--projects PROJECTS_DIR', 'Use a custom projects directory (defaults to $SCIDE_PROJECTS or ~/src)'
        c.option '-a', '--auto', "Automatically use a default screen configuration if the current directory doesn't have a .screenrc file (defaults to $SCIDE_AUTO)"
        c.option '-b', '--bin BIN', 'Path to screen binary (defaults to $SCIDE_BIN or searches in the PATH)'
        c.option '-s', '--screen OPTIONS', 'Custom screen options (defaults to $SCIDE_SCREEN or -U)'
        c.option '-n', '--noop', 'Show the command that would be run'

        c.example 'scide', 'Open the project in the current directory (.screenrc required).'
        c.example 'scide -p ~/src my-project', 'Open a named project from ~/src (config at ~/src/my-project/.screenrc).'
        c.example 'scide my-project', 'Open a named project (from $SCIDE_PROJECTS or ~/src).'

        c.action do |args,options|
          to_trace_or_not_to_trace options.trace do
            options = extract :projects, :auto, :bin, :screen, :noop, options
            args << options unless options.empty?
            result = Scide.open *args
            puts result if options[:noop]
          end
        end
      end

      command :list do |c|

        c.syntax = 'scide list'
        c.description = 'List the projects with a .screenrc file in PROJECTS_DIR.'

        c.option '-p', '--projects PROJECTS_DIR', 'Use a custom projects directory (defaults to $SCIDE_PROJECTS or ~/src)'

        c.example 'scide list', 'List the projects with a .screenrc file in $SCIDE_PROJECTS or ~/src.'
        c.example 'scide -p ~/Projects list', 'List the projects with a .screenrc file in ~/Projects.'

        c.action do |args,options|
          to_trace_or_not_to_trace options.trace do
            projects = Scide.list extract(:projects, options)
            puts projects.join("\n")
          end
        end
      end

      command :setup do |c|

        c.syntax = 'scide setup [PROJECT_NAME]'
        c.description = 'Create a default .screenrc file in PROJECTS_DIR/PROJECT_NAME or in the current directory.'

        c.option '-p', '--projects PROJECTS_DIR', 'Use a custom projects directory (defaults to $SCIDE_PROJECTS or ~/src)'

        c.example 'scide setup', 'Create a default .screenrc file in the current directory.'
        c.example 'scide -p ~/src setup my-project', 'Create a default .screenrc file in ~/src/my-project.'
        c.example 'scide setup my-project', 'Create a default .screenrc file in $SCIDE_PROJECTS/my-project or ~/src/my-project.'

        c.action do |args,options|
          to_trace_or_not_to_trace options.trace do
            options = extract :projects, :noop, options
            args << options unless options.empty?
            result = Scide.setup *args
            puts Paint[result, :green]
          end
        end
      end

      default_command :open
    end

    private

    def to_trace_or_not_to_trace trace = false
      begin
        yield
      rescue Scide::Error => e
        if trace
          raise e
        else
          warn Paint["#{e.message}#{BACKTRACE_NOTICE}", :red]
          exit e.code
        end
      end
    end

    def extract *args
      options = args.pop
      args.inject({}){ |memo,k| memo[k] = options.__send__(k); memo }.reject{ |k,v| v.nil? }
    end
  end
end
