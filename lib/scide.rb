require 'paint'
require 'which_works'
require 'shellwords'

module Scide
  VERSION = '0.0.12'

  # TODO: add detailed error description for non-trace mode
  class Error < StandardError
    attr_reader :code
    
    def initialize msg, code = 1
      super msg
      @code = code
    end
  end

  private

  def self.error msg, code = 1
    raise Error.new msg, code
  end

  def self.projects_dir options = {}
    options[:projects] || ENV['SCIDE_PROJECTS'] || File.expand_path('~/src')
  end

  def self.current_project_dir args, options = {}
    project_name = args.shift
    error "Only one project name must be given, got #{args.unshift project_name}" if args.any?
    dir = project_name ? File.join(projects_dir(options), project_name) : Dir.pwd
    error %/Cannot use home directory/ if File.expand_path(dir) == File.expand_path('~')
    error %/No such directory "#{dir}"/ unless File.directory? dir
    dir
  end
end

Dir[File.join File.dirname(__FILE__), File.basename(__FILE__, '.*'), '*.rb'].each{ |lib| require lib }
