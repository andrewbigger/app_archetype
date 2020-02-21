require 'ruby-handlebars'

module AppArchetype
  module Template
    # Plan builds an in memory representation of template output
    class Plan
      attr_reader :template, :destination_path, :files, :variables

      def initialize(
        template,
        variables,
        destination_path: nil,
        overwrite: false
      )
        @template = template
        @destination_path = destination_path
        @files = []
        @variables = variables
        @overwrite = overwrite
      end

      def devise
        raise 'destination path does not exist' unless destination_exist?

        @template.files.each do |file|
          @files << OutputFile.new(
            file,
            render_dest_file_path(file)
          )
        end
      end

      def execute
        renderer = Renderer.new(
          self,
          @overwrite
        )

        renderer.render
      end

      def destination_exist?
        return false unless @destination_path

        ::File.exist?(
          ::File.dirname(@destination_path)
        )
      end

      def render_dest_file_path(source_path)
        rel_path = render_path(
          source_path.gsub(@template.path, '')
        )

        ::File.join(@destination_path, rel_path)
      end

      def render_path(path)
        hbs = Handlebars::Handlebars.new
        hbs.compile(path).call(@variables)
      end
    end

    # OutputFile represents an output file
    class OutputFile
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
end
