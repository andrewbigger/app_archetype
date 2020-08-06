require 'tty'

module AppArchetype
  class CLI < Thor
    # CLI output presenters
    module Presenters
      class <<self
        ##
        # Output table header
        #
        RESULT_HEADER = %w[NAME VERSION].freeze

        ##
        # Builds a table of manifest information
        #
        # @param [AppArchetype::Template::Manifest] manifest
        #
        def manifest(manifest)
          return 'not found' if manifest.nil?

          TTY::Table.new(
            RESULT_HEADER,
            [
              [
                manifest.name,
                manifest.version
              ]
            ]
          )
        end

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
      end
    end
  end
end
