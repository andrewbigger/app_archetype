module AppArchetype
  module CLI
    # CLI output presenters
    module Presenters
      ##
      # Output table header
      #
      RESULT_HEADER = %w[NAME VERSION PATH].freeze

      ##
      # Show renders a single manifest to STDOUT in table form
      #
      # @param [AppArchetype::Template::Manifest] manifest
      #
      def self.show(manifest)
        return CLI.print_message('not found') if manifest.nil?

        result = TTY::Table.new(
          RESULT_HEADER,
          [
            [
              manifest.name,
              manifest.version,
              manifest.path
            ]
          ]
        )

        CLI.print_message(
          result.render(:ascii)
        )
      end

      ##
      # List renders a set of manifests to STDOUT in table form
      #
      # @param [Array] manifests
      #
      def self.list(manifests)
        results = TTY::Table.new(
          RESULT_HEADER,
          manifests.map do |manifest|
            [
              manifest.name,
              manifest.version,
              manifest.path
            ]
          end
        )

        CLI.print_message(
          results.render(:ascii)
        )
      end
    end
  end
end
