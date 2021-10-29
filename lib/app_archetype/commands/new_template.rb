require 'tty-prompt'

module AppArchetype
  module Commands
    # Creates new blank template for a user
    class NewTemplate
      def initialize(options, template_dir)
        @options = options
        @prompt = TTY::Prompt.new

        @template_dir = template_dir
      end

      ##
      # Renders a new empty template and manifest
      #
      # First it looks to the name option for a relative
      # path from the template dir
      #
      # If this is not provided then the user is prompted
      # for input.
      #
      # Once we have a name, the destination folder is created
      # and the generator renders an empty template there.
      #
      # If the operation is successful then a success message
      # is printed to STDOUT confirming this.
      #
      def run
        rel = @options.name
        rel ||= @prompt.ask('Please enter a name for the new template')

        dest = File.join(@template_dir, rel)
        FileUtils.mkdir_p(dest)

        name = File.basename(rel)
        AppArchetype::Generators.render_empty_template(name, dest)

        puts("✔ Template `#{name}` created at #{dest}")
      end
    end
  end
end
