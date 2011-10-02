require 'rubygems'
require 'bundler'
require 'simplecov'

# test coverage
SimpleCov.start

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rspec'
require 'shoulda'

class SpecHelper
  def self.result name
    File.open(File.join(File.dirname(__FILE__), 'results', "#{name}.screen"), 'r').read
  end

  def self.silence
    silence_stream(STDOUT) do
      silence_stream(STDERR) do
        yield
      end
    end
  end
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'scide'

