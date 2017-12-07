require 'spec_helper'
require 'registers_client'

RSpec.describe RegistersClient do
  before(:each) do
    stub_request(:get, 'https://industrial-classification.alpha.openregister.org/download-rsf').
    to_return(status: 200, body: File.read('./spec/fixtures/industrial-classification.rsf'), headers: {})
  end

  it 'orders fields according to register definition' do
    registers_client = RegistersClient::RegistersClientManager.new
    register_data = registers_client.get_register 'industrial-classification', 'alpha'
    fields = register_data.get_field_definitions.map{|f| f[:item]['field'] }
    expect(fields).to eq(["industrial-classification", "parent-industrial-classification", "name", "start-date", "end-date"])
    expect(fields).to eq(register_data.get_register_definition[:item]['fields'])
  end
end
