module Scide

  module Commands
    
    class Tail < Scide::Commands::Run
      
      def initialize contents, options = {}
        super contents, options
        @text = [ 'tail', options[:tail].to_s, '-f', @text.to_s ].select(&:present?).join(' ')
      end
    end
  end
end
