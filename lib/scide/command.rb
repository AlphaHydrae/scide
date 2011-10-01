module Scide

  class Command

    def self.resolve contents, options = {}

      if contents.kind_of? Hash
        options = options.merge contents[:options] if contents.key? :options
      end
      
      klass, contents = if contents.kind_of? Hash
        resolve_from_hash contents, options
      elsif contents.kind_of? String
        resolve_from_string contents, options
      end

      klass.new contents, options
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

    def self.resolve_from_hash contents, options = {}
      klass = Scide::Commands.const_get contents[:command].downcase.capitalize
      [ klass, contents[:contents] ]
    end

    def self.resolve_from_string contents, options = {}
      klass_name, text = contents.split /\s+/, 2
      klass = Scide::Commands.const_get klass_name.downcase.capitalize
      [ klass, text ]
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

deps_dir = File.join File.dirname(__FILE__), 'commands'
%w( run tail show edit ).each{ |dep| require File.join(deps_dir, dep) }
