require 'rubygems'
require 'bundler'
require 'simplecov'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rspec'
require 'fakefs/spec_helpers'

RSpec.configure do |config|

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before :suite do
    ENV.delete_if{ |k,v| k.match /\ASCIDE_/ }
  end

  config.after :each do
    ENV.delete_if{ |k,v| k.match /\ASCIDE_/ }
  end
end

# test coverage
SimpleCov.start

require 'scide'

