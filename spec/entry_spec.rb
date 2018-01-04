require 'spec_helper'
require 'entry'

RSpec.describe RegistersClient::Entry do
  let(:entry_rsf_line) {"append-entry\tuser\tGB\t2016-04-05T13:23:05Z\tsha-256:6b18693874513ba13da54d61aafa7cad0c8f5573f3431d6f1c04b07ddb27d6bb"}
  let(:entry_type) {:user}

  describe 'entry_number' do
    it 'should return the entry number' do
      entry = RegistersClient::Entry.new(entry_rsf_line, 2, entry_type)

      expect(entry.entry_number).to eq(2)
    end
  end

  describe 'key' do
    it 'should return the key' do
      entry = RegistersClient::Entry.new(entry_rsf_line, 1, entry_type)

      expect(entry.key).to eq("GB")
    end
  end

  describe 'timestamp' do
    it 'should return the timestamp' do
      entry = RegistersClient::Entry.new(entry_rsf_line, 1, entry_type)

      expect(entry.timestamp).to eq("2016-04-05T13:23:05Z")
    end
  end

  describe 'item_hash' do
    it 'should return the item hash' do
      entry = RegistersClient::Entry.new(entry_rsf_line, 1, entry_type)

      expect(entry.item_hash).to eq("sha-256:6b18693874513ba13da54d61aafa7cad0c8f5573f3431d6f1c04b07ddb27d6bb")
    end
  end

  describe 'get_entry' do
    it 'should cache and return the entry after parsing the RSF' do
      entry = RegistersClient::Entry.new(entry_rsf_line, 1, entry_type)
      expect(entry).to receive(:parse_entry).once { { key: "GB", timestamp: "2016-04-05T13:23:05Z", item_hash: "sha-256:6b18693874513ba13da54d61aafa7cad0c8f5573f3431d6f1c04b07ddb27d6bb" } }

      result_first_call = entry.value
      result_second_call = entry.value

      expect(result_first_call).to equal(result_second_call)
    end
  end

  describe 'parse_entry' do
    it 'should not be called when Entry is instantiated' do
      entry = RegistersClient::Entry.new(entry_rsf_line, 1, entry_type)
      expect(entry).not_to receive(:parse_entry)
    end
  end
end
