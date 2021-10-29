require 'tty-prompt'

module AppArchetype
  module Commands
    class DeleteTemplate
      def initialize(options, manager)
        @options = options
        @prompt = TTY::Prompt.new
        @manager = manager
      end

      def run
        name = @options.name
        name ||= @prompt.select(
          'Please choose manifest for deletion',
          @manager.manifest_names
        )

        manifest = @manager.find_by_name(name)
        raise "Unable to find manifest #{name}" unless manifest

        ok_to_proceed = @prompt.yes?("Are you sure you want to delete #{name}?")

        return unless ok_to_proceed

        FileUtils.rm_rf(manifest.parent_path)

        puts("✔ Template described by `#{name}` has been removed")
      end
    end
  end
end
