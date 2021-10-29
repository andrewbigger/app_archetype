require 'tty-prompt'

module AppArchetype
  module Commands
    class NewTemplate
      def initialize(options, template_dir)
        @options = options
        @prompt = TTY::Prompt.new

        @template_dir = template_dir
      end

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
