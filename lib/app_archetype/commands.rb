require 'hashie'

COMMANDS = File.join(__dir__, 'commands', '*.rb')

Dir[COMMANDS].sort.each do |file|
  require file
end

module AppArchetype
  # Module for CLI command classes
  module Commands
  end
end
