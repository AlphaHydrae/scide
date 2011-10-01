require 'yaml'

CONFIG_FILE = File.join File.expand_path('~'), '.scide', 'config.yml'

module Scide

  class Config
    attr_accessor :file
    attr_reader :global, :projects, :screen

    def initialize file = nil
      @file = file.try(:to_s) || CONFIG_FILE
    end

    def load
  
      Scide.fail :config_not_found, "ERROR: expected to find configuration at #{@file}" unless File.exists? @file
      Scide.fail :config_not_readable, "ERROR: configuration #{@file} is not readable" unless File.readable? @file

      begin
        raw_config = File.open(@file, 'r').read
      rescue StandardError => err
        Scide.fail :unexpected, "ERROR: could not read configuration #{@file}"
      end

      begin
        @config = YAML::load raw_config
      rescue StandardError => err
        Scide.fail :malformed_config, "ERROR: could not parse configuration #{@file}\n   #{err}"
      end

      invalid_config 'configuration must be a hash' unless @config.kind_of? Hash

      # laziness
      @config = HashWithIndifferentAccess.new @config

      begin
        validate
      rescue StandardError => err
        invalid_config err
      end

      @global = Scide::Global.new @config[:global]
      @screen = @config[:screen]
      @projects = @config[:projects].inject(HashWithIndifferentAccess.new) do |memo,obj|
        memo[obj[0].to_sym] = Scide::Project.new obj[1], obj[0], @global; memo
      end
    end

    def validate
      raise 'global configuration must be a hash' if @config[:global] and !@config[:global].kind_of?(Hash)
      raise 'configuration must contain a hash of projects' unless @config[:projects].kind_of? Hash
    end

    def invalid_config err
      Scide.fail :invalid_config, "ERROR: configuration #{@file} is invalid.\n   #{err}"
    end
  end
end
