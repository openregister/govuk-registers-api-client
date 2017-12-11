require 'spec_helper'
require 'record'
require 'item'
require 'entry'

RSpec.describe RegistersClient::Record do
  Item_rsf_line = "add-item\t{\"citizen-names\":\"Briton;British citizen\",\"country\":\"GB\",\"name\":\"United Kingdom\"}"

  describe 'item' do
    it 'should return the item that the record initialized with' do
      expected_item = RegistersClient::Item.new(Item_rsf_line)
      record = RegistersClient::Record.new(RegistersClient::Entry.new("", 1), expected_item)

      expect(record.item).to eq(expected_item)
    end
  end

  describe 'entry' do
    it 'should return the entry that the record was initialized with' do
      rsf_line = "append-entry\tuser\tGB\t2016-04-05T13:23:05Z\tsha-256:daebe2747b982f485d64b78c982d549c5d509a43a7a409b59d2c5aa37c3238c2"
      expected_entry = RegistersClient::Entry.new(rsf_line, 1)
      record = RegistersClient::Record.new(expected_entry, RegistersClient::Item.new(Item_rsf_line))

      expect(record.entry).to eq(expected_entry)
    end
  end
end
