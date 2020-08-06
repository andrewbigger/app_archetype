require 'logger'
require 'thor'
require 'tty-prompt'

require 'app_archetype'
require 'app_archetype/cli/presenters'

module AppArchetype
  # Command line interface helpers and actions
  class CLI < Thor
    package_name 'Archetype'

    class <<self
      ##
      # Retrieves template dir from environment and raises error
      # when TEMPLATE_DIR environment variable is not set.
      #
      # @return [String]
      #
      def template_dir
        @template_dir = ENV['ARCHETYPE_TEMPLATE_DIR']

        unless @template_dir
          raise 'ARCHETYPE_TEMPLATE_DIR environment variable not set'
        end

        unless File.exist?(@template_dir)
          raise "ARCHETYPE_TEMPLATE_DIR #{@template_dir} does not exist"
        end

        @template_dir
      end

      ##
      # Editor retrieves the chosen editor command to open text files
      # and raises error when ARCHETYPE_EDITOR is not set.
      #
      # If we detect that the which command fails then we warn the user that
      # something appears awry
      #
      # @return [String]
      #
      def editor
        @editor = ENV['ARCHETYPE_EDITOR']
        raise 'ARCHETYPE_EDITOR environment variable not set' unless @editor

        `which #{@editor}`
        if $?.exitstatus != 0
          CLI.print_warning(
            "WARN: Configured editor #{@editor} is not installed correctly "\
            'please check your configuration'
          )
        end

        @editor
      end

      ##
      # Template manager creates and loads a template manager
      #
      # @return [AppArchetype::Manager]
      #
      def manager
        @manager ||= AppArchetype::Manager.new(template_dir)
        @manager.load

        @manager
      end
    end

    include AppArchetype::Logger

    def self.exit_on_failure?
      true
    end

    desc 'version', 'Prints archetype gem version'
    def version
      print_message(AppArchetype::VERSION)
    end
    map %w[--version -v] => :version

    desc 'list', 'Lists known templates in ARCHETYPE_TEMPLATE_DIR'
    def list
      print_table(
        Presenters.manifest_list(
          CLI.manager.manifests
        )
      )
    end

    desc 'path', 'Prints configured ARCHETYPE_TEMPLATE_DIR'
    def path
      print_message(
        CLI.template_dir
      )
    end

    desc 'open', 'Opens template manifest'
    def open(name)
      editor = CLI.editor
      manifest = CLI.manager.find(name)

      pid = Process.spawn("#{editor} #{manifest.path}")
      Process.waitpid(pid)
    end

    desc 'new', 'Creates a template in ARCHETYPE_TEMPLATE_DIR'
    def new(rel)
      raise 'template rel not provided' unless rel

      dest = File.join(CLI.template_dir, rel)
      FileUtils.mkdir_p(dest)

      name = File.basename(rel)
      AppArchetype::Generators.render_empty_template(name, dest)

      print_message("Template #{name} created at #{dest}")
    end

    desc 'delete', 'Deletes a template in ARCHETYPE_TEMPLATE_DIR'
    def delete(name)
      manifest = CLI.manager.find(name)
      raise 'canot find template' unless manifest

      prompt = TTY::Prompt.new
      proceed = prompt.yes?(
        "Are you sure you want to delete #{manifest.name}?"
      )

      return unless proceed

      FileUtils.rm_rf(manifest.parent_path)
      print_message("#{manifest.name} removed")
    end

    desc 'find', 'Finds a template in collection by name'
    def find(search_term)
      results = CLI.manager.find_by_name(search_term)
      print_table(
        Presenters.manifest_list(results)
      )
    end

    desc 'render', 'Renders project template'
    method_option(
      :overwrite,
      type: :boolean,
      default: false,
      desc: 'Option to overwrite any existing files'
    )
    def render(manifest_name)
      manifest = CLI.manager.find_by_name(manifest_name)

      template = manifest.template
      template.load

      plan = AppArchetype::Template::Plan.new(
        template,
        manifest.variables,
        destination_path: FileUtils.pwd,
        overwrite: options.overwrite
      )
      plan.devise
      plan.execute
    end
  end
end
