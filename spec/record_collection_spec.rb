require 'spec_helper'
require 'record_collection'

RSpec.describe RegistersClient::RecordCollection do
  describe 'each' do
    it 'iterates over each record and finds in expected records' do
      expected_records = [{key: 'CZ'}, {key: 'GM'}]
      RegistersClient::RecordCollection.new(expected_records).each do |record|
        expect(expected_records.select{|r| r.fetch(:key) == record.fetch(:key)}.first).to eq(record)
      end
    end
  end

  describe 'page' do
    it 'returns all results when number of results is less than page size' do
      expected_records = [{key: 'CZ'}, {key: 'GM'}]

      results = RegistersClient::RecordCollection.new(expected_records, 4).page

      expect(results.length).to eq(2)
      expect(results).to eq(expected_records)
    end

    it 'returns correct page of results when number of results is greater than page size' do
      expected_records = [
        {key: 'CZ'},
        {key: 'GM'},
        {key: 'GB'},
        {key: 'US'},
        {key: 'ES'},
      ]

      results = RegistersClient::RecordCollection.new(expected_records, 4).page(2)

      expect(results.length).to eq(1)
      expect(results).to eq([{ key: 'ES' }])
    end
  end
end
