require 'logger'
require 'hashie'

module AppArchetype
  # Command line interface helpers and actions
  module CLI
    # CLI Actions
    module Commands
      ##
      # Template render command
      #
      def self.render(
        template_path,
        destination_path,
        manifest_path,
        overwrite = false,
        vars = []
      )
        template = Template.new(template_path)
        template.load

        variables = Variables.new_from_args(vars)
        if manifest_path
          manifest_vars = Variables.new_from_file(manifest_path)
          variables = manifest_vars.merge(variables)
        end

        plan = Plan.new(template, destination_path, variables)
        plan.devise

        Renderer.new(plan, variables, overwrite).render
      end
    end

    # CLI Helpers
    class <<self
      ##
      # Creates logger for printing messages
      #
      def logger
        @logger ||= Logger.new(STDOUT)
        @logger.formatter = proc do |_sev, _time, _prog, msg|
          msg
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
      # Prints a message and then exits with given status code
      #
      def print_message_and_exit(message, exit_code = 1)
        print_message(message)
        exit(exit_code)
      end
    end
  end
end
