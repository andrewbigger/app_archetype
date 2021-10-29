require 'tty-prompt'
require 'tty-table'

module AppArchetype
  module Commands
    # Summarizes and prints variables from template manifest
    class PrintTemplateVariables
      ##
      # Variable table header
      #
      VARIABLE_HEADER = %w[NAME DESCRIPTION DEFAULT].freeze

      def initialize(manager, options = Hashie::Mash.new)
        @manager = manager
        @options = options
        @prompt = TTY::Prompt.new
      end

      ##
      # Prints manifest variables, descriptions and defaults
      #
      # First it looks to the options for the manifest name.
      # If one is not provided then the user will be prompted
      # to choose a manifest from the list of known manifests.
      #
      # If the manifest cannot be found a RuntimeError will be
      # raised.
      #
      # Once the manifest is found, an info table is rendered
      # with the variable names, descriptions and any defined
      # defaults.
      #
      def run
        name = @options.name
        name ||= @prompt.select('Please choose manifest', @manager.manifest_names)

        manifest = @manager.find_by_name(name)
        raise "Unable to find manifest #{name}" unless manifest

        puts(variable_table_for(manifest).render)
      end

      private

      ##
      # Builds a table of template variables
      #
      # @param [Manifest] manifest
      #
      def variable_table_for(manifest)
        TTY::Table.new(
          header: VARIABLE_HEADER,
          rows: manifest.variables.all.map do |variable|
            [
              variable.name,
              variable.description,
              variable.default
            ]
          end
        )
      end
    end
  end
end
