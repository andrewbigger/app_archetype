module AppArchetype
  module Template
    # Source is an in memory representation of a project archetype
    class Source
      attr_reader :path, :files

      def initialize(path)
        @path = path
        @files = []
      end

      def load
        raise 'template source does not exist' unless exist?

        Dir.glob(::File.join(@path, '**', '*')).each do |file|
          @files << file
        end
      end

      def exist?
        ::File.exist?(@path)
      end
    end
  end
end
