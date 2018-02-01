require 'register_client'
require 'in_memory_data_store'

module RegistersClient
    VERSION = '0.9.0'
    class RegisterClientManager
      def initialize(config_options = {})
        @config_options = defaults.merge(config_options)
        @register_clients = {}
      end
  
      def get_register(register, phase, data_store = nil)
        environment_url = get_environment_url_from_phase(phase)
        get_register_from_environment(register, environment_url, data_store)
      end

      def get_register_from_environment(register, environment_url, data_store = nil) 
        key = register + ':' + environment_url.to_s

        if !@register_clients.key?(key)
          if (data_store.nil?)
            data_store = RegistersClient::InMemoryDataStore.new(@config_options)
          end

          register_url = get_register_url(register, environment_url)
          @register_clients[key] = create_register_client(register_url, data_store, @config_options.fetch(:page_size))
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

      def create_register_client(register_url, data_store, page_size)
        RegistersClient::RegisterClient.new(register_url, data_store, page_size)
      end

      def get_register_url(register, environment_url)
        URI.parse(environment_url.to_s.sub('register', register))
      end

      def get_environment_url_from_phase(phase)
        case phase
        when 'beta'
          URI.parse('https://register.register.gov.uk')
        when 'discovery'
          URI.parse('https://register.cloudapps.digital')
        when 'alpha', 'test'
          URI.parse("https://register.#{phase}.openregister.org")
        else
          raise ArgumentError "Invalid phase '#{phase}'. Must be one of 'beta', 'alpha', 'discovery', 'test'."
        end
      end
    end
  end