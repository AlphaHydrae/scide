require 'tempfile'

module Scide

  # Utility class to run scide in a script.
  class Overmind

    # Awakens the overmind.
    def initialize
      @cli = Scide::Opts.new
      @config = Scide::Config.new
    end

    # Parses command-line arguments and loads the configuration file.
    # Any error will be run through Scide.fail.
    def brood
      @cli.parse! ARGV
      @config.file = @cli.funnel[:config] if @cli.funnel.key? :config
      @config.load!
      @initialized = true
      self
    end

    # Runs GNU \Screen with the project given as argument.
    # The <tt>--dry-run</tt> option will cause scide to print the
    # resulting configuration instead of running it.
    #
    # ==== Errors
    # * <tt>not_initialized</tt> - If #brood was not called.
    # * <tt>unknown_project</tt> - If the given project is not found
    #   in the configuration file.
    # * <tt>screen_not_found</tt> - If the GNU \Screen binary is not
    #   found with <tt>which</tt>.
    def dominate

      Scide.fail :not_initialized, 'ERROR: call #brood to initialize.' unless @initialized
    
      project_key = ARGV.shift
      
      if project_key.blank?
        available_projects = @config.projects.keys.join(', ')
        Scide.fail :invalid_argument, "You must choose a project. Available projects: #{available_projects}."
      end

      unless @config.projects.key? project_key
        Scide.fail :unknown_project, "ERROR: there is no project '#{project_key}' in configuration #{@config.file}."
      end

      screen = Scide::Screen.new @config.projects[project_key], @config.screen
      screen.check_binary

      if @cli.funnel[:'dry-run']
        puts
        puts Paint['COMMAND', :bold]
        puts "   #{screen.to_command}"
        puts
        puts Paint['SCREEN CONFIGURATION', :bold]
        puts screen.to_s.gsub(/^/, '   ')
        puts
      else
        file = Tempfile.new 'scide'
        file.write screen.to_s
        file.rewind
        file.close
        system screen.to_command(file.path)
        file.unlink
      end
    end
  end
end
