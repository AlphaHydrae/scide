module Scide

  # Pre-configured scide option parser.
  class Opts < Upoj::Opts

    # Returns the scide option parser. Run scide with <tt>--usage</tt>
    # to see available options.
    def initialize
      super({
        :banner => {
          :usage => '[OPTION]... PROJECT',
          :description => 'generates GNU Screen configuration files.'
        }
      })

      on '-c', '--config FILE', 'load configuration from FILE'
      on '--dry-run', 'show what would be run but do not execute'
      on('--version', 'show version and exit'){ puts "#{program_name} #{Scide::VERSION}"; exit 0 }

      help!.usage!
    end

    # Parses the given arguments.
    #
    # Causes scide to fail with an <tt>invalid_argument</tt> error (see Scide#fail)
    # if an argument is invalid.
    def parse! args
      begin
        super args
      rescue StandardError => err
        Scide.fail :invalid_argument, err
      end
    end
  end
end
