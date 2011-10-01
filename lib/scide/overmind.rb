module Scide

  class Overmind

    def initialize
      @cli = Scide::Opts.new
      @config = Scide::Config.new
    end

    def brood
      @cli.parse! ARGV
      @config.file = @cli.funnel[:config] if @cli.funnel.key? :config
      @config.load
      @initialized = true
      self
    end

    def dominate

      Scide.fail :not_initialized, 'ERROR: call #brood to initialize' unless @initialized
    
      project_key = ARGV.shift
      screen = Scide::Screen.new @config, @cli, project_key
      screen.validate

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
