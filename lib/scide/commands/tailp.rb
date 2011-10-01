module Scide

  module Commands

    class Tailp < Scide::Commands::Tail
      
      def initialize contents, properties = {}, options = nil
        invalid_config("TAILP requires property #{contents}") unless properties.key? contents
        @text = properties[contents]
        super contents, properties, options
      end
    end
  end
end
