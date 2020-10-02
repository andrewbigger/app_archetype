require 'cli-format'

module AppArchetype
  class CLI < Thor
    # CLI output presenters
    module Presenters
      ##
      # Output table header
      #
      RESULT_HEADER = %w[NAME VERSION].freeze

      ##
      # Variable table header
      #
      VARIABLE_HEADER = %w[NAME DESCRIPTION DEFAULT].freeze

      ##
      # Validation result table header
      #
      VALIDATION_HEADER = %w[ERROR].freeze

      class <<self
        ##
        # Creates a presenter for given data
        #
        # Accepts header row data and has configurable format.
        #
        # Header must be array of string
        #
        # Data is array of arrays where the inner array is a row.
        #
        # Format by default is a table, although can be 'csv'
        # or 'json'.
        #
        # @param header [Array]
        # @param data [Array]
        # @param format [String]
        #
        # @return [CliFormat::Presenter]
        #
        def table(header: [], data: [], format: 'table')
          has_header = header.any?
          opts = { header: has_header, format: format }

          presenter = CliFormat::Presenter.new(opts)
          presenter.header = header if has_header

          data.each { |row| presenter.rows << row }

          presenter
        end

        ##
        # Builds a table of manifest information
        #
        # @param [Array] manifests
        #
        def manifest_list(manifests)
          table(
            header: RESULT_HEADER,
            data: manifests.map do |manifest|
              [
                manifest.name,
                manifest.version
              ]
            end
          ).show
        end

        ##
        # Builds a table of variable information
        #
        # @param [Array] variables
        #
        def variable_list(variables)
          table(
            header: VARIABLE_HEADER,
            data: variables.map do |variable|
              [
                variable.name,
                variable.description,
                variable.default
              ]
            end
          ).show
        end

        ##
        # Builds a table for manifest validation results
        #
        # @param [Array] results
        #
        def validation_result(results)
          table(
            header: VALIDATION_HEADER,
            data: results.map do |result|
              [
                result
              ]
            end
          ).show
        end
      end
    end
  end
end
