require 'yaml'

module Scide

  # Complete scide configuration as an object graph.
  class Config
    
    # The file from which the configuration is normally loaded.
    # This defaults to <tt>$HOME/.scide/config.yml</tt>.
    DEFAULT_CONFIG_FILE = File.join File.expand_path('~'), '.scide', 'config.yml'

    # The file from which this configuration will be loaded.
    attr_accessor :file
    
    # GNU Screen options. Accessible after calling #load!.
    attr_reader :screen

    # The global configuration. Accessible after calling #load!.
    attr_reader :global
    
    # The project definitions (windows, option overrides, etc). Accessible
    # after calling #load!.
    attr_reader :projects

    # Returns an empty configuration.
    #
    # ==== Arguments
    # * <tt>file</tt> - The file from which to load the configuration. If not
    #   given, this defaults to DEFAULT_CONFIG_FILE.
    def initialize file = nil
      @file = file.try(:to_s) || DEFAULT_CONFIG_FILE
    end

    # Loads this configuration. This will read from #file and parse the contents
    # as YAML. Configuration elements can then be retrieved with #global,
    # #projects and #screen.
    #
    # ==== Errors
    # * <tt>config_not_found</tt> - #file does not exist.
    # * <tt>config_not_readable</tt> - #file cannot be read by the user running scide.
    # * <tt>malformed_config</tt> - #file contains malformed YAML.
    # * <tt>invalid_config</tt> - #file contains invalid configuration (see README).
    # * <tt>unexpected</tt> - #file could not be read.
    def load!
  
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

      invalid_config 'screen configuration must be a hash' unless @config[:screen].nil? or @config[:screen].kind_of?(Hash)
      invalid_config 'projects configuration must be a hash' unless @config[:projects].nil? or @config[:projects].kind_of?(Hash)

      begin
        @screen = @config[:screen]
        @global = Scide::Global.new @config[:global]
        @projects = @config[:projects].inject(HashWithIndifferentAccess.new) do |memo,obj|
          memo[obj[0]] = Scide::Project.new @global, obj[0], obj[1]; memo
        end
      rescue ArgumentError => err
        invalid_config err
      end
    end

    private

    # Causes scide to fail with an <tt>invalid_config</tt> error (see Scide#fail).
    # Builds a complete error message containing the full path to the
    # configuration file and the given message.
    def invalid_config msg
      Scide.fail :invalid_config, "ERROR: configuration #{@file} is invalid.\n   #{msg}"
    end
  end
end
