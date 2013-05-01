
module Scide

  def self.list options = {}

    dir = projects_dir options

    projects = []

    config_file = '.screenrc'
    projects << '.' if Dir.pwd != File.expand_path('~') and File.file?(config_file)

    if File.directory? dir

      Dir.entries(dir).each do |project|

        next if project.match /\A\.+\Z/
        project_dir = File.join dir, project

        next unless File.directory? project_dir
        config_file = File.join project_dir, '.screenrc'

        next unless File.file? config_file
        projects << project
      end

    elsif projects.empty?
      error %/No such directory "#{dir}"/
    end

    projects
  end
end
