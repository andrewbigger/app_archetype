module AppArchetype
  module Template
    # Source is an in memory representation of a template source
    class Source
      attr_reader :path, :files

      ##
      # Creates a templatte source from path and initializes file array.
      #
      # @param [String] path
      #
      def initialize(path)
        @path = path
        @files = []
      end

      ##
      # Loads template files into memory. Will raise a RuntimeError if
      # by the time we're loading the source no longer exists.
      #
      def load
        raise 'template source does not exist' unless exist?

        Dir.glob(File.join(@path, '**', '*')).each do |file|
          @files << file
        end
      end

      ##
      # Evaluates whether template source still exists.
      #
      # @return [Boolean]
      #
      def exist?
        File.exist?(@path)
      end
    end
  end
end
