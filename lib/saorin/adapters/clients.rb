require 'saorin/adapters/registerable'

module Saorin
  module Adapters
    module Clients
      include Registerable
      self.load_path = 'saorin/adapters/clients'
    end
  end
end
