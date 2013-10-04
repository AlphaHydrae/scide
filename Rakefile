# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "scide"
  gem.homepage = "http://github.com/AlphaHydrae/scide"
  gem.license = "MIT"
  gem.summary = %Q{GNU Screen IDE}
  gem.description = %Q{GNU screen wrapper to open terminal tabs for projects with a .screenrc file.}
  gem.email = "hydrae.alpha@gmail.com"
  gem.authors = ["Simon Oulevay (AlphaHydrae)"]
  gem.files = %x[git ls-files -- bin lib].split("\n") + %w(Gemfile LICENSE.txt README.md VERSION)
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake-version'
RakeVersion::Tasks.new do |v|
  v.copy 'lib/scide.rb'
end

require 'rspec/core/rake_task'
desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  #t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
  # Put spec opts in a file named .rspec in root
end

task :default => :spec
