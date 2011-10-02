module Scide

  # Scide configuration for one project.
  class Project

    # The project key in the projects configuration hash.
    attr_reader :key

    # The path where the project is located. See #initialize.
    attr_reader :path

    # Project-specific options. Can be used by commands. See #initialize.
    attr_reader :options

    # The GNU Screen windows of this project.
    attr_reader :windows

    # Returns a project configuration.
    #
    # If not given in the project hash, #path is built by joining
    # the global path and <tt>key</tt>.
    #
    # ==== Arguments
    # * <tt>global</tt> - The global configuration.
    # * <tt>key</tt> - The key identifying the project. This is the
    #   key in the projects hash.
    # * <tt>contents</tt> - The project hash.
    #
    # ==== Project Options
    #
    # #options is built by merging the options given in the project
    # hash with the global options.
    #
    # The following default options are added if not given:
    # * <tt>name</tt> - Defaults to the project key.
    # * <tt>path</tt> - The path where the project is located.
    def initialize global, key, contents
      raise ArgumentError, "project '#{key}' must be a hash" unless contents.kind_of? Hash
      raise ArgumentError, "windows of project '#{key}' must be an array" unless contents[:windows].kind_of?(Array)
      raise ArgumentError, "options of project '#{key}' must be a hash" unless contents[:options].nil? or contents[:options].kind_of?(Hash)

      @key = key

      # path defaults to project key
      @path = contents[:path].try(:to_s) || key.to_s
      unless path.match /^\//
        # if not absolute
        if global.path
          # expand from global directory
          @path = File.join global.path, @path
        else
          # or from home directory
          @path = File.join File.expand_path('~'), @path
        end
      end

      @options = global.options.dup
      @options[:name] = key
      @options[:path] = @path
      @options.merge!(contents[:options] || {})

      @windows = contents[:windows].collect{ |w| Scide::Window.new self, w }
    end

    # Returns a representation of this project as a GNU Screen
    # configuration fragment. Returns nil if this project has
    # no configured windows.
    def to_screen
      return nil if @windows.blank?
      String.new.tap do |s|
        @windows.each_with_index do |w,i|
          s << w.to_screen(i)
          s << "\n" if i != @windows.length - 1
        end
      end
    end
  end
end
