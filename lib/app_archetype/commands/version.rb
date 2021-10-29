require 'tty-prompt'

module AppArchetype
  module Commands
    class Version
      def initialize(options)
        @options = options
        @prompt = TTY::Prompt.new
      end

      def run
        puts(AppArchetype::VERSION)
      end
    end
  end
end
