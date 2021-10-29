require 'tty-prompt'
require 'tty-table'

module AppArchetype
  module Commands
    # Validates manifest and prints results
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

      ##
      # Runs a validation for a manifest
      #
      # First it attempts to retreive the manifest
      # name from command options. If this is not
      # specified a user will be prompted to choose
      # the manifest from a list of known manifests.
      #
      # If a manifest is not found, then a RuntimeError
      # is raised and the command stops.
      #
      # Once the manifest is found then a schema validation
      # is run. Any result means that the manifest is invalid.
      #
      # The validity of the manifest is reported to STDOUT
      #
      def run
        name = @options.name
        name ||= @prompt.select(
          'Please choose manifest for validation',
          @manager.manifest_names
        )

        manifest = @manager.find_by_name(name)
        raise "Unable to find manifest #{name}" unless manifest

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
      # Builds a table of validation results
      #
      # @param [Array] results
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
