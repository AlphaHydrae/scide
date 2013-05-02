
module Scide

  def self.setup *args

    options = args.last.kind_of?(Hash) ? args.pop : {}
    dir = current_project_dir args, options

    file = File.join dir, '.screenrc'
    error "#{file} already exists" if File.exists? file

    File.open(file, 'w'){ |f| f.write auto_config }

    file
  end
end
