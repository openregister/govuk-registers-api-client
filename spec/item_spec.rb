require 'spec_helper'
require 'item'
require 'json'

RSpec.describe RegistersClient::Item do
  Item_rsf_line = "add-item\t{\"citizen-names\":\"Briton;British citizen\",\"country\":\"GB\",\"name\":\"United Kingdom\"}"

  describe 'hash' do
    it 'should return the item hash after Item has been created' do
      item = RegistersClient::Item.new(Item_rsf_line)

      expect(item.hash).to eq("sha-256:0635c3f0fedd02c322db4528238a44d9bdbbf702795db33e892aab297afd97bb")
    end
  end

  describe 'value' do
    it 'should return the parsed item' do
      expected_item = JSON.parse("{\"citizen-names\":\"Briton;British citizen\",\"country\":\"GB\",\"name\":\"United Kingdom\"}")
      item = RegistersClient::Item.new(Item_rsf_line)
      result = item.value

      expect(result).to eq(expected_item)
    end

    it 'should cache and return the item after initially parsing the RSF' do
      expected_item = JSON.parse("{\"citizen-names\":\"Briton;British citizen\",\"country\":\"GB\",\"name\":\"United Kingdom\"}")
      item = RegistersClient::Item.new(Item_rsf_line)
      expect(item).to receive(:parse_item).once { expected_item }

      result_first_call = item.value
      result_second_call = item.value

      expect(result_first_call).to eq(expected_item), 'Expected item was not cached'
      expect(result_second_call).to equal(result_first_call), 'Returned items do not reference the same object'
    end
  end

  describe 'has_end_date' do
    item_no_end_date_rsf_line = "add-item\t{\"citizen-names\":\"Czechoslovak\",\"country\":\"CS\",\"name\":\"Czechoslovakia\"}"
    item_with_end_date_rsf_line = "add-item\t{\"citizen-names\":\"Czechoslovak\",\"country\":\"CS\",\"end-date\":\"1992-12-31\",\"name\":\"Czechoslovakia\"}"

    it 'should return false when item has no end date and the RSF has not been parsed' do
      item = RegistersClient::Item.new(item_no_end_date_rsf_line)

      expect(item.has_end_date).to eq(false)
    end

    it 'should return true when item has end date and the RSF has not been parsed' do
      item = RegistersClient::Item.new(item_with_end_date_rsf_line)

      expect(item.has_end_date).to eq(true)
    end

    it 'should return false when item has no end date and the RSF has been parsed' do
      item = RegistersClient::Item.new(item_no_end_date_rsf_line)
      item.value

      expect(item.has_end_date).to eq(false)
    end

    it 'should return true when item has end date and the RSF has been parsed' do
      item = RegistersClient::Item.new(item_with_end_date_rsf_line)
      item.value

      expect(item.has_end_date).to eq(true)
    end
  end

  describe 'parse_item' do
    it 'should not call to parse RSF when Item is initialized' do
      item = RegistersClient::Item.new(Item_rsf_line)

      expect(item).not_to receive(:parse_item)
    end
  end
end
