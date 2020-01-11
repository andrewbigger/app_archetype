module AppArchetype
  # Template is an in memory representation of a project archetype
  class Template
    attr_reader :source_path, :source_files

    def initialize(source_path)
      @source_path = source_path
      @source_files = []
    end

    def load
      raise 'template source does not exist' unless exist?

      Dir.glob(::File.join(@source_path, '**', '*')).each do |file|
        @source_files << file
      end
    end

    def exist?
      ::File.exist?(@source_path)
    end
  end
end
