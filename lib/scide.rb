require 'paint'
require 'upoj-rb'

dirname = File.dirname __FILE__
deps_dir = File.join dirname, 'scide'
VERSION_FILE = File.join dirname, '..', 'VERSION'

module Scide
  VERSION = File.open(VERSION_FILE, 'r').read
  EXIT = {
    :unexpected => 1,
    :invalid_argument => 2,
    :not_initialized => 3,
    :screen_not_found => 4,
    :config_not_found => 13,
    :config_not_readable => 14,
    :malformed_config => 15,
    :invalid_config => 16,
    :unknown_project => 17
  }

  def self.fail condition, msg
    puts
    warn Paint[msg, :yellow]
    puts
    EXIT.key?(condition) ? exit(EXIT[condition]) : exit(1)
  end
end

%w( command config global opts overmind project screen window ).each{ |dep| require File.join(deps_dir, dep) }
