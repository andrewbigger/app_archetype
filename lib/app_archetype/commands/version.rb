require 'tty-prompt'

module AppArchetype
  module Commands
    # Prints gem version to STDOUT
    class Version
      def initialize(options = Hashie::Mash.new)
        @options = options
        @prompt = TTY::Prompt.new
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
