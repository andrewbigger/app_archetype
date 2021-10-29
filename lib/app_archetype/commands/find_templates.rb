require 'tty-prompt'

module AppArchetype
  module Commands
    # Finds template by name in collection
    class FindTemplates
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
      # Finds a template by name from the collection
      #
      # First it looks for a name option, if this is not
      # set then the user is prompted for the template name.
      #
      # Then the template manager runs a search to find a
      # manifest with a fully or partially matching name
      #
      # If there are found results they will be rendered
      # to STDOUT in a table.
      #
      # When there are no results found then a message
      # confirming this will be printed to STDOUT.
      #
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
