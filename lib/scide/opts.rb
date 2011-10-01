module Scide

  class Opts < Upoj::Opts

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

    def parse! args
      begin
        super args
      rescue StandardError => err
        Scide.fail :invalid_argument, err
      end
    end
  end
end
