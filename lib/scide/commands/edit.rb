module Scide

  module Commands

    class Edit < Scide::Commands::Run

      def initialize contents, properties = {}, options = nil
        super contents, properties, options
        @text = [ '$EDITOR', options.to_s, @text.to_s ].select(&:present?).join(' ')
      end
    end
  end
end
