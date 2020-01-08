module AppArchetype
  class Template
    attr_reader :source_path, :source_files

    def initialize(source_path)
      @source_path = source_path
      @source_files = []
      
      load_template
    end

    def load_template
      raise 'template source does not exist' unless exist?
      
      Dir.glob(::File.join(@source_path, '**', '*')).each do |file|
        @source_files << ::File.new(file)
      end
    end

    def exist?
      ::File.exist?(@source_path)
    end
  end
end
