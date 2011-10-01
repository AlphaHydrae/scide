module Scide

  class Global
    attr_accessor :path, :options
  
    def initialize contents
      @options = contents[:options]

      @path = contents[:path].try(:to_s) || File.expand_path('~')
      @path = File.join File.expand_path('~'), @path unless @path.match /^\//
    end
  end
end
