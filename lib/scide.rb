require 'paint'
require 'upoj-rb'

# Generator of GNU Screen configuration files.
module Scide

  # Current version.
  VERSION = File.open(File.join(File.dirname(__FILE__), '..', 'VERSION'), 'r').read

  # Exit status codes.
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
  # If <tt>condition</tt> is a key from {EXIT}, the corresponding value
  # will be used as the exit code. Otherwise, scide exits with
  # status 1.
  def self.fail condition, msg
    if @@exit_on_fail
      puts
      warn Paint[msg, :yellow]
      puts
      EXIT.key?(condition) ? exit(EXIT[condition]) : exit(1)
    else
      raise Scide::Error.new condition, msg
    end
  end

  # By default, scide is meant to be used as a standalone script
  # and exits if an error occurs. If <tt>exit_on_fail</tt> is
  # false, a {Scide::Error} will be raised instead. Scide can then
  # be used by another script.
  def self.exit_on_fail= exit_on_fail
    @@exit_on_fail = exit_on_fail
  end

  # Indicates whether scide is configured to exit on failure.
  # See {Scide.exit_on_fail=}.
  def self.exit_on_fail
    @@exit_on_fail
  end

  # Scide error. Can be raised if {exit_on_fail} is set to false.
  class Error < StandardError

    # A symbol indicating the error type. See {EXIT}.
    attr_reader :condition

    # Returns a new error.
    def initialize condition, msg
      super msg
      @condition = condition
    end
  end

  private

  @@exit_on_fail = true
end

# load scide components
%w( command config global opts overmind project screen window ).each{ |dep| require File.join(File.dirname(__FILE__), 'scide', dep) }
