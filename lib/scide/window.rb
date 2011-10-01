module Scide

  class Window
    
    def initialize contents, project
      @project = project
      if contents.kind_of? Hash
        init_from_hash contents
      elsif contents.kind_of? String
        init_from_string contents
      end
    end

    def to_screen index
      String.new.tap do |s|
        s << "screen -t #{@name} #{index}\n"
        s << @command.to_screen if @command
      end
    end

    private

    def init_from_hash contents
      @name = contents.delete :name
      @command = Command.resolve contents, @project.properties, @project.options if contents.key? :command
    end

    def init_from_string contents
      content_parts = contents.split /\s+/, 2
      @name = content_parts[0]
      if content_parts.length == 2
        @command = Command.resolve content_parts[1], @project.properties, @project.options
      end
    end
  end
end
