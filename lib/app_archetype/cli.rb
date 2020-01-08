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

        variables = Variables.new_from_args(vars)
        variables = variables.merge(Variables.new_from_file(manifest_path)) if manifest_path

        plan = Plan.new(template, destination_path, variables)
        plan.devise

        Renderer.new(plan, variables, overwrite).render
      end
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
