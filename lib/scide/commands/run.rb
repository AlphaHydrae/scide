module Scide

  module Commands
    
    class Run < Scide::Command

      def to_screen
        %|stuff "#{text_with_options}\\012"\n|
      end
    end
  end
end
