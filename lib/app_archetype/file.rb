module AppArchetype
  # File represents an output file
  class File
    attr_reader :source_file_path, :path

    def initialize(source_file_path, path)
      @source_file_path = source_file_path
      @path = path
    end

    def source_directory?
      ::File.directory?(@source_file_path)
    end

    def source_erb?
      ::File.extname(@source_file_path) == '.erb'
    end

    def source_hbs?
      ::File.extname(@source_file_path) == '.hbs'
    end

    def source_file?
      ::File.file?(@source_file_path)
    end

    def exist?
      ::File.exist?(@path)
    end
  end
end
