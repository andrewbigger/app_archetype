require 'logger'
require 'thor'
require 'highline'

require 'app_archetype'
require 'app_archetype/cli/presenters'
require 'app_archetype/cli/prompts'

module AppArchetype
  # Command line interface helpers and actions
  class CLI < ::Thor
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

        return @template_dir if File.exist?(@template_dir)

        raise "ARCHETYPE_TEMPLATE_DIR #{@template_dir} does not exist"
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
      # @return [AppArchetype::TemplateManager]
      #
      def manager
        @manager ||= AppArchetype::TemplateManager.new(template_dir)
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
      print_message(
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
      manifest = CLI.manager.find_by_name(name)

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

      print_message("Template `#{name}` created at #{dest}")
    end

    desc 'delete', 'Deletes a template in ARCHETYPE_TEMPLATE_DIR'
    def delete(name)
      manifest = CLI.manager.find_by_name(name)
      raise 'Cannot find template' unless manifest

      proceed = Prompts.delete_template(manifest)

      return unless proceed

      FileUtils.rm_rf(manifest.parent_path)
      print_message("Template `#{manifest.name}` has been removed")
    end

    desc 'validate', 'Runs a schema validation on given template'
    def validate(name)
      manifest = CLI.manager.find_by_name(name)
      raise 'Cannot find template' unless manifest

      result = manifest.validate

      print_message("VALIDATION RESULTS FOR `#{name}`")
      if result.any?
        print_message(
          Presenters.validation_result(result)
        )

        raise "Manifest `#{name}` is not valid"
      end

      print_message("Manifest `#{name}` is valid") if result.empty?
    end

    desc 'variables', 'Prints template variables'
    def variables(search_term)
      result = CLI.manager.find_by_name(search_term)
      return print_message("Manifest `#{search_term}` not found") unless result

      print_message("VARIABLES FOR `#{search_term}`")
      print_message(
        Presenters.variable_list(result.variables.all)
      )
    end

    desc 'find', 'Finds a template in collection by name'
    def find(search_term)
      result = CLI.manager.find_by_name(search_term)
      return print_message("Manifest `#{search_term}` not found") unless result

      print_message("SEARCH RESULTS FOR `#{search_term}`")
      print_message(
        Presenters.manifest_list([result])
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

      raise "Unable to find manifest `#{manifest_name}`" unless manifest

      template = manifest.template
      template.load

      manifest.variables.all.each do |var|
        value = Prompts.variable_prompt_for(var)
        var.set!(value)
      end

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
