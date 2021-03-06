require 'spec_helper'
require 'register_client'
require 'in_memory_data_store'

RSpec.describe RegistersClient::RegisterClient do
  describe 'get_item' do
    before(:each) do
      setup
    end

    it 'should get the user item for the given item hash when it exists' do
      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size)

      item = client.get_item('sha-256:c69c04fff98c59aabd739d43018e87a25fd51a00c37d100721cc68fa9003a720')

      expect(item.hash).to eq('sha-256:c69c04fff98c59aabd739d43018e87a25fd51a00c37d100721cc68fa9003a720')
    end

    it 'should get nil for the user item, for the given item hash when it does not exist' do
      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size)

      item = client.get_item('sha-256:abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz')

      expect(item).to eq(nil)
    end
  end

  describe 'get_items' do
    before(:each) do
      setup
    end

    it 'should get all items' do
      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size)

      items = client.get_items

      expect(items.count).to eq(19)
    end
  end

  describe 'get_entry' do
    before(:each) do
      setup
    end

    it 'should get the user entry for the given entry number when it exists' do
      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size)

      entry = client.get_entry(7)

      expect(entry.key).to eq('CZ')
      expect(entry.item_hash).to eq('sha-256:c69c04fff98c59aabd739d43018e87a25fd51a00c37d100721cc68fa9003a720')
    end

    it 'should get nil for the user entry, for the given entry number when it does not exist' do
      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size)

      entry = client.get_entry(8)

      expect(entry).to eq(nil)
    end
  end

  describe 'get_entries' do
    before(:each) do
      setup

      @expected_entries = RegistersClient::EntryCollection.new([
          RegistersClient::Entry.new("append-entry\tuser\tYU\t2016-04-05T13:23:05Z\tsha-256:a074752a77011b18447401652029a9129c53b4ee35e1d99e6dec8b42ff4a0103", 1, 'user'),
          RegistersClient::Entry.new("append-entry\tuser\tCS\t2016-04-05T13:23:05Z\tsha-256:0031f311f87260b07f4c7b25748cfdd8c2d2efa3c15fc98c33dd8563fafb6476", 2, 'user'),
          RegistersClient::Entry.new("append-entry\tuser\tGB\t2016-04-05T13:23:05Z\tsha-256:6b18693874513ba13da54d61aafa7cad0c8f5573f3431d6f1c04b07ddb27d6bb", 3, 'user'),
          RegistersClient::Entry.new("append-entry\tuser\tAF\t2016-04-05T13:23:05Z\tsha-256:6bf7f01f268fa6d18e53eb7d5ebadb41c25c4aa2eedecfb7bc863e233ec99e24", 4, 'user'),
          RegistersClient::Entry.new("append-entry\tuser\tAL\t2016-04-05T13:23:05Z\tsha-256:9d04a7e04ac92ab809a7471e7142617bc30a4b2d2f30c1002520a4a1d216f2a5", 5, 'user'),
          RegistersClient::Entry.new("append-entry\tuser\tCZ\t2016-04-05T13:23:05Z\tsha-256:c45bd0b4785680534e07c627a5eea0d2f065f0a4184a02ba2c1e643672c3f2ed", 6, 'user'),
          RegistersClient::Entry.new("append-entry\tuser\tCZ\t2016-04-05T13:23:05Z\tsha-256:c69c04fff98c59aabd739d43018e87a25fd51a00c37d100721cc68fa9003a720", 7, 'user')
      ])
    end

    it 'should get the all user entries' do
      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size)

      actual_entries = client.get_entries

      expect(actual_entries).to be_a(RegistersClient::EntryCollection)
      expect(actual_entries.count).to eq(7)
      expect(actual_entries.map { |e| e.key }).to contain_exactly("YU", "CS", "GB", "AF", "AL", "CZ", "CZ")
    end

    it 'should pass the correct page size to the EntryCollection' do
      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, 2)

      entries = client.get_entries

      expect(entries.instance_variable_get('@page_size')).to eq(2)
    end

    it 'should get a subset of entries when a start entry number is specified' do
      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size)

      actual_entries = client.get_entries(4)

      expect(actual_entries).to be_a(RegistersClient::EntryCollection)
      expect(actual_entries.count).to eq(3)
      expect(actual_entries.map { |e| e.key }).to contain_exactly("AL", "CZ", "CZ")
    end
  end

  describe 'get_record' do
    before(:each) do
      setup
    end

    it 'should get the user record for the given key when it exists' do
      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size)

      record = client.get_record('CZ')

      expect(record.entry.key).to eq('CZ')
      expect(record.entry.item_hash).to eq('sha-256:c69c04fff98c59aabd739d43018e87a25fd51a00c37d100721cc68fa9003a720')
      expect(record.item.hash).to eq('sha-256:c69c04fff98c59aabd739d43018e87a25fd51a00c37d100721cc68fa9003a720')
    end

    it 'should get nil for the user record, for the given key when it does not exist' do
      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size)

      record = client.get_record('XYZ')

      expect(record).to eq(nil)
    end
  end

  describe 'get_records' do
    before(:each) do
      setup

      @expected_records = RegistersClient::RecordCollection.new([
          RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tuser\tYU\t2016-04-05T13:23:05Z\tsha-256:a074752a77011b18447401652029a9129c53b4ee35e1d99e6dec8b42ff4a0103", 1, 'user'),
            RegistersClient::Item.new("add-item\t{\"citizen-names\":\"Yugoslavian\",\"country\":\"YU\",\"end-date\":\"1992-04-28\",\"name\":\"Yugoslavia\",\"official-name\":\"Socialist Federal Republic of Yugoslavia\"}")
          ),
          RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tuser\tCS\t2016-04-05T13:23:05Z\tsha-256:0031f311f87260b07f4c7b25748cfdd8c2d2efa3c15fc98c33dd8563fafb6476", 2, 'user'),
            RegistersClient::Item.new("add-item\t{\"citizen-names\":\"Czechoslovak\",\"country\":\"CS\",\"end-date\":\"1992-12-31\",\"name\":\"Czechoslovakia\",\"official-name\":\"Czechoslovak Republic\"}")
          ),
          RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tuser\tGB\t2016-04-05T13:23:05Z\tsha-256:6b18693874513ba13da54d61aafa7cad0c8f5573f3431d6f1c04b07ddb27d6bb", 3, 'user'),
            RegistersClient::Item.new("add-item\t{\"citizen-names\":\"Briton;British citizen\",\"country\":\"GB\",\"name\":\"United Kingdom\",\"official-name\":\"The United Kingdom of Great Britain and Northern Ireland\"}")
          ),
          RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tuser\tAF\t2016-04-05T13:23:05Z\tsha-256:6bf7f01f268fa6d18e53eb7d5ebadb41c25c4aa2eedecfb7bc863e233ec99e24", 4, 'user'),
            RegistersClient::Item.new("add-item\t{\"citizen-names\":\"Afghan\",\"country\":\"AF\",\"name\":\"Afghanistan\",\"official-name\":\"The Islamic Republic of Afghanistan\"}")
          ),
          RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tuser\tAL\t2016-04-05T13:23:05Z\tsha-256:9d04a7e04ac92ab809a7471e7142617bc30a4b2d2f30c1002520a4a1d216f2a5", 5, 'user'),
            RegistersClient::Item.new("add-item\t{\"citizen-names\":\"Albanian\",\"country\":\"AL\",\"name\":\"Albania\",\"official-name\":\"The Republic of Albania\"}")
          ),
          RegistersClient::Record.new(
              RegistersClient::Entry.new("append-entry\tuser\tCZ\t2016-04-05T13:23:05Z\tsha-256:c69c04fff98c59aabd739d43018e87a25fd51a00c37d100721cc68fa9003a720", 5, 'user'),
              RegistersClient::Item.new("add-item\t{\"citizen-names\":\"Czech\",\"country\":\"CZ\",\"name\":\"Czechia\",\"official-name\":\"The Czech Republic\",\"start-date\":\"1993-01-01\"}")
          )
      ])
    end

    it 'should get all the user records' do
      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size)

      records = client.get_records

      expect(records).to be_a(RegistersClient::RecordCollection)
      expect(records.count).to eq(6)
      expect(records.select{ |record| record.entry.key == 'CZ' }.first.entry.item_hash).to eq(@expected_records.to_a[5].entry.item_hash)
    end

    it 'should pass the correct page size to the RecordCollection' do
      data_store = RegistersClient::InMemoryDataStore.new({ page_size: 2 })
      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), data_store, 2)

      records = client.get_records

      expect(records.instance_variable_get('@page_size')).to eq(2)
    end
  end

  describe 'get_records_with_history' do
    before(:each) do
      setup
    end

    it 'should get records with history' do
      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size)

      records_with_history = client.get_records_with_history

      expect(records_with_history).to be_a(RegistersClient::RecordMapCollection)
      expect(records_with_history.count).to eq(6)
      expect(records_with_history.get_records_for_key('CZ')[0].item.hash).to eq("sha-256:c45bd0b4785680534e07c627a5eea0d2f065f0a4184a02ba2c1e643672c3f2ed")
      expect(records_with_history.get_records_for_key('CZ')[1].item.hash).to eq("sha-256:c69c04fff98c59aabd739d43018e87a25fd51a00c37d100721cc68fa9003a720")
    end

    it 'should get a subset of records with history when a start entry number is specified' do
      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size)

      records_with_history = client.get_records_with_history(3)

      expect(records_with_history).to be_a(RegistersClient::RecordMapCollection)
      expect(records_with_history.count).to eq(3)
      expect(records_with_history.get_records_for_key('AF')[0].item.hash).to eq("sha-256:6bf7f01f268fa6d18e53eb7d5ebadb41c25c4aa2eedecfb7bc863e233ec99e24")
      expect(records_with_history.get_records_for_key('AL')[0].item.hash).to eq("sha-256:9d04a7e04ac92ab809a7471e7142617bc30a4b2d2f30c1002520a4a1d216f2a5")
      expect(records_with_history.get_records_for_key('CZ')[1].item.hash).to eq("sha-256:c69c04fff98c59aabd739d43018e87a25fd51a00c37d100721cc68fa9003a720")
    end
  end

  describe 'get_metadata_records' do
    before(:each) do
      setup

      @expected_records = RegistersClient::RecordCollection.new([
        RegistersClient::Record.new(
         RegistersClient::Entry.new("append-entry\tsystem\tname\t2017-07-17T10:59:47Z\tsha-256:d3d8e15fbd410e08bd896902fba40d4dd75a4a4ae34d98b87785f4b6965823ba", 1, 'system'),
         RegistersClient::Item.new("add-item\t{\"name\":\"country\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tsystem\tcustodian\t2017-11-02T11:18:00Z\tsha-256:aa98858fc2a8a9fae068c44908932d24b207defe526bdf75e3f6c049bb352927", 2, 'system'),
            RegistersClient::Item.new("add-item\t{\"custodian\":\"Joe Bloggs\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tsystem\tfield:country\t2017-01-10T17:16:07Z\tsha-256:a303d05bdbeb029440344e0f1148f5524b4a2f9076d1b0f36a95ff7d5eeedb0e", 3, 'system'),
            RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"string\",\"field\":\"country\",\"phase\":\"beta\",\"register\":\"country\",\"text\":\"The country's 2-letter ISO 3166-2 alpha2 code.\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tsystem\tfield:name\t2017-01-10T17:16:07Z\tsha-256:a7a9f2237dadcb3980f6ff8220279a3450778e9c78b6f0f12febc974d49a4a9f", 4, 'system'),
            RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"string\",\"field\":\"name\",\"phase\":\"beta\",\"text\":\"The commonly-used name of a record.\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tsystem\tfield:official-name\t2017-01-10T17:16:07Z\tsha-256:5c4728f439f6cbc6c7eea42992b858afc78c182962ba35d169f49db2c88e1e41", 5, 'system'),
            RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"string\",\"field\":\"official-name\",\"phase\":\"beta\",\"text\":\"The official or technical name of a record.\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tsystem\tfield:citizen-names\t2017-01-10T17:16:07Z\tsha-256:494f6fa9481b2d17d72b8fa4dcf91b72751b88c262c4c8f52012cb370afcfbd1", 6, 'system'),
            RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"string\",\"field\":\"citizen-names\",\"phase\":\"beta\",\"text\":\"The name of a country's citizens.\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tsystem\tfield:start-date\t2017-08-29T11:30:00Z\tsha-256:f09c439836eb6fccfb0680fa98dfc3d0300d1ceb2a43eb3c26b3eed01a42d2c2", 7, 'system'),
            RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"datetime\",\"field\":\"start-date\",\"phase\":\"beta\",\"text\":\"The date a record first became relevant to a register.\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tsystem\tfield:end-date\t2017-08-29T11:31:00Z\tsha-256:c5845bfc15577e8c120970ba084f1dc2c82b10e703f80d1efe4f694295a5a71d", 8, 'system'),
            RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"datetime\",\"field\":\"end-date\",\"phase\":\"beta\",\"text\":\"The date a record stopped being applicable.\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tsystem\tregister:country\t2016-08-04T14:45:41Z\tsha-256:610bde42d3ae2ed3dd829263fe461542742a10ca33865d96d31ae043b242c300", 9, 'system'),
            RegistersClient::Item.new("add-item\t{\"fields\":[\"country\",\"name\",\"official-name\",\"citizen-names\",\"start-date\",\"end-date\"],\"phase\":\"beta\",\"register\":\"country\",\"registry\":\"foreign-commonwealth-office\",\"text\":\"British English-language names and descriptive terms for countries\"}")
        )
      ])
    end

    it 'should get all the metadata records' do
      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size)

      records = client.get_metadata_records

      expect(records).to be_a(RegistersClient::RecordCollection)
      expect(records.count).to eq(9)
      expect(records.select{ |record| record.entry.key == 'field:start-date' }.first.entry.item_hash).to eq(@expected_records.to_a[6].entry.item_hash)
    end
  end

  describe 'get_metadata_records_with_history' do
    before(:each) do
      setup
    end

    it 'should get metadata records with history' do
      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size)

      metadata_records_with_history = client.get_metadata_records_with_history

      expect(metadata_records_with_history).to be_a(RegistersClient::RecordMapCollection)
      expect(metadata_records_with_history.count).to eq(9)
      expect(metadata_records_with_history.get_records_for_key('field:start-date')[0].item.hash).to eq("sha-256:1cff4c622577fabd35917760b04bc304af3b950e19735b60152c19f18b55e75e")
      expect(metadata_records_with_history.get_records_for_key('field:start-date')[1].item.hash).to eq("sha-256:f09c439836eb6fccfb0680fa98dfc3d0300d1ceb2a43eb3c26b3eed01a42d2c2")
    end

    it 'should get a subset of metadata records with history when a start entry number is specified' do
      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size)

      metadata_records_with_history = client.get_metadata_records_with_history(9)

      expect(metadata_records_with_history).to be_a(RegistersClient::RecordMapCollection)
      expect(metadata_records_with_history.count).to eq(3)
      expect(metadata_records_with_history.get_records_for_key('field:start-date')[0].item.hash).to eq("sha-256:f09c439836eb6fccfb0680fa98dfc3d0300d1ceb2a43eb3c26b3eed01a42d2c2")
      expect(metadata_records_with_history.get_records_for_key('field:end-date')[0].item.hash).to eq("sha-256:c5845bfc15577e8c120970ba084f1dc2c82b10e703f80d1efe4f694295a5a71d")
      expect(metadata_records_with_history.get_records_for_key('custodian')[0].item.hash).to eq("sha-256:f9842397c9188c9f8e6a05c0728edb115880f62d39f07ab260cced3b6254941c")
    end
  end

  describe 'get_field_definitions' do
    before(:each) do
      setup

      @expected_records = RegistersClient::RecordCollection.new([
        RegistersClient::Record.new(
          RegistersClient::Entry.new("append-entry\tsystem\tfield:country\t2017-01-10T17:16:07Z\tsha-256:a303d05bdbeb029440344e0f1148f5524b4a2f9076d1b0f36a95ff7d5eeedb0e", 3, 'system'),
          RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"string\",\"field\":\"country\",\"phase\":\"beta\",\"register\":\"country\",\"text\":\"The country's 2-letter ISO 3166-2 alpha2 code.\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tsystem\tfield:name\t2017-01-10T17:16:07Z\tsha-256:a7a9f2237dadcb3980f6ff8220279a3450778e9c78b6f0f12febc974d49a4a9f", 4, 'system'),
            RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"string\",\"field\":\"name\",\"phase\":\"beta\",\"text\":\"The commonly-used name of a record.\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tsystem\tfield:official-name\t2017-01-10T17:16:07Z\tsha-256:5c4728f439f6cbc6c7eea42992b858afc78c182962ba35d169f49db2c88e1e41", 5, 'system'),
            RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"string\",\"field\":\"official-name\",\"phase\":\"beta\",\"text\":\"The official or technical name of a record.\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tsystem\tfield:citizen-names\t2017-01-10T17:16:07Z\tsha-256:494f6fa9481b2d17d72b8fa4dcf91b72751b88c262c4c8f52012cb370afcfbd1", 6, 'system'),
            RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"string\",\"field\":\"citizen-names\",\"phase\":\"beta\",\"text\":\"The name of a country's citizens.\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tsystem\tfield:start-date\t2017-08-29T11:30:00Z\tsha-256:f09c439836eb6fccfb0680fa98dfc3d0300d1ceb2a43eb3c26b3eed01a42d2c2", 7, 'system'),
            RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"datetime\",\"field\":\"start-date\",\"phase\":\"beta\",\"text\":\"The date a record first became relevant to a register.\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tsystem\tfield:end-date\t2017-08-29T11:31:00Z\tsha-256:c5845bfc15577e8c120970ba084f1dc2c82b10e703f80d1efe4f694295a5a71d", 8, 'system'),
            RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"datetime\",\"field\":\"end-date\",\"phase\":\"beta\",\"text\":\"The date a record stopped being applicable.\"}")
        )
      ])
    end

    it 'should get the current field definitions' do
      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size)

      records = client.get_field_definitions

      expect(records.count).to eq(6)
      expect(records.select{ |record| record.entry.key == 'field:end-date' }.first.entry.item_hash).to eq(@expected_records.to_a[5].entry.item_hash)
      expect(records.select{ |record| record.entry.key == 'field:end-date' }.first.item.hash).to eq(@expected_records.to_a[5].entry.item_hash)
    end

    it 'should order fields as specified in the register definition' do
      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size)

      fields = client.get_field_definitions.map { |field| field.item.value['field'] }
      register_definition = client.get_register_definition

      expect(fields).to eq(["country","name","official-name","citizen-names","start-date","end-date"])
      expect(fields).to eq(register_definition.item.value['fields'])
    end
  end

  describe 'get_register_definition' do
    before(:each) do
      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size)
      expected_item = RegistersClient::Item.new("add-item\t{\"fields\":[\"country\",\"name\",\"official-name\",\"citizen-names\",\"start-date\",\"end-date\"],\"phase\":\"beta\",\"register\":\"country\",\"registry\":\"foreign-commonwealth-office\",\"text\":\"British English-language names and descriptive terms for countries\"}")

      record = client.get_register_definition

      expect(record).to be_a(RegistersClient::Record)
      expect(record.entry.item_hash).to eq(expected_item.hash)
      expect(record.item.hash).to eq(expected_item.hash)
    end
  end

  describe 'get_custodian' do
    before(:each) do
      setup
    end

    it 'should get the correct custodian when the custodian has been updated' do
      pending('This will fail until system and user entry logs are merged as it relies on RSF that ORJ will never produce')
      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size)
      expected_custodian = RegistersClient::Item.new("add-item\t{\"custodian\":\"Joe Bloggs\"}")
      expected_updated_custodian = RegistersClient::Item.new("add-item\t{\"custodian\":\"Joseph Bloggs\"}")

      record = client.get_custodian

      expect(record).to be_a(RegistersClient::Record)
      expect(record.entry.item_hash).to eq(expected_custodian.hash)
      expect(record.item.hash).to eq(expected_custodian.hash)

      client.refresh_data
      record = client.get_custodian

      expect(record.entry.item_hash).to eq(expected_updated_custodian.hash)
      expect(record.item.hash).to eq(expected_updated_custodian.hash)
    end
  end

  describe 'get_current_records' do
    before(:each) do
      setup
    end

    it 'should get the current records' do
      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size)
      records = client.get_current_records

      expect(records.count).to eq(4)
      expect(records.map { |record| record.entry.key }).to contain_exactly("GB", "AF", "AL", "CZ")
    end
  end

  describe 'get_expired_records' do
    before(:each) do
      setup
    end

    it 'should get the expired records' do
      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size)
      records = client.get_expired_records

      expect(records.count).to eq(2)
      expect(records.map { |record| record.entry.key }).to contain_exactly("YU", "CS")
    end
  end

  describe 'refresh_data' do
    before(:each) do |example|
      unless example.metadata[:skip_before]
        setup
      end
    end

    it 'should update the downloaded register data' do
      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size)
      records = client.get_records
      entries = client.get_entries

      expect(records.count).to eq(6)
      expect(entries.count).to eq(7)

      client.refresh_data
      records = client.get_records
      entries = client.get_entries

      expect(records.count).to eq(7)
      expect(entries.count).to eq(9)
    end

    it 'should keep the existing register data when no new updates exist' do
      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size)
      client.refresh_data
      records = client.get_records
      entries = client.get_entries

      expect(records.count).to eq(7)
      expect(entries.count).to eq(9)

      client.refresh_data
      records = client.get_records
      entries = client.get_entries

      expect(records.count).to eq(7)
      expect(entries.count).to eq(9)
    end

    it 'should not store system entries if system entries already exist in datastore', :skip_before do
      dir = File.dirname(__FILE__)
      rsf_empty_register = File.read(File.join(dir, 'fixtures/country_register_system_only.rsf'))
      rsf_with_user_data = File.read(File.join(dir, 'fixtures/country_register.rsf'))
      
      @config_options = { page_size: 100 }
      @page_size = 100
      @data_store = RegistersClient::InMemoryDataStore.new(@config_options)

      allow_any_instance_of(RegistersClient::RegisterClient).to receive(:download_rsf).with(0).and_return(rsf_empty_register)
      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size)

      expect(@data_store.get_latest_entry_number(:system)).to eq(12)
      expect(@data_store.get_latest_entry_number(:user)).to eq(0)

      allow_any_instance_of(RegistersClient::RegisterClient).to receive(:download_rsf).with(0).and_return(rsf_with_user_data)
      client.refresh_data

      expect(@data_store.get_latest_entry_number(:system)).to eq(12)
      expect(@data_store.get_latest_entry_number(:user)).to eq(7)
    end

    it 'should get the current user entry number from the datastore before refreshing data' do
      data_store = instance_double("InMemoryDataStore")
      allow(data_store).to receive(:get_latest_entry_number).with(:user).and_return(9)
      allow(data_store).to receive(:get_latest_entry_number).with(:system).and_return(13)
      allow(data_store).to receive(:after_load)

      RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), data_store, @page_size)

      expect(data_store).to have_received(:get_latest_entry_number).with(:user)
      expect(data_store).to have_received(:get_latest_entry_number).with(:system)
    end

    it 'should not set the Auth header in the download request when API is not present' do
      options = {}

      expect(RestClient).to receive(:get).with('https://country.test.openregister.org/download', user_agent: 'CL').once

      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size, options)
      client.send(:register_http_request, "https://country.test.openregister.org/download")
    end

    it 'should set the Auth header in the download request when API key is present' do
      api_key = "f5f53ca1-3408-4034-8ba7-008e8e75f5ea"
      options = {
          api_key: api_key
      }

      expect(RestClient).to receive(:get).with('https://country.test.openregister.org/download', Authorization: api_key, user_agent: 'CL').once

      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size, options)
      client.send(:register_http_request, "https://country.test.openregister.org/download")
    end

      it 'should set the user agent header on the request' do
      options = {}

      expect(RestClient).to receive(:get).with('https://country.test.openregister.org/download', user_agent: 'CL').once

      client = RegistersClient::RegisterClient.new(URI.parse('https://country.test.openregister.org'), @data_store, @page_size, options)
      client.send(:register_http_request, "https://country.test.openregister.org/download")
    end
  end

  def setup(config_options = {})
    dir = File.dirname(__FILE__)
    rsf = File.read(File.join(dir, 'fixtures/country_register.rsf'))
    update_rsf = File.read(File.join(dir, 'fixtures/country_register_update.rsf'))
    no_new_updates_rsf = "assert-root-hash\tsha-256:fa87bc961ed7fa6dde75db82cda8a6df8d8427da36bbf448fff6b177c2486cdb"

    @config_options = { page_size: 100 }.merge(config_options)
    @page_size = 100
    @data_store = RegistersClient::InMemoryDataStore.new(@config_options)

    allow_any_instance_of(RegistersClient::RegisterClient).to receive(:download_rsf).with(0).and_return(rsf)
    allow_any_instance_of(RegistersClient::RegisterClient).to receive(:download_rsf).with(7).and_return(update_rsf)
    allow_any_instance_of(RegistersClient::RegisterClient).to receive(:download_rsf).with(9).and_return(no_new_updates_rsf)
  end
end