require 'tty-prompt'

module AppArchetype
  module Commands
    # Prompts user for variable values and renders template to disk
    class RenderTemplate
      def initialize(options, manager, destination_path)
        @options = options
        @prompt = TTY::Prompt.new
        @manager = manager
        @destination_path = destination_path
      end

      ##
      # Renders a template with instructions described
      # in the manifest.
      #
      # First it looks to the options to determine the
      # name of the manifest. If one is not provided
      # then the user will be prompted to choose a manifest
      # from the list.
      #
      # The manager will then attempt to find the manifest.
      # if one is not found then a RuntimeError will be raised.
      #
      # Once the manifest is loaded the template will be loaded
      # into memory.
      #
      # Then the variables specified in the manifest are
      # resolved. This involves the command prompting
      # for values.
      #
      # A plan can then be constructed with the template and
      # variables, this plan is then devised and executed.
      #
      # When the render is successful a success message
      # is sent to STDOUT to confirm the operation was
      # successful.
      #
      def run
        name = @options.name
        name ||= @prompt.select('Please choose manifest', @manager.manifest_names)

        manifest = @manager.find_by_name(name)
        raise "Unable to find manifest #{name}" unless manifest

        template = manifest.template
        template.load

        manifest.variables.all.each do |var|
          value = variable_prompt_for(var)
          var.set!(value)
        end

        plan = AppArchetype::Template::Plan.new(
          template,
          manifest.variables,
          destination_path: @destination_path,
          overwrite: @options.overwrite
        )

        plan.devise
        plan.execute

        puts("✔ Rendered #{name} to #{@destination_path}")
      end

      private

      ##
      # Resolver for a given variable
      #
      # First, it will set the value if the value is set in
      # the manifest.
      #
      # Otherwise it will call a function that prompts
      # a user for input depending on type.
      #
      # By default it will call the string variable prompt
      #
      # @param [AppArchetype::Template::Variable] var
      #
      # @return [Object]
      #
      def variable_prompt_for(var)
        return var.value if var.value?
        return boolean_variable_prompt_for(var) if var.type == 'boolean'
        return integer_variable_prompt_for(var) if var.type == 'integer'

        string_variable_prompt_for(var)
      end

      ##
      # Prompts and then asks for boolean input for
      # a boolean variable
      #
      # @param [AppArchetype::Template::Variable] var
      #
      # @return [Boolean]
      #
      def boolean_variable_prompt_for(var)
        puts "• #{var.name} (#{var.description})"
        @prompt.yes?("Enter value for `#{var.name}` variable:", default: var.default)
      end

      ##
      # Prompts and then asks for integer input for
      # a integer variable
      #
      # @param [AppArchetype::Template::Variable] var
      #
      # @return [Integer]
      #
      def integer_variable_prompt_for(var)
        puts "• #{var.name} (#{var.description})"
        @prompt.ask("Enter value for `#{var.name}` variable:", convert: :int, default: var.default)
      end

      ##
      # Prompts and then asks for string input for
      # a string variable
      #
      # @param [AppArchetype::Template::Variable] var
      #
      # @return [String]
      #
      def string_variable_prompt_for(var)
        puts "• #{var.name} (#{var.description})"
        @prompt.ask("Enter value for `#{var.name}` variable:", default: var.default)
      end
    end
  end
end
