COMMANDS = File.join(__dir__, 'commands', '*.rb')

Dir[COMMANDS].sort.each do |file|
  require file
end

module AppArchetype
  module Commands
  end
end
