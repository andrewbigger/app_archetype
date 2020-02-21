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
      # Template manager
      #
      def manager
        @manager ||= AppArchetype::Manager.new(template_dir)
        @manager.load_templates

        @manager
      end

      ##
      # Retrieves template dir from environment
      #
      def template_dir
        @template_dir = ENV['TEMPLATE_DIR']
        raise 'TEMPLATE_DIR environment not set' unless @template_dir

        unless ::File.exist?(@template_dir)
          raise "TEMPLATE_DIR #{@template_dir} does not exist"
        end

        @template_dir
      end

      ##
      # Creates logger for printing messages
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
      def print_message(message)
        logger.info(message)
      end

      ##
      # Prints warning to STDOUT
      #
      def print_warning(message)
        logger.warn(message)
      end

      ##
      # Prints error to STDERR
      #
      def print_error(message)
        logger(STDERR).error(message)
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
