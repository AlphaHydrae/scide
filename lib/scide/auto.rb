
module Scide

  def self.auto_config
    # TODO: option to specify custom default configuration file
    String.new.tap do |c|
      c << %|source $HOME/.screenrc\n\n| if File.exists? home_config_file
      c << %|screen -t editor 0\n|
      c << %|stuff "\\${PROJECT_EDITOR-\\$EDITOR}\\012"\n|
      c << %|screen -t shell 1\n|
      c << %|select editor|
    end
  end

  def self.auto_config_file
    file = Tempfile.new 'scide'
    file.write auto_config
    file.rewind
    file.close
    yield file
    file.unlink
  end

  def self.auto? options = {}
    options[:auto] or (ENV['SCIDE_AUTO'] and ENV['SCIDE_AUTO'].match(/\A(1|y|yes|t|true)\Z/i))
  end

  private

  def self.home_config_file
    File.join File.expand_path('~'), '.screenrc'
  end
end
