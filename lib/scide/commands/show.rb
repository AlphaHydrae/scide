module Scide

  module Commands
    
    class Show < Scide::Command

      def to_screen
        %|stuff "#{text_with_properties}"\n|
      end
    end
  end
end