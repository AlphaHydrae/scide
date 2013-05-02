
module Scide
  SCREEN_BIN = 'screen'
  SCREEN_OPTIONS = '-U'

  def self.open *args

    error "screen must be in the path" unless Which.which 'screen'

    options = args.last.kind_of?(Hash) ? args.pop : {}
    dir = current_project_dir args, options

    file = File.join dir, '.screenrc'
    exists = File.exists? file

    if auto?(options) and !exists
      auto_config_file do |auto_file|
        return run dir, options.merge(screenrc: auto_file.path)
      end
    end

    error %/No such configuration "#{file}"/ unless exists
    error %/"#{file}" is not a file/ unless File.file? file

    run dir, options
  end

  private

  def self.run dir, options = {}
    if options[:noop]
      command dir, options
    else
      error "Could not open project" unless Kernel.system command(dir, options)
      true
    end
  end

  def self.command dir, options = {}
    # TODO: look for other config file names (e.g. "screenrc") or add option to customize?
    command = "#{screen_bin(options)} #{screen_options(options)} -c #{screen_config(options)}"
    command = "cd #{Shellwords.escape dir} && #{command}" if dir != Dir.pwd
    command
  end

  def self.screen_config options = {}
    options[:screenrc] || '.screenrc'
  end

  def self.screen_bin options = {}
    options[:bin] || ENV['SCIDE_BIN'] || SCREEN_BIN
  end

  def self.screen_options options = {}
    options[:screen] || ENV['SCIDE_SCREEN'] || SCREEN_OPTIONS
  end
end
