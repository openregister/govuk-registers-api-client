require 'register_client'

module RegistersClient
    VERSION = '0.5.0'
    class RegisterClientManager
      def initialize(config_options = {})
        @config_options = defaults.merge(config_options)
        @register_clients = {}
      end
  
      def get_register(register, phase)
        key = register + ':' + phase
  
        if !@register_clients.key?(key)
          @register_clients[key] = create_register_client(register, phase, @config_options)
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

      def create_register_client(register, phase, config_options)
        RegistersClient::RegisterClient.new(register, phase, config_options)
      end
    end
  end