require 'tty-prompt'

module AppArchetype
  module Commands
    # Deletes template from collection
    class DeleteTemplate
      def initialize(options, manager)
        @options = options
        @prompt = TTY::Prompt.new
        @manager = manager
      end

      ##
      # Deletes a manifest from template dir
      #
      # First it looks in options for the name of the
      # manifest to delete. If this is not set then the user
      # is presented a list of manifests to choose from.
      #
      # When the manifest specified does not exist
      # a runtime error will be raised
      #
      # The user will then be prompted with a yes/no prompt
      # to confirm they wish to delete the selected manifest.
      #
      # If the answer to this is no, the command will stop
      #
      # Otherwise, the template and manifest will be removed
      # from the template dir
      #
      # A success message will be presented to confirm to the
      # user that the operation was successful.
      #
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
