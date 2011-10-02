module Scide

  module Commands
    
    # Runs a command.
    #
    # == Configuration Example
    #   # this YAML configuration,
    #   projects:
    #     project1:
    #       windows:
    #         - "window1 RUN rails server"
    #
    #   # will produce the following command in window1:
    #   rails server
    class Run < Scide::Commands::Show

      # Appends a carriage return to the command so that
      # it will not only be shown but also executed.
      def text_with_options
        "#{super}\\012"
      end
    end
  end
end
