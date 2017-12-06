require 'spec_helper'
require 'register_client_manager'

RSpec.describe RegistersClient::RegisterClientManager do
  describe 'get_register' do
    before(:each) do
      setup
    end

    it 'should create and return a new register client for the given register when one does not currently exist' do
      client_manager = RegistersClient::RegisterClientManager.new(@config_options)
      expect(client_manager).to receive(:create_register_client).with('country', 'test', @config_options).once { @country_test_register_client }

      register_client = client_manager.get_register("country", "test")

      expect(register_client).to eq(@country_test_register_client)
    end

    it 'should return the cached register client when one already exists for the given parameters' do
      client_manager = RegistersClient::RegisterClientManager.new(@config_options)
      expect(client_manager).to receive(:create_register_client).with('country', 'test', @config_options).once { @country_test_register_client }

      register_client = client_manager.get_register("country", "test")
      cached_register_client = client_manager.get_register("country", "test")

      expect(register_client).to eq(@country_test_register_client)
      expect(cached_register_client).to eq(register_client)
    end

    it 'should create multiple register clients when the given register is in multiple environments' do
      client_manager = RegistersClient::RegisterClientManager.new(@config_options)
      expect(client_manager).to receive(:create_register_client).with('country', 'test', @config_options).once { @country_test_register_client }
      expect(client_manager).to receive(:create_register_client).with('country', 'beta', @config_options).once { @country_beta_register_client }

      test_register_client = client_manager.get_register("country", "test")
      beta_register_client = client_manager.get_register("country", "beta")

      expect(test_register_client).to eq(@country_test_register_client)
      expect(beta_register_client).to eq(@country_beta_register_client)
    end

    it 'should create multiple register clients for different registers in the same environment' do
      client_manager = RegistersClient::RegisterClientManager.new(@config_options)
      expect(client_manager).to receive(:create_register_client).with('country', 'test', @config_options).once { @country_test_register_client }
      expect(client_manager).to receive(:create_register_client).with('field', 'test', @config_options).once { @field_test_register_client }

      country_test_register_client = client_manager.get_register("country", "test")
      field_test_register_client = client_manager.get_register("field", "test")

      expect(country_test_register_client).to eq(@country_test_register_client)
      expect(field_test_register_client).to eq(@field_test_register_client)
    end

    it 'should pass the correct config options to the register client' do
      client_manager = RegistersClient::RegisterClientManager.new({page_size: 30, cache_duration: 300 })

      register_client = client_manager.get_register("country", "test")

      expect(register_client.instance_variable_get('@config_options')).to eq({ page_size: 30, cache_duration: 300 })
    end
  end

  def setup
    dir = File.dirname(__FILE__)
    country_rsf = File.read(File.join(dir, 'fixtures/country_register.rsf'))
    field_rsf = File.read(File.join(dir, 'fixtures/field_register_test.rsf'))

    allow_any_instance_of(RegistersClient::RegisterClient).to receive(:download_rsf).with("country", "test").and_return(country_rsf)
    allow_any_instance_of(RegistersClient::RegisterClient).to receive(:download_rsf).with("country", "beta").and_return(country_rsf)
    allow_any_instance_of(RegistersClient::RegisterClient).to receive(:download_rsf).with("field", "test").and_return(field_rsf)

    @config_options = { page_size: 10, cache_duration: 60 }
    @field_test_register_client = RegistersClient::RegisterClient.new("field", "test", @config_options)
    @country_test_register_client = RegistersClient::RegisterClient.new("country", "test", @config_options)
    @country_beta_register_client = RegistersClient::RegisterClient.new("country", "beta", @config_options)
  end
end