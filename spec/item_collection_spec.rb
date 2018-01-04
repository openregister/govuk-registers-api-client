require 'spec_helper'
require 'item_collection'

RSpec.describe RegistersClient::ItemCollection do
  describe 'each' do
    it 'iterates over each item and finds in expected items' do
      expected_items = [{country: 'GB'}, {country: 'US'}]
      RegistersClient::ItemCollection.new(expected_items).each do |item|
        expect(expected_items.select{|i| i.fetch(:country) == item.fetch(:country)}.first).to eq(item)
      end
    end
  end

  describe 'page' do
    it 'returns all results when number of results is less than page size' do
      expected_items = [
          {country: 'GB'},
          {country: 'US'}
      ]

      results = RegistersClient::ItemCollection.new(expected_items, 4).page

      expect(results.length).to eq(2)
      expect(results).to eq(expected_items)
    end

    it 'returns correct page of results when number of results is greater than page size' do
      expected_items = [
          {country: 'GB'},
          {country: 'US'},
          {country: 'GM'},
          {country: 'CZ'},
          {country: 'VA'}
      ]

      results = RegistersClient::ItemCollection.new(expected_items, 4).page(2)

      expect(results.length).to eq(1)
      expect(results).to eq([{ country: 'VA'} ])
    end
  end
end
