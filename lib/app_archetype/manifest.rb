require 'hashie'

module AppArchetype
  # Manifest is a description of an archetype
  class Manifest
    class <<self
      def new_from_file(file_path)
        manifest = JSON.parse(
          ::File.read(file_path)
        )

        if incompatible?(manifest)
          raise 'provided manifest is incompatible with this version'
        end

        new(
          file_path,
          manifest
        )
      end

      def incompatible?(manifest)
        manifest['version'] > AppArchetype::VERSION
      end
    end

    attr_reader :path, :data, :variables

    def initialize(path, data)
      @path = path
      @data = Hashie::Mash.new(data)
      @variables = AppArchetype::Variables.new(@data.variables)
    end

    def name
      @data.name
    end

    def version
      @data.version
    end

    def template
      template_path = ::File.join(::File.dirname(@path), 'template')

      unless ::File.exist?(template_path)
        raise "cannot find template for manifest #{name}"
      end

      @template ||= AppArchetype::Template.new(template_path)
      @template
    end

    def valid?
      return false if version.nil?

      true
    end
  end
end
