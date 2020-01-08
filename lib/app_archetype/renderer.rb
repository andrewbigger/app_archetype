require 'fileutils'
require 'erb'

module AppArchetype
  class Renderer
    def initialize(plan, variables, overwrite = false)
      @plan = plan
      @overwrite = overwrite
      @variables = variables
    end

    def render
      write_dir(@plan.destination)

      @plan.files.each do |file|
        case
        when file.source_directory?
          write_dir(file)
        when file.source_template?
          render_file(file)
        when file.source_file?
          copy_file(file)
        end
      end
    end

    def write_dir(file)
      FileUtils.mkdir_p(file.path)
    end

    def render_file(file)
      raise 'cannot overwrite file' if file.exist? && !@overwrite

      input = ::File.read(file.source_file.path)
      out = ERB.new(input).result(@variables.instance_eval { binding })

      ::File.open(file.path.gsub('.erb', ''), 'w+') { |f| f.write(out) }
    end

    def copy_file(file)
      raise 'cannot overwrite file' if file.exist? && !@overwrite

      FileUtils.cp(file.source_file.path, file.path)
    end
  end
end
