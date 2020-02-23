require 'hashie'

module AppArchetype
  module Template
    # Manifest is a description of an archetype
    class Manifest
      class <<self
        ##
        # Creates a [AppArchetype::Template] from a manifest json so long as the
        # manifest is compatible with this version of AppArchetype.
        #
        # @param [String] file_path
        #
        def new_from_file(file_path)
          manifest = JSON.parse(
            File.read(file_path)
          )

          if incompatible?(manifest)
            raise 'provided manifest is invalid or incompatible with '\
            'this version of app archetype'
          end

          new(
            file_path,
            manifest
          )
        end

        ##
        # Incompatible returns true if the current manifest is not compatible
        # with this version of AppArchetype.
        #
        # A manifest is not compatible if it was created with a version greater
        # than this the installed version.
        #
        # @param [Hash] manifest
        #
        # @return [Boolean]
        #
        def incompatible?(manifest)
          manifest_version = manifest['metadata']['app_archetype']['version']
          manifest_version > AppArchetype::VERSION
        rescue NoMethodError
          true
        end
      end

      attr_reader :path, :data, :variables

      ##
      # Creates a manifest and memoizes the manifest data hash as a Hashe::Map
      #
      # On initialize the manifest variables are retrieved and memoized for use
      # in rendering the templates.
      #
      # @param [String] path
      # @param [Hash] data
      #
      def initialize(path, data)
        @path = path
        @data = Hashie::Mash.new(data)
        @variables = AppArchetype::Template::Variables.new(@data.variables)
      end

      ##
      # Manifest name getter
      #
      # @return [String]
      #
      def name
        @data.name
      end

      ##
      # Manifest version getter
      #
      # @return [String]
      #
      def version
        @data.version
      end

      ##
      # Manifest metadata getter
      #
      # @return[String]
      #
      def metadata
        @data.metadata
      end

      ##
      # Loads the template that is adjacent to the manifest.json.
      #
      # If the template cannot be found, a RuntimeError explaining that
      # the template cannot
      # be found is raised.
      #
      # Loaded template is memoized for the current session.
      #
      # @return [AppArchetype::Template::Source]
      def template
        template_path = File.join(File.dirname(@path), 'template')

        unless File.exist?(template_path)
          raise "cannot find template for manifest #{name}"
        end

        @template ||= AppArchetype::Template::Source.new(template_path)
        @template
      end
    end
  end
end
