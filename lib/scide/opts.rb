module Scide

  class Opts < Upoj::Opts

    def initialize *args
      super *args

      on '-c', '--config FILE'
      on '--dry-run'

      help!
      usage!
    end

    def parse! args
      begin
        super args
      rescue StandardError => err
        Scide.fail :invalid_argument, err
      end
    end
  end
end
