require 'tty-prompt'

module AppArchetype
  module Commands
    # Prints templates path to STDOUT
    class PrintPath
      def initialize(template_dir, options = Hashie::Mash.new)
        @template_dir = template_dir
        @options = options
        @prompt = TTY::Prompt.new
      end

      ##
      # Prints template directory to STDOUT
      #
      def run
        puts(@template_dir)
      end
    end
  end
end
