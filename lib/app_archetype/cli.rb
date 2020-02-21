require 'app_archetype/cli/commands'
require 'app_archetype/cli/presenters'
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
        @variables = Variables.new_from_args(vars)
        @template_path = template_path

        if manifest_path
          @manifest = Manifest.new_from_file(manifest_path)
          raise 'invalid manifest' unless @manifest.valid?

          if @manifest.variables
            @variables = @manifest.variables.merge(@variables)
          end
        end

        template = Template.new(@template_path)
        template.load

        plan = Plan.new(template, destination_path, @variables)
        plan.devise

        Renderer.new(plan, @variables, overwrite).render
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
      # Prints a message and then exits with given status code
      #
      def print_message_and_exit(message, exit_code = 1)
        print_message(message)
        exit(exit_code)
      end
    end
  end
end
