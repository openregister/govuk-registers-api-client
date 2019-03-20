require 'spec_helper'
require 'register_client_manager'

RSpec.describe RegistersClient::RegisterClientManager do
  describe 'get_register' do
    before(:each) do
      setup
    end

    it 'should create and return a new register client for the given register when one does not currently exist' do
      client_manager = RegistersClient::RegisterClientManager.new(@config_options)
      options = { data_store: @country_test_data_store }
      expect(client_manager).to receive(:create_register_client).with(URI.parse('https://country.test.openregister.org'), @country_test_data_store, @page_size).once { @country_test_register_client }

      register_client = client_manager.get_register("country", "test", options)

      expect(register_client).to eq(@country_test_register_client)
    end

    it 'should return the cached register client when one already exists for the given parameters' do
      client_manager = RegistersClient::RegisterClientManager.new(@config_options)
      options = { data_store: @country_test_data_store }
      expect(client_manager).to receive(:create_register_client).with(URI.parse('https://country.test.openregister.org'), @country_test_data_store, @page_size).once { @country_test_register_client }

      register_client = client_manager.get_register("country", "test", options)
      cached_register_client = client_manager.get_register("country", "test", { data_store: @country_beta_data_store })

      expect(register_client).to eq(@country_test_register_client)
      expect(cached_register_client).to eq(register_client)
    end

    it 'should create multiple register clients when the given register is in multiple environments' do
      client_manager = RegistersClient::RegisterClientManager.new(@config_options)

      test_register_options = { data_store: @country_test_data_store }
      beta_register_options = { data_store: @country_beta_data_store }

      expect(client_manager).to receive(:create_register_client).with(URI.parse('https://country.test.openregister.org'), @country_test_data_store, @page_size).once { @country_test_register_client }
      expect(client_manager).to receive(:create_register_client).with(URI.parse('https://country.register.gov.uk'), @country_beta_data_store, @page_size).once { @country_beta_register_client }

      test_register_client = client_manager.get_register("country", "test", test_register_options)
      beta_register_client = client_manager.get_register("country", "beta", beta_register_options)

      expect(test_register_client).to eq(@country_test_register_client)
      expect(beta_register_client).to eq(@country_beta_register_client)
    end

    it 'should create multiple register clients for different registers in the same environment' do
      client_manager = RegistersClient::RegisterClientManager.new(@config_options)

      country_register_options = { data_store: @country_test_data_store }
      field_register_options = { data_store: @field_data_store }

      expect(client_manager).to receive(:create_register_client).with(URI.parse('https://country.test.openregister.org'), @country_test_data_store, @page_size).once { @country_test_register_client }
      expect(client_manager).to receive(:create_register_client).with(URI.parse('https://field.test.openregister.org'), @field_data_store, @page_size).once { @field_test_register_client }

      country_test_register_client = client_manager.get_register("country", "test", country_register_options)
      field_test_register_client = client_manager.get_register("field", "test", field_register_options)

      expect(country_test_register_client).to eq(@country_test_register_client)
      expect(field_test_register_client).to eq(@field_test_register_client)
    end

    it 'should pass the correct data store to the register client' do
      client_manager = RegistersClient::RegisterClientManager.new(@config_options)
      data_store = RegistersClient::InMemoryDataStore.new(@config_options)

      register_client = client_manager.get_register("country", "test", { data_store: data_store })

      expect(register_client.instance_variable_get('@data_store')).to eq(data_store)
    end

    it 'should create a new data store when no data store is passed in' do
      client_manager = RegistersClient::RegisterClientManager.new(@config_options)

      register_client = client_manager.get_register("country", "test")

      expect(register_client.instance_variable_get('@data_store')).to be_a(RegistersClient::InMemoryDataStore)
    end

    it 'should pass the correct page size to the register client' do
      client_manager = RegistersClient::RegisterClientManager.new({ page_size: 30 })

      register_client = client_manager.get_register("country", "test")

      expect(register_client.instance_variable_get('@page_size')).to eq(30)
    end

    it 'should pass the correct API key to the register client' do
      config_options = { api_key: "e4f1ea09-f7eb-4dde-a440-5c56cc96fe5f", page_size: 10 }
      client_manager = RegistersClient::RegisterClientManager.new(config_options)

      register_client = client_manager.get_register("country", "test")

      expect(register_client.instance_variable_get('@options')[:api_key]).to eq("e4f1ea09-f7eb-4dde-a440-5c56cc96fe5f")
    end

    it 'should use correct register URL given environment' do
      client_manager = RegistersClient::RegisterClientManager.new(@config_options)
      allow_any_instance_of(RegistersClient::RegisterClient).to receive(:refresh_data).and_return(nil)

      expect(client_manager.get_register("country", "beta").instance_variable_get(:@register_url)).to eq(URI.parse('https://country.register.gov.uk'))
      expect(client_manager.get_register("territory", "alpha").instance_variable_get(:@register_url)).to eq(URI.parse('https://territory.alpha.openregister.org'))
      expect(client_manager.get_register("vehicle", "discovery").instance_variable_get(:@register_url)).to eq(URI.parse('https://vehicle.cloudapps.digital'))
    end
  end

  def setup
    dir = File.dirname(__FILE__)
    country_rsf = File.read(File.join(dir, 'fixtures/country_register.rsf'))
    field_rsf = File.read(File.join(dir, 'fixtures/field_register_test.rsf'))

    @config_options = { page_size: 10 }
    @register_options = {}
    @page_size = 10
    @field_data_store = RegistersClient::InMemoryDataStore.new(@config_options)
    @country_test_data_store = RegistersClient::InMemoryDataStore.new(@config_options)
    @country_beta_data_store = RegistersClient::InMemoryDataStore.new(@config_options)

    stub_request(:get, "https://field.test.openregister.org/download-rsf/0").to_return(status: 200, body: field_rsf)
    stub_request(:get, "https://country.register.gov.uk/download-rsf/0").to_return(status: 200, body: country_rsf)
    stub_request(:get, "https://country.test.openregister.org/download-rsf/0").to_return(status: 200, body: country_rsf)

    @field_test_register_client = RegistersClient::RegisterClient.new(URI.parse('https://field.test.openregister.org'), @field_data_store, @page_size)
    @country_test_register_client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @country_test_data_store, @page_size)
    @country_beta_register_client = RegistersClient::RegisterClient.new(URI.parse('https://country.register.gov.uk'), @country_beta_data_store, @page_size)
  end
end