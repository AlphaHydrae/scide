require 'which_works'

module Scide

  # Configuration of a GNU Screen session (windows for a specific project).
  #
  # The configuration will disable the startup message and display a hardstatus line.
  # It will also display the windows of the given project.
  class Screen
    
    # The default screen hardstatus line.
    DEFAULT_HARDSTATUS = '%{= kG}[ %{G}%H %{g}][%= %{=kw}%?%-Lw%?%{r}(%{W}%n*%f%t%?(%u)%?%{r})%{w}%?%+Lw%?%?%= %{g}][%{B}%Y-%m-%d %{W}%c %{g}]'

    # Options for this screen.
    attr_accessor :options

    # Returns a screen configuration for the given project.
    #
    # == Arguments
    # * <tt>project</tt> - The project.
    # * <tt>options</tt> - Screen-specific options (see below).
    #
    # == Options
    # * <tt>binary</tt> - Screen binary (defaults to <tt>screen</tt>).
    # * <tt>args</tt> - Command-line arguments that will be given to screen (e.g. <tt>-U</tt> for unicode).
    # * <tt>hardstatus</tt> - Hardstatus line configuration (defaults to {DEFAULT_HARDSTATUS}).
    def initialize project, options
      raise ArgumentError, 'screen configuration must be a hash' unless options.nil? or options.kind_of?(Hash)

      @project = project
      @options = options.try(:dup) || {}
    end

    # Returns the command that will be used to run screen with this configuration.
    #
    # == Arguments
    # * <tt>tmp_file</tt> - The temporary file in which the configuration will be stored.
    #   (Optional for dry-run.)
    def to_command tmp_file = 'TEMPORARY_FILE'
      [ "cd #{@project.path} &&", binary, args, "-c #{tmp_file}" ].select(&:present?).join(' ')
    end

    # Verifies that the screen binary is there. If not, causes scide
    # to fail with a <tt>screen_not_found</tt> error (see {Scide.fail}).
    def check_binary
      Scide.fail :screen_not_found, "ERROR: #{binary} not found" unless Which.which(binary)
    end

    # Returns a representation of this configuration as a string.
    def to_s
      String.new.tap do |s|
        s << "startup_message off\n"
        s << "hardstatus on\n"
        s << "hardstatus alwayslastline\n"
        s << "hardstatus string '#{hardstatus}'\n\n"
        s << @project.to_screen
      end
    end

    # Returns the screen hardstatus line given as option, or
    # the default {DEFAULT_HARDSTATUS}.
    def hardstatus
      @options[:hardstatus].try(:to_s) || DEFAULT_HARDSTATUS
    end

    # Returns the screen binary given as option, or the
    # default (<tt>screen</tt>).
    def binary
      @options[:binary].try(:to_s) || 'screen'
    end

    # Returns the screen command-line arguments given as options.
    def args
      @options[:args].try(:to_s)
    end
  end
end
