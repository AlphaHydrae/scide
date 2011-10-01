module Scide

  class Project
    attr_accessor :properties, :options, :path

    def initialize contents, key, global
      @global = global

      @path = contents[:path].try(:to_s) || key.to_s
      @path = File.join global.path, @path unless @path.match /^\//

      @properties = global.properties.merge(contents[:properties] || {})
      @properties['name'] ||= key

      @options = global.options.merge(contents[:options] || {})

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
