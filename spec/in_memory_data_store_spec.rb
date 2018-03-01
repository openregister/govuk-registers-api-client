require 'spec_helper'
require 'register_client'
require 'in_memory_data_store'

RSpec.describe RegistersClient::InMemoryDataStore do
  describe 'add_item' do
    before(:each) do
      @config_options = { page_size: 2 }
    end

    it 'should add item to the data store' do
      item_rsf_line = "add-item\t{\"citizen-names\":\"Czech\",\"country\":\"CZ\",\"name\":\"Czechia\",\"official-name\":\"The Czech Republic\",\"start-date\":\"1993-01-01\"}"
      item = RegistersClient::Item.new(item_rsf_line)

      data_store = RegistersClient::InMemoryDataStore.new(@config_options)
      data_store.add_item(item)

      expect(data_store.get_items.count).to eq(1)
      expect(data_store.get_items.first.hash).to eq("sha-256:c69c04fff98c59aabd739d43018e87a25fd51a00c37d100721cc68fa9003a720")
    end

  end

  describe 'append_entry' do
    before(:each) do
      @config_options = { page_size: 2 }
    end

    it 'should add entry and record to the data store' do
      item_rsf_line = "add-item\t{\"citizen-names\":\"Czech\",\"country\":\"CZ\",\"name\":\"Czechia\",\"official-name\":\"The Czech Republic\",\"start-date\":\"1993-01-01\"}"
      entry_rsf_line = "append-entry\tuser\tCZ\t2016-11-11T16:25:07Z\tsha-256:c69c04fff98c59aabd739d43018e87a25fd51a00c37d100721cc68fa9003a720"

      item = RegistersClient::Item.new(item_rsf_line)
      entry = RegistersClient::Entry.new(entry_rsf_line, 1, 'user')

      data_store = RegistersClient::InMemoryDataStore.new(@config_options)
      data_store.add_item(item)
      data_store.append_entry(entry)

      item = data_store.get_item('sha-256:c69c04fff98c59aabd739d43018e87a25fd51a00c37d100721cc68fa9003a720')
      entry = data_store.get_entry(:user, 1)
      record = data_store.get_record(:user, 'CZ')

      expect(data_store.get_entries(:user).count).to eq(1)
      expect(data_store.get_records(:user).count).to eq(1)
      expect(entry.key).to eq('CZ')
      expect(record.entry).to eq(entry)
      expect(record.item).to eq(item)
    end
  end

  describe 'get_item' do
    before(:each) do
      setup
    end

    it 'should get the item for the given item hash when it exists' do
      expected_item = RegistersClient::Item.new("add-item\t{\"citizen-names\":\"Czech\",\"country\":\"CZ\",\"name\":\"Czechia\",\"official-name\":\"The Czech Republic\",\"start-date\":\"1993-01-01\"}")

      item = @data_store.get_item("sha-256:c69c04fff98c59aabd739d43018e87a25fd51a00c37d100721cc68fa9003a720")

      expect(item.value).to eq(expected_item.value)
    end

    it 'should get nil for the given item hash when no such item exists' do
      item = @data_store.get_item("sha-256:abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz")

      expect(item).to eq(nil)
    end

  end

  describe 'get_items' do
    before(:each) do
      setup
    end

    it 'should get all items' do
      items = @data_store.get_items

      expect(items.count).to eq(19)
    end
  end

  describe 'get_entry' do
    before(:each) do
      setup
    end

    it 'should get the entry for the given entry type and entry number when it exists' do
      entry = @data_store.get_entry(:user, 3)

      expect(entry.key).to eq("GB")
      expect(entry.item_hash).to eq("sha-256:6b18693874513ba13da54d61aafa7cad0c8f5573f3431d6f1c04b07ddb27d6bb")
    end

    it 'should get nil for the given entry type and entry number when no such entry exists' do
      entry = @data_store.get_entry(:user, 8)

      expect(entry).to eq(nil)
    end
  end

  describe 'get_entries' do
    before(:each) do
      setup
    end

    it 'should get the all user entries' do
      actual_entries = @data_store.get_entries(:user)

      expect(actual_entries).to be_a(RegistersClient::EntryCollection)
      expect(actual_entries.count).to eq(7)
      expect(actual_entries.map { |e| e.key }).to contain_exactly("YU", "CS", "GB", "AF", "AL", "CZ", "CZ")
    end

    it 'should get the all system entries' do
      actual_entries = @data_store.get_entries(:system)

      expect(actual_entries).to be_a(RegistersClient::EntryCollection)
      expect(actual_entries.count).to eq(12)
      expect(actual_entries.map { |e| e.key }).to contain_exactly("name", "custodian", "field:country", "field:name", "field:official-name", "field:citizen-names", "field:start-date", "field:end-date", "register:country", "field:start-date", "field:end-date", "custodian")
    end
  end

  describe 'get_record' do
    before(:each) do
      setup
    end

    it 'should get the record for a given entry type and key when the record exists' do
      record = @data_store.get_record(:user, 'CZ')

      expect(record.entry.item_hash).to eq("sha-256:c69c04fff98c59aabd739d43018e87a25fd51a00c37d100721cc68fa9003a720")
    end

    it 'should get nil for a given entry type and key when no such record exists' do
      record = @data_store.get_record(:user, 'XYZ')

      expect(record).to eq(nil)
    end
  end

  describe 'get_records' do
    before(:each) do
      setup

      @expected_records = RegistersClient::RecordCollection.new([
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tuser\tYU\t2016-04-05T13:23:05Z\tsha-256:a074752a77011b18447401652029a9129c53b4ee35e1d99e6dec8b42ff4a0103", 1, :user),
            RegistersClient::Item.new("add-item\t{\"citizen-names\":\"Yugoslavian\",\"country\":\"YU\",\"end-date\":\"1992-04-28\",\"name\":\"Yugoslavia\",\"official-name\":\"Socialist Federal Republic of Yugoslavia\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tuser\tCS\t2016-04-05T13:23:05Z\tsha-256:0031f311f87260b07f4c7b25748cfdd8c2d2efa3c15fc98c33dd8563fafb6476", 2, :user),
            RegistersClient::Item.new("add-item\t{\"citizen-names\":\"Czechoslovak\",\"country\":\"CS\",\"end-date\":\"1992-12-31\",\"name\":\"Czechoslovakia\",\"official-name\":\"Czechoslovak Republic\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tuser\tGB\t2016-04-05T13:23:05Z\tsha-256:6b18693874513ba13da54d61aafa7cad0c8f5573f3431d6f1c04b07ddb27d6bb", 3, :user),
            RegistersClient::Item.new("add-item\t{\"citizen-names\":\"Briton;British citizen\",\"country\":\"GB\",\"name\":\"United Kingdom\",\"official-name\":\"The United Kingdom of Great Britain and Northern Ireland\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tuser\tAF\t2016-04-05T13:23:05Z\tsha-256:6bf7f01f268fa6d18e53eb7d5ebadb41c25c4aa2eedecfb7bc863e233ec99e24", 4, :user),
            RegistersClient::Item.new("add-item\t{\"citizen-names\":\"Afghan\",\"country\":\"AF\",\"name\":\"Afghanistan\",\"official-name\":\"The Islamic Republic of Afghanistan\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tuser\tAL\t2016-04-05T13:23:05Z\tsha-256:9d04a7e04ac92ab809a7471e7142617bc30a4b2d2f30c1002520a4a1d216f2a5", 5, :user),
            RegistersClient::Item.new("add-item\t{\"citizen-names\":\"Albanian\",\"country\":\"AL\",\"name\":\"Albania\",\"official-name\":\"The Republic of Albania\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tuser\tCZ\t2016-04-05T13:23:05Z\tsha-256:c69c04fff98c59aabd739d43018e87a25fd51a00c37d100721cc68fa9003a720", 5, :user),
            RegistersClient::Item.new("add-item\t{\"citizen-names\":\"Czech\",\"country\":\"CZ\",\"name\":\"Czechia\",\"official-name\":\"The Czech Republic\",\"start-date\":\"1993-01-01\"}")
        )
      ])

      @expected_metadata_records = RegistersClient::RecordCollection.new([
         RegistersClient::Record.new(
             RegistersClient::Entry.new("append-entry\tsystem\tname\t2017-07-17T10:59:47Z\tsha-256:d3d8e15fbd410e08bd896902fba40d4dd75a4a4ae34d98b87785f4b6965823ba", 1, :system),
             RegistersClient::Item.new("add-item\t{\"name\":\"country\"}")
         ),
         RegistersClient::Record.new(
             RegistersClient::Entry.new("append-entry\tsystem\tcustodian\t2017-11-02T11:18:00Z\tsha-256:aa98858fc2a8a9fae068c44908932d24b207defe526bdf75e3f6c049bb352927", 2, :system),
             RegistersClient::Item.new("add-item\t{\"custodian\":\"Joe Bloggs\"}")
         ),
         RegistersClient::Record.new(
             RegistersClient::Entry.new("append-entry\tsystem\tfield:country\t2017-01-10T17:16:07Z\tsha-256:a303d05bdbeb029440344e0f1148f5524b4a2f9076d1b0f36a95ff7d5eeedb0e", 3, :system),
             RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"string\",\"field\":\"country\",\"phase\":\"beta\",\"register\":\"country\",\"text\":\"The country's 2-letter ISO 3166-2 alpha2 code.\"}")
         ),
         RegistersClient::Record.new(
             RegistersClient::Entry.new("append-entry\tsystem\tfield:name\t2017-01-10T17:16:07Z\tsha-256:a7a9f2237dadcb3980f6ff8220279a3450778e9c78b6f0f12febc974d49a4a9f", 4, :system),
             RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"string\",\"field\":\"name\",\"phase\":\"beta\",\"text\":\"The commonly-used name of a record.\"}")
         ),
         RegistersClient::Record.new(
             RegistersClient::Entry.new("append-entry\tsystem\tfield:official-name\t2017-01-10T17:16:07Z\tsha-256:5c4728f439f6cbc6c7eea42992b858afc78c182962ba35d169f49db2c88e1e41", 5, :system),
             RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"string\",\"field\":\"official-name\",\"phase\":\"beta\",\"text\":\"The official or technical name of a record.\"}")
         ),
         RegistersClient::Record.new(
             RegistersClient::Entry.new("append-entry\tsystem\tfield:citizen-names\t2017-01-10T17:16:07Z\tsha-256:494f6fa9481b2d17d72b8fa4dcf91b72751b88c262c4c8f52012cb370afcfbd1", 6, :system),
             RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"string\",\"field\":\"citizen-names\",\"phase\":\"beta\",\"text\":\"The name of a country's citizens.\"}")
         ),
         RegistersClient::Record.new(
             RegistersClient::Entry.new("append-entry\tsystem\tfield:start-date\t2017-08-29T11:30:00Z\tsha-256:f09c439836eb6fccfb0680fa98dfc3d0300d1ceb2a43eb3c26b3eed01a42d2c2", 7, :system),
             RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"datetime\",\"field\":\"start-date\",\"phase\":\"beta\",\"text\":\"The date a record first became relevant to a register.\"}")
         ),
         RegistersClient::Record.new(
             RegistersClient::Entry.new("append-entry\tsystem\tfield:end-date\t2017-08-29T11:31:00Z\tsha-256:c5845bfc15577e8c120970ba084f1dc2c82b10e703f80d1efe4f694295a5a71d", 8, :system),
             RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"datetime\",\"field\":\"end-date\",\"phase\":\"beta\",\"text\":\"The date a record stopped being applicable.\"}")
         ),
         RegistersClient::Record.new(
             RegistersClient::Entry.new("append-entry\tsystem\tregister:country\t2016-08-04T14:45:41Z\tsha-256:610bde42d3ae2ed3dd829263fe461542742a10ca33865d96d31ae043b242c300", 9, :system),
             RegistersClient::Item.new("add-item\t{\"fields\":[\"country\",\"name\",\"official-name\",\"citizen-names\",\"start-date\",\"end-date\"],\"phase\":\"beta\",\"register\":\"country\",\"registry\":\"foreign-commonwealth-office\",\"text\":\"British English-language names and descriptive terms for countries\"}")
         )
       ])
    end

    it 'should get all the user records' do
      records = @data_store.get_records(:user)

      expect(records).to be_a(RegistersClient::RecordCollection)
      expect(records.count).to eq(6)
      expect(records.select{ |record| record.entry.key == 'CZ' }.first.entry.item_hash).to eq(@expected_records.to_a[5].entry.item_hash)
    end

    it 'should get all the metadata records' do
      records = @data_store.get_records(:system)

      expect(records).to be_a(RegistersClient::RecordCollection)
      expect(records.count).to eq(9)
      expect(records.select{ |record| record.entry.key == 'field:start-date' }.first.entry.item_hash).to eq(@expected_metadata_records.to_a[6].entry.item_hash)
    end

    it 'should pass the correct page size to the RecordCollection' do
      data_store = RegistersClient::InMemoryDataStore.new({ page_size: 2 })

      records = data_store.get_records(:user)

      expect(records.instance_variable_get('@page_size')).to eq(2)
    end
  end

  describe 'get_latest_entry_number' do
    before(:each) do
      setup
    end

    it 'should get the latest entry number' do
      user_entry_number = @data_store.get_latest_entry_number(:user)
      system_entry_number = @data_store.get_latest_entry_number(:system)

      expect(user_entry_number).to eq(7)
      expect(system_entry_number).to eq(12)
    end
  end

  def setup(config_options = {})
    dir = File.dirname(__FILE__)
    rsf = File.read(File.join(dir, 'fixtures/country_register.rsf'))

    @config_options = { page_size: 2 }.merge(config_options)
    @page_size = 100

    allow_any_instance_of(RegistersClient::RegisterClient).to receive(:download_rsf).with(0).and_return(rsf)

    @data_store = RegistersClient::InMemoryDataStore.new(@config_options)

    # Run the RSF through the data store
    RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, 2)
  end
end