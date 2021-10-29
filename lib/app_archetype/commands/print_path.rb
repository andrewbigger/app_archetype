require 'tty-prompt'

module AppArchetype
  module Commands
    class PrintPath
      def initialize(options, template_dir)
        @options = options
        @prompt = TTY::Prompt.new
        @template_dir = template_dir
      end

      def run
        puts(@template_dir)
      end
    end
  end
end
