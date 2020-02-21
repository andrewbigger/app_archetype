require 'app_archetype/cli/commands'
require 'app_archetype/cli/presenters'

require 'logger'
require 'hashie'
require 'tty-table'
require 'tty-prompt'
require 'securerandom'

module AppArchetype
  # Command line interface helpers and actions
  module CLI
    # CLI Helpers
    class <<self
      ##
      # Template manager creates and loads a template manager
      #
      # @return [AppArchetype::Manager]
      #
      def manager
        @manager ||= AppArchetype::Manager.new(template_dir)
        @manager.load

        @manager
      end

      ##
      # Retrieves template dir from environment and raises error
      # when TEMPLATE_DIR environment variable is not set.
      #
      # @return [String]
      #
      def template_dir
        @template_dir = ENV['ARCHETYPE_TEMPLATE_DIR']

        unless @template_dir
          raise 'ARCHETYPE_TEMPLATE_DIR environment variable not set'
        end

        unless File.exist?(@template_dir)
          raise "ARCHETYPE_TEMPLATE_DIR #{@template_dir} does not exist"
        end

        @template_dir
      end

      ##
      # Editor retrieves the chosen editor command to open text files
      # and raises error when ARCHETYPE_EDITOR is not set.
      #
      # If we detect that the which command fails then we warn the user that
      # something appears awry
      #
      # @return [String]
      #
      def editor
        @editor = ENV['ARCHETYPE_EDITOR']
        raise 'ARCHETYPE_EDITOR environment variable not set' unless @editor

        `which #{@editor}`
        if $?.exitstatus != 0
          CLI.print_warning(
            "WARN: Configured editor #{@editor} is not installed correctly "\
            'please check your configuration'
          )
        end

        @editor
      end

      ##
      # Creates logger for printing messages
      #
      # Sets the formatter to output only the provided message to the
      # specified IO
      #
      # @param [IO] out - default: STDOUT
      #
      # @return [Logger]
      #
      def logger(out = STDOUT)
        @logger ||= Logger.new(out)
        @logger.formatter = proc do |_sev, _time, _prog, msg|
          "#{msg}\n"
        end

        @logger
      end

      ##
      # Prints command line message to STDOUT
      #
      # For use when printing info messages for a user to STDOUT
      #
      # @param [String] message - message to be printed
      #
      def print_message(message)
        logger.info(message)
      end

      ##
      # Prints warning to STDOUT
      #
      # For use when printing warn messages to STDOUT
      #
      # @param [String] message - message to be printed
      #
      def print_warning(message)
        logger.warn(message)
      end

      ##
      # Prints error to STDERR
      #
      # For indicating fatal message to user
      #
      # @param [String] message - message to be printed
      #
      def print_error(message)
        logger(STDERR).error(message)
      end

      ##
      # Prints a message and then exits with given status code
      #
      # This will terminate the program with the given status code
      #
      # @param [String] message - message to be printed
      # @param [Integer] exit_code - exit status (default: 1)
      #
      def print_message_and_exit(message, exit_code = 1)
        print_message(message)
        exit(exit_code)
      end
    end
  end
end
