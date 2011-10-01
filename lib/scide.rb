require 'paint'
require 'upoj-rb'

# Generator of GNU Screen configuration files.
module Scide

  # Current version.
  VERSION = File.open(File.join(File.dirname(__FILE__), '..', 'VERSION'), 'r').read

  # Exit status codes.
  #
  # ==== Codes
  # * <tt>unexpected</tt> - 1.
  # * <tt>invalid_argument</tt> - 2.
  # * <tt>not_initialized</tt> - 3.
  # * <tt>screen_not_found</tt> - 4.
  # * <tt>config_not_found</tt> - 10.
  # * <tt>config_not_readable</tt> - 11.
  # * <tt>malformed_config</tt> - 12.
  # * <tt>invalid_config</tt> - 13.
  # * <tt>unknown_project</tt> - 14.
  EXIT = {
    :unexpected => 1,
    :invalid_argument => 2,
    :not_initialized => 3,
    :screen_not_found => 4,
    :config_not_found => 10,
    :config_not_readable => 11,
    :malformed_config => 12,
    :invalid_config => 13,
    :unknown_project => 14
  }

  # Prints a message on <tt>stderr</tt> and exits.
  # If #condition is a key from #EXIT, the corresponding value
  # will be used as the exit code. Otherwise, scide exits with
  # status 1.
  def self.fail condition, msg
    puts
    warn Paint[msg, :yellow]
    puts
    EXIT.key?(condition) ? exit(EXIT[condition]) : exit(1)
  end
end

# load scide components
%w( command config global opts overmind project screen window ).each{ |dep| require File.join(File.dirname(__FILE__), 'scide', dep) }
