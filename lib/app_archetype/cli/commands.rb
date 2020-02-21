module AppArchetype
  module CLI
    # CLI Actions
    module Commands
      ##
      # Render template command
      #
      def self.render(dest, args = [], overwrite = false)
        manifest_name = args.shift

        unless ::File.exist?(dest)
          begin
            FileUtils.mkdir_p(dest)
          rescue StandardError
            raise 'cannot create destination directory'
          end
        end

        manifest = CLI.manager.find(manifest_name)
        template = manifest.template

        template.load

        plan = Plan.new(
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
      def self.list(_dest, _args = [], _overwrite = false)
        CLI::Presenters.list_templates(CLI.manager.templates)
      end

      ##
      # Find template command
      #
      def self.find(_dest, args = [], _overwrite = false)
        search_term = args.shift

        raise 'no search term provided' if search_term.nil?

        result = CLI.manager.find(search_term)
        CLI::Presenters.show(result)
      end

      ##
      # Print Template directory command
      #
      def self.template_dir(_dest, _args = [], _overwrite = false)
        template_dir = CLI.template_dir
        CLI.print_message(template_dir)
      end
    end
  end
end
