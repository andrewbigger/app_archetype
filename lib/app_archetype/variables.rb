require 'hashie'
require 'json'

module AppArchetype
  # Variables is a module for parsing variables for use in templates
  module Variables
    class <<self
      def new_from_args(args)
        variables = Hashie::Mash.new
        args.each do |arg|
          pair = arg.split(':')
          raise "malformed variable argument: #{arg}" unless pair.count == 2

          variables[pair.shift] = pair.shift
        end

        variables
      end

      def new_from_file(file_path)
        raise 'file not found' unless ::File.exist?(file_path)

        Hashie::Mash.new(
          JSON.parse(
            ::File.read(file_path)
          )
        )
      end
    end
  end
end
