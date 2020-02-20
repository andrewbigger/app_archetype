require 'fileutils'
require 'erb'
require 'ruby-handlebars'

module AppArchetype
  # Renderer renders a plan
  class Renderer
    def initialize(plan, variables, overwrite = false)
      @plan = plan
      @overwrite = overwrite
      @variables = variables
    end

    def render
      write_dir(::File.new(@plan.destination_path))

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

    def write_dir(file)
      CLI.print_message("CREATE dir -> #{file.path}")

      FileUtils.mkdir_p(file.path)
    end

    def render_erb_file(file)
      raise 'cannot overwrite file' if file.exist? && !@overwrite

      CLI.print_message("RENDER erb ->: #{file.path}")

      input = ::File.read(file.source_file_path)
      out = ERB.new(input).result(@variables.instance_eval { binding })

      ::File.open(file.path.gsub('.erb', ''), 'w+') { |f| f.write(out) }
    end

    def render_hbs_file(file)
      raise 'cannot overwrite file' if file.exist? && !@overwrite

      CLI.print_message("RENDER hbs ->: #{file.path}")

      input = ::File.read(file.source_file_path)

      hbs = Handlebars::Handlebars.new
      out = hbs.compile(input).call(@variables)

      ::File.open(file.path.gsub('.hbs', ''), 'w+') { |f| f.write(out) }
    end

    def copy_file(file)
      raise 'cannot overwrite file' if file.exist? && !@overwrite

      CLI.print_message("COPY file ->: #{file.path}")

      FileUtils.cp(file.source_file_path, file.path)
    end
  end
end
