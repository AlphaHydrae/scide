module Scide

  class Command

    def self.resolve contents, properties = {}, options = {}

      if contents.kind_of? Hash
        options = options.merge contents[:options] if contents.key? :options
        properties = properties.merge contents[:properties] if contents.key? :properties
      end
      
      klass, contents = if contents.kind_of? Hash
        resolve_from_hash contents, properties, options
      elsif contents.kind_of? String
        resolve_from_string contents, properties, options
      end

      klass.new contents, properties, build_options(options, klass)
    end

    def initialize contents, properties = {}, options = nil
      @text ||= contents
      @properties, @options = properties, options
    end

    def to_screen
      raise 'Use a subclass'
    end

    def invalid_config err
      Scide.fail :invalid_config, "ERROR: #{self.class.name} configuration is invalid.\n   #{err}"
    end

    private

    def self.resolve_from_hash contents, properties = {}, options = {}
      klass = Scide::Commands.const_get contents[:command].downcase.capitalize
      [ klass, contents[:contents] ]
    end

    def self.resolve_from_string contents, properties = {}, options = {}
      klass_name, text = contents.split /\s+/, 2
      klass = Scide::Commands.const_get klass_name.downcase.capitalize
      [ klass, text ]
    end

    def self.build_options options, klass
      klass_name = klass.name.demodulize.downcase
      current_options = options.try(:[], klass_name)
      current_klass = klass
      while current_klass != Scide::Command and current_options.blank?
        current_klass = current_klass.superclass
        current_options = options.try(:[], current_klass.name.demodulize.downcase)
      end
      current_options
    end

    def text_with_properties
      @text.dup.tap do |s|
        @properties.each_pair do |key, value|
          s.gsub! /\%\{#{key}\}/, value
        end
      end
    end
  end
end

deps_dir = File.join File.dirname(__FILE__), 'commands'
%w( run tail dblog show edit ).each{ |dep| require File.join(deps_dir, dep) }
