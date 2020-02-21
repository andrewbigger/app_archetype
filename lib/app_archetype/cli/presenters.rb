module AppArchetype
  module CLI
    # CLI output presenters
    module Presenters
      RESULT_HEADER = %w[NAME VERSION PATH].freeze

      def self.show(template)
        return CLI.print_message('not found') if template.nil?

        result = TTY::Table.new(
          RESULT_HEADER,
          [
            [
              template.name,
              template.version,
              template.path
            ]
          ]
        )

        CLI.print_message(
          result.render(:ascii)
        )
      end

      def self.list_templates(templates)
        results = TTY::Table.new(
          RESULT_HEADER,
          templates.map do |template|
            [
              template.name,
              template.version,
              template.path
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
