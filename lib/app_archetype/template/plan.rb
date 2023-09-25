require 'ruby-handlebars'
require_relative '../../core_ext/string'

module AppArchetype
  module Template
    # Plan builds an in memory representation of template output
    class Plan
      attr_reader :template, :destination_path, :files, :variables

      ##
      # Creates a new plan from given source and variables.
      #
      # @param [AppArchetype::Template::Source] template
      # @param [AppArchetype::Template::VariableManager] variables
      # @param [String] destination_path
      # @param [Boolean] overwrite
      #
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

      ##
      # Devise builds an in memory representation of what needs to be done to
      # render the template.
      #
      # When the destination path does not exist - a RuntimeError is raised -
      # however at this stage we should always have a destination path to
      # render to.
      #
      def devise
        raise 'destination path does not exist' unless destination_exist?

        @template.files.each do |file|
          @files << OutputFile.new(
            file,
            render_dest_file_path(file)
          )
        end
      end

      ##
      # Execute will render the plan to disk
      #
      def execute
        renderer = Renderer.new(
          self,
          @overwrite
        )

        renderer.render
      end

      ##
      # Check for whether the destination exists
      #
      # @return [Boolean]
      def destination_exist?
        return false unless @destination_path

        File.exist?(
          File.dirname(@destination_path)
        )
      end

      ##
      # Determines what the destination file path is going to be by taking
      # the source path, subbing the template path and then joining it
      # with the specified destination path.
      #
      # Calls render path to handle any handlebars moustaches included within
      # the file name.
      #
      # @param [String] source_path
      #
      # @return [String]
      def render_dest_file_path(source_path)
        rel_path = render_path(
          source_path.gsub(@template.path, '')
        )

        File.join(@destination_path, rel_path)
      end

      ##
      # Renders template variables into any moustaches included in the filename
      #
      # This permits us to have variable file names as well as variable file
      # content.
      #
      # @param [String] path
      #
      # @return [String]
      #
      def render_path(path)
        hbs = Handlebars::Handlebars.new
        hbs.compile(path).call(@variables.to_h)
      end
    end

    # OutputFile represents a plan action, in other words holds a reference
    # to a source file, and what the output is likely to be
    class OutputFile
      attr_reader :source_file_path, :path

      ##
      # Creates an output file
      #
      # @param [String] source_file_path
      # @param [String] path
      #
      def initialize(source_file_path, path)
        @source_file_path = source_file_path
        @path = path
      end

      ##
      # Evaluates whether the source file is a directory
      #
      # @return [Boolean]
      #
      def source_directory?
        File.directory?(@source_file_path)
      end

      ##
      # Evaluates whether the source file is a erb template
      #
      # @return [Boolean]
      #
      def source_erb?
        File.extname(@source_file_path) == '.erb'
      end

      ##
      # Evaluates whether the source file is a handlebars template
      #
      # @return [Boolean]
      #
      def source_hbs?
        File.extname(@source_file_path) == '.hbs'
      end

      ##
      # Evaluates whether the source file is a template.
      #
      # This is for cases where one wants to render a hbs or
      # erb file without processing as a template file.
      #
      # @return [Boolean]
      #
      def source_template?
        File.extname(@source_file_path) == '.template'
      end

      ##
      # Evaluates whether the source file is a file as opposed to
      # being a directory.
      #
      # @return [Boolean]
      #
      def source_file?
        File.file?(@source_file_path)
      end

      ##
      # Evaluates whether the source file actually exists
      #
      # @return [Boolean]
      #
      def exist?
        File.exist?(@path)
      end
    end
  end
end
