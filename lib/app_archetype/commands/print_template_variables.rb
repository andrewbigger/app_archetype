require 'tty-prompt'
require 'tty-table'

module AppArchetype
  module Commands
    class PrintTemplateVariables
      ##
      # Variable table header
      #
      VARIABLE_HEADER = %w[NAME DESCRIPTION DEFAULT].freeze

      def initialize(options, manager)
        @options = options
        @prompt = TTY::Prompt.new
        @manager = manager
      end

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
