module Scide

  class Command

    def self.resolve window, contents
      if contents.kind_of? Hash
        resolve_from_hash window, contents
      elsif contents.kind_of? String
        resolve_from_string window, contents
      else
        raise ArgumentError, 'command must be a string or a hash'
      end
    end

    def initialize contents, options = {}
      @text ||= contents
      @options = (@options || {}).merge options
    end

    def to_screen
      raise 'Use a subclass'
    end

    def invalid_config err
      Scide.fail :invalid_config, "ERROR: #{self.class.name} configuration is invalid.\n   #{err}"
    end

    private

    def self.resolve_from_hash window, contents
      klass = Scide::Commands.const_get contents[:command].downcase.capitalize
      klass.new contents[:contents], window.options.dup
    end

    def self.resolve_from_string window, contents
      klass_name, text = contents.split /\s+/, 2
      klass = Scide::Commands.const_get klass_name.downcase.capitalize
      klass.new text, window.options.dup
    end

    def text_with_options
      @text.dup.tap do |s|
        @options.each_pair do |key, value|
          s.gsub! /\%\{#{key}\}/, value
        end
      end
    end
  end
end

# load pre-defined commands
deps_dir = File.join File.dirname(__FILE__), 'commands'
%w( run tail show edit ).each{ |dep| require File.join(deps_dir, dep) }
