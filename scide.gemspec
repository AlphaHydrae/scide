# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "scide"
  s.version = "0.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["AlphaHydrae"]
  s.date = "2011-10-02"
  s.description = "Utility to generate GNU screen configuration files."
  s.email = "hydrae.alpha@gmail.com"
  s.executables = ["scide"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    ".rspec",
    ".rvmrc",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "bin/scide",
    "lib/scide.rb",
    "lib/scide/command.rb",
    "lib/scide/commands/edit.rb",
    "lib/scide/commands/run.rb",
    "lib/scide/commands/show.rb",
    "lib/scide/commands/tail.rb",
    "lib/scide/config.rb",
    "lib/scide/global.rb",
    "lib/scide/opts.rb",
    "lib/scide/overmind.rb",
    "lib/scide/project.rb",
    "lib/scide/screen.rb",
    "lib/scide/window.rb",
    "scide.gemspec",
    "spec/command_spec.rb",
    "spec/commands/edit_spec.rb",
    "spec/commands/run_spec.rb",
    "spec/commands/show_spec.rb",
    "spec/commands/tail_spec.rb",
    "spec/helper.rb"
  ]
  s.homepage = "http://github.com/AlphaHydrae/scide"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "GNU Screen IDE."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<upoj-rb>, ["~> 0.0.4"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, [">= 0"])
    else
      s.add_dependency(%q<upoj-rb>, ["~> 0.0.4"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<rdoc>, [">= 0"])
    end
  else
    s.add_dependency(%q<upoj-rb>, ["~> 0.0.4"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<rdoc>, [">= 0"])
  end
end

