require 'os'

module AppArchetype
  module CLI
    # CLI Actions
    module Commands
      ##
      # Render template command
      #
      # This will create the destination directory if it does not already
      # exist.
      #
      # The command will then render a project using the source template
      # and manifest instructions to the specified destination directory.
      #
      # @param [String] dest - path to destination
      # @param [Array] args - command line args - manifest name is required
      # @param [Boolean] overwrite - controls renderer overwrite behaviour
      #
      def self.render(dest, args = [], overwrite = false)
        manifest_name = args.shift

        unless File.exist?(dest)
          begin
            FileUtils.mkdir_p(dest)
          rescue StandardError
            raise 'cannot create destination directory'
          end
        end

        manifest = CLI.manager.find(manifest_name)
        template = manifest.template

        template.load

        plan = AppArchetype::Template::Plan.new(
          template,
          manifest.variables,
          destination_path: dest,
          overwrite: overwrite
        )
        plan.devise
        plan.execute
      end

      ##
      # List templates command
      #
      # Outputs a list of templates that exist in TEMPLATE_DIR
      #
      def self.list(_dest, _args = [], _overwrite = false)
        CLI::Presenters.list(CLI.manager.manifests)
      end

      ##
      # Open manifest command
      #
      # Opens manifest json in default editor for adjustment
      #
      def self.open(_dest, args = [], _overwrite = false)
        editor = CLI.editor

        manifest_name = args.shift
        manifest = CLI.manager.find(manifest_name)

        pid = Process.spawn("#{editor} #{manifest.path}")

        Process.waitpid(pid)
      end

      ##
      # Find template command
      #
      # Returns first found template based on query string provided in
      # args
      #
      # @param [String] _dest - not used
      # @param [Array] args - command line args - first value is search term
      # @param [Boolean] _overwrite - not used
      def self.find(_dest, args = [], _overwrite = false)
        search_term = args.shift

        raise 'no search term provided' if search_term.nil?

        result = CLI.manager.find(search_term)
        CLI::Presenters.show(result)
      end

      ##
      # Print Template directory command
      #
      # Prints out the currently set template directory - will be blank if
      # TEMPLATE_DIR is not set.
      #
      def self.template_dir(_dest, _args = [], _overwrite = false)
        template_dir = CLI.template_dir
        CLI.print_message(template_dir)
      end
    end
  end
end
