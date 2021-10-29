require 'tty-prompt'

module AppArchetype
  module Commands
    class OpenManifest
      def initialize(options, manager, editor)
        @options = options
        @prompt = TTY::Prompt.new
        @manager = manager
        @editor = editor
      end

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
