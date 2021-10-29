require 'logger'
require 'thor'
require 'highline'

require 'app_archetype'
require 'app_archetype/commands'

require 'app_archetype/cli/presenters'
require 'app_archetype/cli/prompts'

module AppArchetype
  # Command line interface helpers and actions
  class CLI < ::Thor
    package_name 'AppArchetype'

    desc 'version', 'Print app archetype version to STDOUT'

    def version
      cmd = AppArchetype::Commands::Version.new(options)
      cmd.run
    end

    map %w[--version -v] => :version

    desc 'list_templates', 'Prints a list of known templates to STDOUT'

    def list_templates
      cmd =  AppArchetype::Commands::ListTemplates.new(options, manager.manifests)
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
