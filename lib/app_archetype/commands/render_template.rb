require 'tty-prompt'

module AppArchetype
  module Commands
    class RenderTemplate
      def initialize(options, manager, destination_path)
        @options = options
        @prompt = TTY::Prompt.new
        @manager = manager
        @destination_path = destination_path
      end

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

      def variable_prompt_for(var)
        return var.value if var.value?
        return boolean_variable_prompt_for(var) if var.type == 'boolean'
        return integer_variable_prompt_for(var) if var.type == 'integer'
        
        string_variable_prompt_for(var)
      end

      def boolean_variable_prompt_for(var)
        puts "• #{var.name} (#{var.description})"
        @prompt.yes?("Enter value for `#{var.name}` variable:", default: var.default)
      end

      def integer_variable_prompt_for(var)
        puts "• #{var.name} (#{var.description})"
        @prompt.ask("Enter value for `#{var.name}` variable:", convert: :int, default: var.default)
      end

      def string_variable_prompt_for(var)
        puts "• #{var.name} (#{var.description})"
        @prompt.ask("Enter value for `#{var.name}` variable:", default: var.default)
      end
    end
  end
end
