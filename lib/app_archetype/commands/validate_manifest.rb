require 'tty-prompt'

module AppArchetype
  module Commands
    class ValidateManifest
      ##
      # Validation result table header
      #
      VALIDATION_HEADER = %w[ERROR].freeze

      def initialize(options, manager)
        @options = options
        @prompt = TTY::Prompt.new
        @manager = manager
      end

      def run
        name = @options.name
        name ||= @prompt.select(
          'Please choose manifest for validation',
          @manager.manifest_names
        )

        manifest = @manager.find_by_name(name)

        result = manifest.validate
        if result.any?
          puts validation_results_table.render
          puts ''
          puts "✖ Manifest #{name} is NOT valid"
        else
          puts("✔ Manifest #{name} is valid")
        end
      end

      private

      ##
      # Builds a table of manifest information
      #
      # @param [Array] manifests
      #
      def validation_results_table(results)
        TTY::Table.new(
          header: VALIDATION_HEADER,
          rows: results.map do |result|
            [
              result
            ]
          end
        )
      end
    end
  end
end
