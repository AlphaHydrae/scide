module Scide

  # Configuration of a GNU Screen window (name, command).
  class Window

    # The name of the window as it will shown in GNU Screen.
    # See {#initialize}.
    attr_reader :name

    # The optional command that will be shown in this window.
    attr_reader :command

    # Window-specific options. Can be used by commands. See {#initialize}.
    attr_reader :options
    
    # Returns a window for the given project.
    #
    # == Arguments
    # * <tt>project</tt> - The project owning this window.
    # * <tt>contents</tt> - The window configuration (String or Hash).
    #
    # == String Initialization
    # The string must be in the format <tt>NAME [COMMAND]</tt> where
    # <tt>NAME</tt> is the window name and <tt>COMMAND</tt> (optional)
    # is the command configuration (see {Scide::Command}).
    #
    # == Hash Initialization
    # The following options can be given:
    # * <tt>:name => string</tt> - The window name.
    # * <tt>:options => hash</tt> - Window-specific options (will be
    #   merged to the project options).
    # * <tt>:command => string</tt> - The command to use for this window
    #   (will be built using {Scide::Command.resolve}).
    # * <tt>:string => string</tt> - If given, <tt>:name</tt> and <tt>:command</tt>
    #   are ignored and string initialization will be performed with <tt>string</tt>.
    #   <tt>:options</tt> can still be used to override project options.
    def initialize project, contents
      @project = project

      if contents.kind_of? Hash
        init_from_hash! contents
      elsif contents.kind_of? String
        init_from_string! contents
      else
        raise ArgumentError, "window '#{contents}' must be a string or a hash"
      end
    end

    # Returns a representation of this window as a GNU Screen
    # configuration frament.
    #
    # == Arguments
    # * <tt>index</tt> - The position of the window (zero-based).
    def to_screen index
      String.new.tap do |s|
        s << "screen -t #{@name} #{index}"
        s << "\n#{@command.to_screen}" if @command
      end
    end

    private

    # Initializes this window from a hash. See {#initialize} for options.
    def init_from_hash! contents
      raise ArgumentError, "options of window '#{@name}' must be a hash" unless contents[:options].nil? or contents[:options].kind_of?(Hash)
      @options = @project.options.dup.merge(contents[:options] || {})

      if contents[:string].present?
        init_from_string! contents[:string]
      else
        raise ArgumentError, "window '#{contents}' must have a name" unless contents[:name].present?
        @name = contents[:name]
        @command = Command.resolve self, contents if contents.key? :command
      end
    end

    # Initializes this window from a string. See {#initialize} for format.
    def init_from_string! contents
      raise ArgumentError, "window '#{contents}' must not be an empty string" unless contents.present?
      content_parts = contents.split /\s+/, 2
      @name = content_parts[0]
      @options ||= @project.options.dup
      if content_parts.length == 2
        @command = Command.resolve self, content_parts[1]
      end
    end
  end
end
