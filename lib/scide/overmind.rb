module Scide

  class Overmind

    def initialize
      @cli = Scide::Opts.new
      @config = Scide::Config.new
    end

    def brood
      @cli.parse! ARGV
      @config.file = @cli.funnel[:config] if @cli.funnel.key? :config
      @config.load!
      @initialized = true
      self
    end

    def dominate

      Scide.fail :not_initialized, 'ERROR: call #brood to initialize' unless @initialized
    
      project_key = ARGV.shift
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
        screen.run
      end
    end
  end
end
