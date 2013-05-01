require 'paint'
require 'which_works'
require 'shellwords'

module Scide
  VERSION = '0.0.12'

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
end

Dir[File.join File.dirname(__FILE__), File.basename(__FILE__, '.*'), '*.rb'].each{ |lib| require lib }
