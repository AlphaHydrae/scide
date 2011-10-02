module Scide

  module Commands

    # Edits a file with the default editor (<tt>$EDITOR</tt>).
    #
    # == Configuration Example
    #   # this YAML configuration,
    #   projects:
    #     project1:
    #       options:
    #         edit: '-c MyVimCommand'
    #       windows:
    #         - "window1 EDIT $HOME/fubar.txt"
    #
    #   # will produce the following command in window1:
    #   $EDITOR -c MyVimCommand $HOME/fubar.txt
    class Edit < Scide::Commands::Run

      # Returns a new edit command.
      #
      # See class definition for examples.
      #
      # == Arguments
      # * <tt>contents</tt> - The file to edit.
      # * <tt>options</tt> - Options that can be used in the contents
      #   of the command.
      #
      # == Options
      # * <tt>:edit => string</tt> - Arguments to the editor.
      def initialize contents, options = {}
        super contents, options
        @text = [ '$EDITOR', options[:edit].to_s, @text.to_s ].select(&:present?).join(' ')
      end
    end
  end
end
