require 'tty'

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
        # Builds a table of manifest information
        #
        # @param [Array] manifests
        #
        def manifest_list(manifests)
          TTY::Table.new(
            RESULT_HEADER,
            manifests.map do |manifest|
              [
                manifest.name,
                manifest.version
              ]
            end
          )
        end

        ##
        # Builds a table of variable information
        #
        # @param [Array] variables
        #
        def variable_list(variables)
          TTY::Table.new(
            VARIABLE_HEADER,
            variables.map do |variable|
              [
                variable.name,
                variable.description,
                variable.default
              ]
            end
          )
        end

        ##
        # Builds a table for manifest validation results
        #
        # @param [Array] results
        #
        def validation_result(results)
          TTY::Table.new(
            VALIDATION_HEADER,
            results.map do |result|
              [
                result
              ]
            end
          )
        end
      end
    end
  end
end
