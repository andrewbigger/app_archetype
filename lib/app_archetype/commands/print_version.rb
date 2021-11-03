require 'tty-prompt'

module AppArchetype
  module Commands
    # Prints gem version to STDOUT
    class PrintVersion
      def initialize(options = Hashie::Mash.new)
        @options = options
      end

      ##
      # Prints gem version
      #
      def run
        puts(AppArchetype::VERSION)
      end
    end
  end
end
