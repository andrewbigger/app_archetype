require 'ruby-handlebars'

module AppArchetype
  class Plan
    attr_reader :template, :destination, :files, :variables

    def initialize(template, destination_path, variables)
      @template = template
      @destination = ::File.new(destination_path)
      @files = []
      @variables = variables
    end

    def devise
      raise 'destination path does not exist' unless destination_exist?

      @template.source_files.each do |file|
        @files << File.new(
          file, 
          render_dest_file_path(file)
        )
      end
    end

    def destination_exist?
      ::File.exist?(
        ::File.dirname(@destination.path)
      )
    end

    def render_dest_file_path(source_path)
      rel_path = render_path(
        source_path.path.gsub(@template.source_path, ''),
        @variables
      )

      ::File.join(@destination.path, rel_path)
    end

    def render_path(path, variables)
      hbs = Handlebars::Handlebars.new
      hbs.compile(path).call(@variables)
    end
  end
end
