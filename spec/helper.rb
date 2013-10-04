require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'simplecov'
require 'coveralls'
Coveralls.wear!

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

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

require 'scide'
