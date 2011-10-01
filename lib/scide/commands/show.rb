module Scide

  module Commands
    
    class Show < Scide::Command

      def to_screen
        %|stuff "#{text_with_options}"\n|
      end
    end
  end
end
