require 'hashie'

module AppArchetype
  # Manifest is a description of an archetype
  class Manifest < Hashie::Mash
    class <<self
      def new_from_file(file_path)
        manifest = JSON.parse(
          ::File.read(file_path)
        )

        if incompatible?(manifest)
          raise 'provided manifest is incompatible with this version'
        end

        new(
          manifest
        )
      end

      def incompatible?(manifest)
        manifest['version'] > AppArchetype::VERSION
      end
    end

    def valid?
      return false if version.nil?
      return false if variables.nil?

      true
    end
  end
end
