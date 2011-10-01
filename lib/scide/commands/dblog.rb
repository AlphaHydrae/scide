module Scide

  module Commands

    class Dblog < Scide::Commands::Tail
      
      def initialize contents, properties = {}, options = nil
        @text = properties[:db_log]
        invalid_config('DBLOG requires property db_log') unless @text.present?
        super contents, properties, options
      end
    end
  end
end
