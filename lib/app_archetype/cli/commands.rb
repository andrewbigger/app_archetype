require 'os'

module AppArchetype
  module CLI
    # CLI Actions
    module Commands
      class <<self
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
        def render(dest, args = [], overwrite = false)
          manifest_name = args.shift

          raise 'template name not provided' unless manifest_name

          make_destination_directory(dest)
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
        def list(_dest, _args = [], _overwrite = false)
          CLI::Presenters.list(CLI.manager.manifests)
        end

        ##
        # New template command
        #
        # Creates a blank template in the template directory with the given
        # name
        #
        # @param [String] _dest
        # @param [Array] args
        # @param [Boolean] _overwrite
        #
        def new(_dest, args = [], _overwrite = false)
          template_rel = args.shift
          raise 'template rel not provided' unless template_rel

          dest = File.join(CLI.template_dir, template_rel)
          make_destination_directory(dest)

          template_name = File.basename(template_rel)

          AppArchetype::Generators.render_empty_template(template_name, dest)
        end

        ##
        # Open manifest command
        #
        # Opens manifest json in default editor for adjustment
        #
        def open(_dest, args = [], _overwrite = false)
          editor = CLI.editor

          manifest_name = args.shift

          raise 'template name not provided' unless manifest_name

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
        #
        def find(_dest, args = [], _overwrite = false)
          search_term = args.shift

          raise 'no search term provided' unless search_term

          result = CLI.manager.find(search_term)
          CLI::Presenters.show(result)
        end

        ##
        # Print Template directory command
        #
        # Prints out the currently set template directory - will be blank if
        # TEMPLATE_DIR is not set.
        #
        # @param [String] _dest - not used
        # @param [Array] args - command line args - first value is search term
        # @param [Boolean] _overwrite - not used
        #
        def path(_dest, _args = [], _overwrite = false)
          path = CLI.template_dir
          CLI.print_message(path)
        end

        ##
        # Print version command
        #
        # Prints the gem version
        #
        # @param [String] _dest - not used
        # @param [Array] args - command line args - first value is search term
        # @param [Boolean] _overwrite - not used
        #
        def version(_dest, _args = [], _overwrite = false)
          CLI.print_message(AppArchetype::VERSION)
        end

        private

        ##
        # Makes a directory at specified location
        #
        # Uses FileUtils.mkdir_p so will recursively create
        # a directory if the parent does not exist.
        #
        # Raises RuntimeError when making directory fails i.e.
        # insufficient permissions to create the directory etc.
        #
        # @param [String] dest
        #
        def make_destination_directory(dest)
          return if File.exist?(dest)

          begin
            FileUtils.mkdir_p(dest)
          rescue StandardError
            raise 'cannot create destination directory'
          end
        end
      end
    end
  end
end
