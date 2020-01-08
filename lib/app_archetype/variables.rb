require 'json'

module AppArchetype
  # Variables is a module for parsing variables for use in templates
  module Variables
    def self.new_from_args(args)
      variables = Hashie::Mash.new
      args.each do |arg|
        pair = arg.split(':')
        variables[pair.shift] = pair.shift
      end

      variables
    end

    def self.new_from_file(file_path)
      Hashie::Mash.new(
        JSON.parse(
          ::File.read(file_path)
        )
      )
    end
  end
end
