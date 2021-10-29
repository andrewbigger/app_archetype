require 'logger'
require 'thor'
require 'highline'

require 'app_archetype'
require 'app_archetype/commands'

module AppArchetype
  # Command line interface helpers and actions
  class CLI < ::Thor
    package_name 'AppArchetype'

    desc 'version', 'Print app archetype version to STDOUT'

    ##
    # Runs version command
    #
    def version
      cmd = AppArchetype::Commands::Version.new(options)
      cmd.run
    end

    map %w[--version -v] => :version

    desc 'list', 'Prints a list of known templates to STDOUT'

    ##
    # Runs list templates command
    #
    def list
      cmd = AppArchetype::Commands::ListTemplates.new(
        options,
        manager.manifests
      )
      cmd.run
    end

    desc 'path', 'Prints template path to STDOUT'

    ##
    # Runs print path command
    #
    def path
      cmd = AppArchetype::Commands::PrintPath.new(
        options,
        template_dir
      )
      cmd.run
    end

    desc 'open', 'Opens template manifest file'

    method_option(
      :name,
      type: :string,
      desc: 'Name of manifest'
    )

    ##
    # Runs open manifest command
    #
    def open
      cmd = AppArchetype::Commands::OpenManifest.new(
        options,
        manager,
        editor
      )
      cmd.run
    end

    desc 'new', 'Creates a template in ARCHETYPE_TEMPLATE_DIR'

    method_option(
      :name,
      type: :string,
      desc: 'Name of template'
    )

    ##
    # Runs new template commmand
    #
    def new
      cmd = AppArchetype::Commands::NewTemplate.new(
        options,
        template_dir
      )
      cmd.run
    end

    desc 'delete', 'Deletes a template in ARCHETYPE_TEMPLATE_DIR'

    method_option(
      :name,
      type: :string,
      desc: 'Name of template'
    )

    ##
    # Runs delete template command
    #
    def delete
      cmd = AppArchetype::Commands::DeleteTemplate.new(
        options,
        manager
      )
      cmd.run
    end

    desc 'validate', 'Runs a schema validation on template manifest'

    method_option(
      :name,
      type: :string,
      desc: 'Name of template'
    )

    ##
    # Runs validate manifest command
    #
    def validate
      cmd = AppArchetype::Commands::ValidateManifest.new(
        options,
        manager
      )
      cmd.run
    end

    desc 'variables', 'Prints template variables'

    method_option(
      :name,
      type: :string,
      desc: 'Name of template'
    )

    ##
    # Runs print template variables command
    #
    def variables
      cmd = AppArchetype::Commands::PrintTemplateVariables.new(
        options,
        manager
      )
      cmd.run
    end

    desc 'find', 'Finds a template in collection'

    method_option(
      :name,
      type: :string,
      desc: 'Name of template'
    )

    ##
    # Runs find templates command
    #
    def find
      cmd = AppArchetype::Commands::FindTemplates.new(
        options,
        manager
      )
      cmd.run
    end

    desc 'render', 'Renders project template'

    method_option(
      :name,
      type: :string,
      desc: 'Name of template'
    )

    method_option(
      :out,
      type: :string,
      desc: 'Destination path for rendered template',
      default: FileUtils.pwd
    )

    method_option(
      :overwrite,
      type: :boolean,
      default: false,
      desc: 'Option to overwrite any existing files'
    )

    ##
    # Runs render template command
    #
    def render
      cmd = AppArchetype::Commands::RenderTemplate.new(
        options,
        manager,
        options.out
      )
      cmd.run
    end

    protected

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
end
