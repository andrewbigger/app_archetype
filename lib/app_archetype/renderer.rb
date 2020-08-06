require 'fileutils'
require 'erb'
require 'ruby-handlebars'

module AppArchetype
  # Renderer renders a plan
  class Renderer
    include AppArchetype::Logger

    ##
    # Creates a renderer instance
    #
    # @param [AppArchetype::Template::Plan] plan
    # @param [Boolean] overwrite
    #
    def initialize(plan, overwrite = false)
      @plan = plan
      @overwrite = overwrite
    end

    ##
    # Renders plan to disk. The renderer is capable of:
    # - creating directories
    # - Rendering ERB templates with plan variables
    # - Rendering Handlebars templates with plan variables
    # - Copying static files
    #
    # When a template requests a varaible that does not exist within
    # the plan - then the rendering process stops and a RuntimeError
    # is raised
    #
    # Similarly when a template cannot be parsed a Runtime Error will
    # be raised.
    #
    def render
      write_dir(File.new(@plan.destination_path))

      @last_file = ''
      @plan.files.each do |file|
        @last_file = file
        if file.source_directory?
          write_dir(file)
        elsif file.source_erb?
          render_erb_file(file)
        elsif file.source_hbs?
          render_hbs_file(file)
        elsif file.source_file?
          copy_file(file)
        end
      end
    rescue NoMethodError => e
      raise "error rendering #{@last_file.path} "\
            "cannot find variable `#{e.name}` in template"
    rescue SyntaxError
      raise "error parsing #{@last_file.path} template is invalid"
    end

    ##
    # Creates a directory at the specified location
    #
    # @param [AppArchetype::Template::OutputFile] file
    #
    def write_dir(file)
      print_message("CREATE dir -> #{file.path}")

      FileUtils.mkdir_p(file.path)
    end

    ##
    # Renders erb template to output location
    #
    # @param [AppArchetype::Template::OutputFile] file
    #
    def render_erb_file(file)
      raise 'cannot overwrite file' if file.exist? && !@overwrite

      print_message("RENDER erb ->: #{file.path}")
      input = File.read(file.source_file_path)
      out = ERB.new(input).result(@plan.variables.instance_eval { binding })

      File.open(file.path.gsub('.erb', ''), 'w+') { |f| f.write(out) }
    end

    ##
    # Renders handlebars template to output location
    #
    # @param [AppArchetype::Template::OutputFile] file
    #
    def render_hbs_file(file)
      raise 'cannot overwrite file' if file.exist? && !@overwrite

      print_message("RENDER hbs ->: #{file.path}")

      input = File.read(file.source_file_path)

      hbs = Handlebars::Handlebars.new
      out = hbs.compile(input).call(@plan.variables.to_h)

      File.open(file.path.gsub('.hbs', ''), 'w+') { |f| f.write(out) }
    end

    ##
    # Copies source file to planned path only ovewriting if permitted by the
    # renderer.
    #
    # @param [AppArchetype::Template::OutputFile] file
    #
    def copy_file(file)
      raise 'cannot overwrite file' if file.exist? && !@overwrite

      print_message("COPY file ->: #{file.path}")

      FileUtils.cp(file.source_file_path, file.path)
    end
  end
end
