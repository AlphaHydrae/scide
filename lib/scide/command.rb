module Scide

  # A command to be used in a GNU Screen window. There are several
  # command implementations (show command, run command, tail file, etc).
  # See under Scide::Commands.
  class Command

    # The options given to this command. These are built by merging
    # global options, project options and window options.
    attr_reader :options

    # Returns a new command for the given window.
    #
    # ==== Arguments
    # * <tt>window</tt> - The window in which the command will be used.
    #   Command options are retrieved from Scide::Window#options. See
    #   #initialize.
    # * <tt>contents</tt> - The command configuration (String or Hash).
    #
    # ==== String Initialization
    # The string must be in the format <tt>COMMAND [CONTENTS]</tt>.
    #
    # <tt>TYPE</tt> is the name of the command class under
    # Scide::Commands, in uppercase camelcase. For example, <tt>TAIL</tt>
    # corresponds to Scide::Commands::Tail, <tt>MY_COMMAND</tt> would
    # correspond to Scide::Commands::MyCommand.
    #
    # <tt>CONTENTS</tt> is the contents of the command.
    #
    # ==== Hash Initialization
    # The following options can be given:
    # * <tt>:command => string</tt> is the same <tt>COMMAND</tt> as
    #   for string initialization above.
    # * <tt>:contents => string or other</tt> is the same <tt>CONTENTS</tt>
    #   as for string initialization above. Typically this is only a
    #   string, but more advanced commands might be initialized with
    #   arrays or hashes.
    def self.resolve window, contents
      if contents.kind_of? Hash
        resolve_from_hash window, contents
      elsif contents.kind_of? String
        resolve_from_string window, contents
      else
        raise ArgumentError, 'command must be a string or a hash'
      end
    end

    # Returns a new command with the given options.
    #
    # ==== Arguments
    # * <tt>contents</tt> - The contents of the command. Typically this
    #   is only a string, but more advanced commands might be initialized
    #   with arrays or hashes. By default, the contents can be retrieved
    #   as a string with #text_with_options.
    # * <tt>options</tt> - Options that can be used in the string contents
    #   of the command. See #text_with_options.
    def initialize contents, options = {}

      # fill text only if it's not already there, in case a subclass does
      # some initialization work before calling super
      @text ||= contents.to_s

      # merge given options to the already initialized ones, if any
      @options = (@options || {}).merge options
    end

    # Returns a representation of this command as a GNU Screen
    # configuration fragment.
    #
    # This default implementation raises an error and must be
    # overriden by subclasses.
    def to_screen
      raise 'Use a subclass'
    end

    # Returns the text of this command with filtered option placeholders.
    #
    # ==== Examples
    #   com_text = 'tail %{tail} -f file.txt -c %{foo}'
    #   com = Scide::Command.new com_text, :tail => '-n 1000', :foo => 400
    #   
    #   com.text_with_options   #=> 'tail -n 1000 -f file.txt -c 400'
    def text_with_options
      @text.dup.tap do |s|
        @options.each_pair do |key, value|
          s.gsub! /\%\{#{Regexp.escape key}\}/, value.to_s
        end
      end
    end

    private

    # Returns a new command for the given window. The given
    # contents are a hash. See Scide::Command.resolve.
    def self.resolve_from_hash window, contents
      begin
        klass = Scide::Commands.const_get contents[:command].downcase.camelize
        klass.new contents[:contents], window.options.dup
      rescue NameError => err
        raise ArgumentError, "unknown '#{contents[:command]}' command type"
      end
    end

    # Returns a new command for the given window. The given
    # contents are a string. See Scide::Command.resolve.
    def self.resolve_from_string window, contents
      klass_name, text = contents.split /\s+/, 2
      begin
        klass = Scide::Commands.const_get klass_name.downcase.camelize
        klass.new text, window.options.dup
      rescue NameError => err
        raise ArgumentError, "unknown '#{klass_name}' command type"
      end
    end
  end

  # Module containing scide command classes.
  module Commands
  end
end

# load pre-defined commands
deps_dir = File.join File.dirname(__FILE__), 'commands'
%w( show run tail edit ).each{ |dep| require File.join(deps_dir, dep) }
