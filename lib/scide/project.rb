module Scide

  class Project
    attr_accessor :options, :path

    def initialize contents, key, global
      @global = global

      @path = contents[:path].try(:to_s) || key.to_s
      @path = File.join global.path, @path unless @path.match /^\//

      @options = global.options.merge(contents[:options] || {})
      @options[:name] ||= key
      @options[:path] ||= @path

      @windows = []
      contents[:windows].each do |w|
        @windows << Scide::Window.new(w, self)
      end
    end

    def to_screen
      String.new.tap do |s|
        @windows.each_with_index do |w,i|
          s << w.to_screen(i)
        end
      end
    end
  end
end
