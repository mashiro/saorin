require 'saorin/adapters/registerable'

module Saorin
  module Adapters
    module Servers
      include Registerable
      self.load_path = 'saorin/adapters/servers'
    end
  end
end
