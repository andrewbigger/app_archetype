require 'tty-prompt'

module AppArchetype
  module Commands
    # Prints templates path to STDOUT
    class PrintPath
      def initialize(options, template_dir)
        @options = options
        @prompt = TTY::Prompt.new
        @template_dir = template_dir
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
