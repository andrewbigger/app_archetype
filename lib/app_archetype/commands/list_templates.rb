require 'tty-prompt'
require 'tty-table'

module AppArchetype
  module Commands
    class ListTemplates
      ##
      # Output table header
      #
      RESULT_HEADER = %w[NAME VERSION].freeze

      def initialize(options, manifests)
        @options = options
        @manifests = manifests
        @prompt = TTY::Prompt.new
      end

      def run
        puts(manifest_list_table.render)
      end

      private

      ##
      # Builds a table of manifest information
      #
      # @param [Array] manifests
      #
      def manifest_list_table
        TTY::Table.new(
          header: RESULT_HEADER, 
          rows: @manifests.map do |manifest|
            [
              manifest.name,
              manifest.version
            ]
          end
        )
      end
    end
  end
end
