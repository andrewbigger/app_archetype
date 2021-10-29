require 'tty-prompt'

module AppArchetype
  module Commands
    # Opens manifest in configured editor
    class OpenManifest
      def initialize(options, manager, editor)
        @options = options
        @prompt = TTY::Prompt.new
        @manager = manager
        @editor = editor
      end

      ##
      # Opens a manifest in the chosen editor program
      #
      # First it looks to the options for the manifest
      # name. If this is not provided the user will be
      # given a list to select from.
      #
      # The manager then attempts to find the manifest
      # by name. If it cannot be found, a RuntimeError
      # is raised and the command stops.
      #
      # Otherwise a new editor subprocess is started
      # with the manifest path given as an arg.
      #
      # This process will wait until the conclusion of
      # the editor process. It's recommended that the
      # editor be a command line editor like `vi`
      #
      def run
        name = @options.name
        name ||= @prompt.select('Please choose manifest', @manager.manifest_names)

        manifest = @manager.find_by_name(name)
        raise "Unable to find manifest #{name}" unless manifest

        pid = Process.spawn("#{@editor} #{manifest.path}")
        Process.waitpid(pid)
      end
    end
  end
end
