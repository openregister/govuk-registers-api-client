require 'register_client'
require 'in_memory_data_store'

module RegistersClient
    VERSION = '0.8.0'
    class RegisterClientManager
      def initialize(config_options = {})
        @config_options = defaults.merge(config_options)
        @register_clients = {}
      end
  
      def get_register(register, phase, data_store = nil)
        key = register + ':' + phase

        if !@register_clients.key?(key)
          if (data_store.nil?)
            data_store = RegistersClient::InMemoryDataStore.new(@config_options)
          end

          @register_clients[key] = create_register_client(register, phase, data_store, @config_options.fetch(:page_size))
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

      def create_register_client(register, phase, data_store, page_size)
        RegistersClient::RegisterClient.new(register, phase, data_store, page_size)
      end
    end
  end