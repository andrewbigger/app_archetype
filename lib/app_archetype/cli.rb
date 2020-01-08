require 'hashie'

module AppArchetype
  # Command line interface helpers and actions
  module CLI
    # CLI Actions
    module Commands
    end

    # CLI Helpers
    class <<self
      ##
      # Prints command line message to CLI
      #
      def print_message(message)
        puts(message)
      end

      ##
      # Prints a message and then exits with given status code
      #
      def print_message_and_exit(message, exit_code = 1)
        print_message(message)
        exit(exit_code)
      end
    end
  end
end
