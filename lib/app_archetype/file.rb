module AppArchetype
  class File
    attr_reader :source_file, :path

    def initialize(source_file, path)
      @source_file = source_file
      @path = path
    end

    def source_exist?
      ::File.exist?(@source_file.path)
    end

    def source_directory?
      ::File.directory?(@source_file.path)
    end

    def source_file?
      ::File.file?(@source_file.path)
    end

    def source_template?
      ::File.extname(@source_file.path) == '.erb'
    end

    def exist?
      ::File.exist?(@path)
    end

    def directory?
      ::File.directory?(@path)
    end

    def file?
      ::File.file?(@path)
    end

    def template?
      ::File.extname(@source_file.path) == '.erb'
    end

    def parent
      ::File.dirname(@path)
    end
  end
end
