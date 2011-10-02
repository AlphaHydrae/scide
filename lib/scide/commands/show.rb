module Scide

  module Commands
    
    # Prepares and shows a command but do not run it.
    #
    # == Configuration Example
    #   # this YAML configuration,
    #   projects:
    #     project1:
    #       options:
    #         host: 127.0.0.1
    #       windows:
    #         - "window1 SHOW ssh %{host}"
    #
    #   # will produce the following command in window1:
    #   ssh 127.0.0.1
    class Show < Scide::Command

      # Returns a configuration fragment that will show
      # this command in a GNU Screen window without running it.
      # This will use screen's <tt>stuff</tt> command to
      # put the text in the window.
      def to_screen
        %|stuff "#{text_with_options}"|
      end
    end
  end
end
