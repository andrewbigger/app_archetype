require 'hashie'
require 'json'

module AppArchetype
  # Variables is a module for parsing variables for use in templates
  class Variables < Hashie::Mash
    class <<self
      def new_from_args(args)
        vars = {}
        args.each do |arg|
          pair = arg.split(':')
          raise "malformed variable argument: #{arg}" unless pair.count == 2

          vars[pair.shift] = pair.shift
        end

        new(vars)
      end

      def new_from_file(file_path)
        raise 'file not found' unless ::File.exist?(file_path)

        new(
          JSON.parse(
            ::File.read(file_path)
          )
        )
      end
    end

    # dot provides a convenient way for a noop render at the
    # beginning of dotfiles
    def dot
      ''
    end
  end
end
