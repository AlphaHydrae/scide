
module Scide
  SCREEN_BIN = 'screen'
  SCREEN_OPTIONS = '-U'

  def self.open *args

    error "screen must be in the path" unless Which.which 'screen'

    options = args.last.kind_of?(Hash) ? args.pop : {}
    project_name = args.shift
    error "Only one project name must be given, got #{args.unshift project_name}" if args.any?
    
    dir = project_name ? File.join(projects_dir(options), project_name) : Dir.pwd
    error %/Cannot open the home directory/ if File.expand_path(dir) == File.expand_path('~')
    error %/No such directory "#{dir}"/ unless File.exists? dir
    error %/"#{dir}" is not a directory/ unless File.directory? dir

    file = File.join dir, '.screenrc'
    error %/No such configuration "#{file}"/ unless File.exists? file
    error %/"#{file}" is not a file/ unless File.file? file

    if options[:noop]
      command dir, options
    else
      error "Could not open project" unless Kernel.system command(dir, options)
      true
    end
  end

  private

  def self.command dir, options = {}
    # TODO: look for other config file names (e.g. "screenrc") or add option to customize?
    command = "#{screen_bin(options)} #{screen_options(options)} -c .screenrc"
    command = "cd #{Shellwords.escape dir} && #{command}" if dir != Dir.pwd
    command
  end

  def self.screen_bin options = {}
    options[:bin] || ENV['SCIDE_BIN'] || SCREEN_BIN
  end

  def self.screen_options options = {}
    options[:screen] || ENV['SCIDE_SCREEN'] || SCREEN_OPTIONS
  end
end
