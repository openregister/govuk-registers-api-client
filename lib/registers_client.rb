require 'register_client'
require 'Paginated'

module RegistersClient
  VERSION = '0.2.0' unless defined? OpenRegister::VERSION
  class RegistersClientManager
    def initialize(config_options = {})
      @config_options = defaults.merge(config_options)
      @register_clients = {}
    end

    def get_register(register, phase)
      key = register + ':' + phase

      if !@register_clients.key?(key)
        @register_clients[key] = RegistersClient::RegisterClient.new register, phase, @config_options
      end

      @register_clients[key]
    end

    private

    def defaults
      {
        cache_duration: 30,
        page_size: 100
      }
    end
  end
end