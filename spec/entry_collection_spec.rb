require 'spec_helper'
require 'entry_collection'

RSpec.describe RegistersClient::EntryCollection do
  describe 'each' do
    it 'iterates over each entry and finds in expected entries' do
      expected_entries = [{entry_number: 1}, {entry_number: 2}]
      RegistersClient::EntryCollection.new(expected_entries).each do |entry|
        expect(expected_entries[entry.fetch(:entry_number) - 1]).to eq(entry)
      end
    end
  end

  describe 'page' do
    it 'returns all results when number of results is less than page size' do
      expected_entries = [
          { entry_number: 1 },
          { entry_number: 2 }
      ]

      results = RegistersClient::EntryCollection.new(expected_entries, 4).page

      expect(results.length).to eq(2)
      expect(results).to eq(expected_entries)
    end

    it 'returns correct page of results when number of results is greater than page size' do
      expected_entries = [
        { entry_number: 1 },
        { entry_number: 2 },
        { entry_number: 3 },
        { entry_number: 4 },
        { entry_number: 5 },
      ]

      results = RegistersClient::EntryCollection.new(expected_entries, 4).page(2)

      expect(results.length).to eq(1)
      expect(results).to eq([{ entry_number: 5 }])
    end
  end
end
