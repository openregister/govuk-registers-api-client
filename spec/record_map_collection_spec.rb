require 'spec_helper'
require 'record_map_collection'

RSpec.describe RegistersClient::RecordMapCollection do
  describe 'each' do
    it 'iterates over each record and finds in expected records' do
      expected_records = {}
      expected_records['GM'] = {key: 'GM', 'official-name': 'Gambia'}
      expected_records['CZ'] = {key: 'CZ', 'official-name': 'Czechia'}

      RegistersClient::RecordMapCollection.new(expected_records).each do |record|
        expected_record = expected_records[record.fetch(:key)]
        expect(record).to eq({key: record.fetch(:key), records: expected_record})
      end
    end
  end

  describe 'get_records_for_key' do
    it 'returns nil when record does not exist' do
      expected_record = {}
      expected_record['GM'] = {key: 'GM'}
      expected_record['CZ'] = {key: 'CZ'}
      client = RegistersClient::RecordMapCollection.new(expected_record)
      expect{client.get_records_for_key('ES')}.to raise_exception KeyError
    end

    it 'returns record when record exists' do
      expected_record = {}
      expected_record['GM'] = {key: 'GM'}
      expected_record['CZ'] = {key: 'CZ'}
      result = RegistersClient::RecordMapCollection.new(expected_record).get_records_for_key('CZ')

      expect(result).to eq(expected_record['CZ'])
    end
  end

  describe 'paginator' do
    it 'returns results as enumerator, in slices specified by the page size' do
      expected_records = {}
      expected_records['GM'] = {key: 'GM'}
      expected_records['CZ'] = {key: 'CZ'}
      expected_records['GB'] = {key: 'GB'}
      expected_records['US'] = {key: 'US'}
      expected_records['ES'] = {key: 'ES'}

      results = RegistersClient::RecordMapCollection.new(expected_records, 4).paginator
      page_results = results.next
      expect(page_results.length).to eq(4)
      expect(page_results.slice(0, 4)).to eq(page_results)

      page_results = results.next
      expect(page_results.length).to eq(1)
      expect([page_results.last]).to eq(page_results)
    end
  end
end
