module Scide

  module Commands
    
    class Tail < Scide::Commands::Run
      
      def initialize contents, properties = {}, options = nil
        super contents, properties, options
        @text = [ 'tail', options.to_s, '-f', @text.to_s ].select(&:present?).join(' ')
      end
    end
  end
end
