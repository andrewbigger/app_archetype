require 'tty-prompt'

module AppArchetype
  module Commands
    class FindTemplates
      ##
      # Output table header
      #
      RESULT_HEADER = %w[NAME VERSION].freeze

      def initialize(options, manager)
        @options = options
        @prompt = TTY::Prompt.new
        @manager = manager
      end

      def run
        name = @options.name
        name ||= @prompt.ask('Please enter a template name')

        result = @manager.search_by_name(name)

        if result.any?
          puts manifest_list_table(result)
        else
          puts "✖ No manifests with name `#{name}` found."
        end
      end

      private

      ##
      # Builds a table of manifest information
      #
      # @param [Array] manifests
      #
      def manifest_list_table(manifests)
        TTY::Table.new(
          header: RESULT_HEADER, 
          rows: manifests.map do |manifest|
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
