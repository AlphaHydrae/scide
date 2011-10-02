module Scide

  module Commands
    
    # Tails a file.
    #
    # == Configuration Example
    #   # this YAML configuration,
    #   projects:
    #     project1:
    #       options:
    #         tail: '-n 1000'
    #       windows:
    #         - "window1 TAIL $HOME/fubar.txt"
    #
    #   # will produce the following command in window1:
    #   tail -n 1000 -f $HOME/fubar.txt
    class Tail < Scide::Commands::Run
      
      # Returns a new tail command.
      #
      # See class definition for examples.
      #
      # == Arguments
      # * <tt>contents</tt> - The file to tail.
      # * <tt>options</tt> - Options that can be used in the
      #   contents of the command.
      #
      # == Options
      # * <tt>tail => string</tt> - Arguments to tail.
      def initialize contents, options = {}
        super contents, options
        @text = [ 'tail', options[:tail].to_s, '-f', @text.to_s ].select(&:present?).join(' ')
      end
    end
  end
end
