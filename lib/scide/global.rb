module Scide

  # Global scide options (base path for all projects,
  # shared options).
  class Global
    
    # The path under which all projects reside by default.
    # (Can be overriden at the project level.)
    attr_reader :path

    # Global options shared by all projects.
    attr_reader :options
  
    # Builds global options.
    #
    # ==== Arguments
    # * <tt>contents</tt> - The global options hash.
    def initialize contents
      raise ArgumentError, 'global configuration must be a hash' unless contents.kind_of? Hash

      @options = contents[:options] || {}

      # default to home directory
      @path = contents[:path].try(:to_s) || File.expand_path('~')
      # expand from home directory unless absolute
      @path = File.join File.expand_path('~'), @path unless @path.match /^\//
    end
  end
end
