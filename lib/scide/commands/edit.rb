module Scide

  module Commands

    class Edit < Scide::Commands::Run

      def initialize contents, options = {}
        super contents, options
        @text = [ '$EDITOR', options[:edit].to_s, @text.to_s ].select(&:present?).join(' ')
      end
    end
  end
end
