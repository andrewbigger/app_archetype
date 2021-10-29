require 'tty-prompt'
require 'tty-table'

module AppArchetype
  module Commands
    # Lists known templates for user
    class ListTemplates
      ##
      # Output table header
      #
      RESULT_HEADER = %w[NAME VERSION].freeze

      def initialize(manager, options = Hashie::Mash.new)
        @manager = manager
        @options = options
        @prompt = TTY::Prompt.new
      end

      ##
      # Lists all known and valid manifests
      #
      # This renders a manifest list table
      #
      # Note: any invalid manifests will be excluded
      # from this list.
      #
      def run
        puts(manifest_list_table.render)
      end

      private

      ##
      # Builds a table of manifest information
      #
      def manifest_list_table
        TTY::Table.new(
          header: RESULT_HEADER,
          rows: @manager.manifests.map do |manifest|
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
