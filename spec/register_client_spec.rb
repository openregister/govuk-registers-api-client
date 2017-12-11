require 'spec_helper'
require 'register_client'

RSpec.describe RegistersClient::RegisterClient do
  describe 'get_entries' do
    before(:each) do
      setup

      @expected_entries = RegistersClient::EntryCollection.new([
          RegistersClient::Entry.new("append-entry\tuser\tYU\t2016-04-05T13:23:05Z\tsha-256:a074752a77011b18447401652029a9129c53b4ee35e1d99e6dec8b42ff4a0103", 1),
          RegistersClient::Entry.new("append-entry\tuser\tCS\t2016-04-05T13:23:05Z\tsha-256:0031f311f87260b07f4c7b25748cfdd8c2d2efa3c15fc98c33dd8563fafb6476", 2),
          RegistersClient::Entry.new("append-entry\tuser\tGB\t2016-04-05T13:23:05Z\tsha-256:6b18693874513ba13da54d61aafa7cad0c8f5573f3431d6f1c04b07ddb27d6bb", 3),
          RegistersClient::Entry.new("append-entry\tuser\tAF\t2016-04-05T13:23:05Z\tsha-256:6bf7f01f268fa6d18e53eb7d5ebadb41c25c4aa2eedecfb7bc863e233ec99e24", 4),
          RegistersClient::Entry.new("append-entry\tuser\tAL\t2016-04-05T13:23:05Z\tsha-256:9d04a7e04ac92ab809a7471e7142617bc30a4b2d2f30c1002520a4a1d216f2a5", 5),
          RegistersClient::Entry.new("append-entry\tuser\tCZ\t2016-04-05T13:23:05Z\tsha-256:c45bd0b4785680534e07c627a5eea0d2f065f0a4184a02ba2c1e643672c3f2ed", 6),
          RegistersClient::Entry.new("append-entry\tuser\tCZ\t2016-04-05T13:23:05Z\tsha-256:c69c04fff98c59aabd739d43018e87a25fd51a00c37d100721cc68fa9003a720", 7)
      ])
    end

    it 'should get the all user entries' do
      client = RegistersClient::RegisterClient.new("country", "test", @config_options)

      actual_entries = client.get_entries

      expect(actual_entries).to be_a(RegistersClient::EntryCollection)
      expect(actual_entries.count).to eq(7)
      expect(actual_entries.map { |e| e.key }).to contain_exactly("YU", "CS", "GB", "AF", "AL", "CZ", "CZ")
    end

    it 'should pass the correct page size to the EntryCollection' do
      client = RegistersClient::RegisterClient.new("country", "test", { page_size: 2 })

      entries = client.get_entries

      expect(entries.instance_variable_get('@page_size')).to eq(2)
    end
  end

  describe 'get_records' do
    before(:each) do
      setup

      @expected_records = RegistersClient::RecordCollection.new([
          RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tuser\tYU\t2016-04-05T13:23:05Z\tsha-256:a074752a77011b18447401652029a9129c53b4ee35e1d99e6dec8b42ff4a0103", 1),
            RegistersClient::Item.new("add-item\t{\"citizen-names\":\"Yugoslavian\",\"country\":\"YU\",\"end-date\":\"1992-04-28\",\"name\":\"Yugoslavia\",\"official-name\":\"Socialist Federal Republic of Yugoslavia\"}")
          ),
          RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tuser\tCS\t2016-04-05T13:23:05Z\tsha-256:0031f311f87260b07f4c7b25748cfdd8c2d2efa3c15fc98c33dd8563fafb6476", 2),
            RegistersClient::Item.new("add-item\t{\"citizen-names\":\"Czechoslovak\",\"country\":\"CS\",\"end-date\":\"1992-12-31\",\"name\":\"Czechoslovakia\",\"official-name\":\"Czechoslovak Republic\"}")
          ),
          RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tuser\tGB\t2016-04-05T13:23:05Z\tsha-256:6b18693874513ba13da54d61aafa7cad0c8f5573f3431d6f1c04b07ddb27d6bb", 3),
            RegistersClient::Item.new("add-item\t{\"citizen-names\":\"Briton;British citizen\",\"country\":\"GB\",\"name\":\"United Kingdom\",\"official-name\":\"The United Kingdom of Great Britain and Northern Ireland\"}")
          ),
          RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tuser\tAF\t2016-04-05T13:23:05Z\tsha-256:6bf7f01f268fa6d18e53eb7d5ebadb41c25c4aa2eedecfb7bc863e233ec99e24", 4),
            RegistersClient::Item.new("add-item\t{\"citizen-names\":\"Afghan\",\"country\":\"AF\",\"name\":\"Afghanistan\",\"official-name\":\"The Islamic Republic of Afghanistan\"}")
          ),
          RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tuser\tAL\t2016-04-05T13:23:05Z\tsha-256:9d04a7e04ac92ab809a7471e7142617bc30a4b2d2f30c1002520a4a1d216f2a5", 5),
            RegistersClient::Item.new("add-item\t{\"citizen-names\":\"Albanian\",\"country\":\"AL\",\"name\":\"Albania\",\"official-name\":\"The Republic of Albania\"}")
          ),
          RegistersClient::Record.new(
              RegistersClient::Entry.new("append-entry\tuser\tCZ\t2016-04-05T13:23:05Z\tsha-256:c69c04fff98c59aabd739d43018e87a25fd51a00c37d100721cc68fa9003a720", 5),
              RegistersClient::Item.new("add-item\t{\"citizen-names\":\"Czech\",\"country\":\"CZ\",\"name\":\"Czechia\",\"official-name\":\"The Czech Republic\",\"start-date\":\"1993-01-01\"}")
          )
      ])
    end

    it 'should get all the user records' do
      client = RegistersClient::RegisterClient.new("country", "test", @config_options)

      records = client.get_records

      expect(records).to be_a(RegistersClient::RecordCollection)
      expect(records.count).to eq(6)
      expect(records.select{ |record| record.entry.key == 'CZ' }.first.entry.item_hash).to eq(@expected_records.to_a[5].entry.item_hash)
    end

    it 'should pass the correct page size to the RecordCollection' do
      client = RegistersClient::RegisterClient.new("country", "test", { page_size: 2 })

      records = client.get_records

      expect(records.instance_variable_get('@page_size')).to eq(2)
    end
  end

  describe 'get_records_with_history' do
    before(:each) do
      setup
    end

    it 'should get records with history' do
      client = RegistersClient::RegisterClient.new("country", "test", @config_options)

      records_with_history = client.get_records_with_history

      expect(records_with_history).to be_a(RegistersClient::RecordMapCollection)
      expect(records_with_history.count).to eq(6)
      expect(records_with_history.get_records_for_key('CZ')[0].item.hash).to eq("sha-256:c45bd0b4785680534e07c627a5eea0d2f065f0a4184a02ba2c1e643672c3f2ed")
      expect(records_with_history.get_records_for_key('CZ')[1].item.hash).to eq("sha-256:c69c04fff98c59aabd739d43018e87a25fd51a00c37d100721cc68fa9003a720")
    end
  end

  describe 'get_metadata_records' do
    before(:each) do
      setup

      @expected_records = RegistersClient::RecordCollection.new([
        RegistersClient::Record.new(
         RegistersClient::Entry.new("append-entry\tsystem\tname\t2017-07-17T10:59:47Z\tsha-256:d3d8e15fbd410e08bd896902fba40d4dd75a4a4ae34d98b87785f4b6965823ba", 1),
         RegistersClient::Item.new("add-item\t{\"name\":\"country\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tsystem\tcustodian\t2017-11-02T11:18:00Z\tsha-256:aa98858fc2a8a9fae068c44908932d24b207defe526bdf75e3f6c049bb352927", 2),
            RegistersClient::Item.new("add-item\t{\"custodian\":\"Joe Bloggs\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tsystem\tfield:country\t2017-01-10T17:16:07Z\tsha-256:a303d05bdbeb029440344e0f1148f5524b4a2f9076d1b0f36a95ff7d5eeedb0e", 3),
            RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"string\",\"field\":\"country\",\"phase\":\"beta\",\"register\":\"country\",\"text\":\"The country's 2-letter ISO 3166-2 alpha2 code.\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tsystem\tfield:name\t2017-01-10T17:16:07Z\tsha-256:a7a9f2237dadcb3980f6ff8220279a3450778e9c78b6f0f12febc974d49a4a9f", 4),
            RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"string\",\"field\":\"name\",\"phase\":\"beta\",\"text\":\"The commonly-used name of a record.\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tsystem\tfield:official-name\t2017-01-10T17:16:07Z\tsha-256:5c4728f439f6cbc6c7eea42992b858afc78c182962ba35d169f49db2c88e1e41", 5),
            RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"string\",\"field\":\"official-name\",\"phase\":\"beta\",\"text\":\"The official or technical name of a record.\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tsystem\tfield:citizen-names\t2017-01-10T17:16:07Z\tsha-256:494f6fa9481b2d17d72b8fa4dcf91b72751b88c262c4c8f52012cb370afcfbd1", 6),
            RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"string\",\"field\":\"citizen-names\",\"phase\":\"beta\",\"text\":\"The name of a country's citizens.\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tsystem\tfield:start-date\t2017-08-29T11:30:00Z\tsha-256:f09c439836eb6fccfb0680fa98dfc3d0300d1ceb2a43eb3c26b3eed01a42d2c2", 7),
            RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"datetime\",\"field\":\"start-date\",\"phase\":\"beta\",\"text\":\"The date a record first became relevant to a register.\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tsystem\tfield:end-date\t2017-08-29T11:31:00Z\tsha-256:c5845bfc15577e8c120970ba084f1dc2c82b10e703f80d1efe4f694295a5a71d", 8),
            RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"datetime\",\"field\":\"end-date\",\"phase\":\"beta\",\"text\":\"The date a record stopped being applicable.\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tsystem\tregister:country\t2016-08-04T14:45:41Z\tsha-256:610bde42d3ae2ed3dd829263fe461542742a10ca33865d96d31ae043b242c300", 9),
            RegistersClient::Item.new("add-item\t{\"fields\":[\"country\",\"name\",\"official-name\",\"citizen-names\",\"start-date\",\"end-date\"],\"phase\":\"beta\",\"register\":\"country\",\"registry\":\"foreign-commonwealth-office\",\"text\":\"British English-language names and descriptive terms for countries\"}")
        )
      ])
    end

    it 'should get all the metadata records' do
      client = RegistersClient::RegisterClient.new("country", "test", @config_options)

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
      client = RegistersClient::RegisterClient.new("country", "test", @config_options)

      metadata_records_with_history = client.get_metadata_records_with_history

      expect(metadata_records_with_history).to be_a(RegistersClient::RecordMapCollection)
      expect(metadata_records_with_history.count).to eq(9)
      expect(metadata_records_with_history.get_records_for_key('field:start-date')[0].item.hash).to eq("sha-256:1cff4c622577fabd35917760b04bc304af3b950e19735b60152c19f18b55e75e")
      expect(metadata_records_with_history.get_records_for_key('field:start-date')[1].item.hash).to eq("sha-256:f09c439836eb6fccfb0680fa98dfc3d0300d1ceb2a43eb3c26b3eed01a42d2c2")
    end
  end

  describe 'get_field_definitions' do
    before(:each) do
      setup

      @expected_records = RegistersClient::RecordCollection.new([
        RegistersClient::Record.new(
          RegistersClient::Entry.new("append-entry\tsystem\tfield:country\t2017-01-10T17:16:07Z\tsha-256:a303d05bdbeb029440344e0f1148f5524b4a2f9076d1b0f36a95ff7d5eeedb0e", 3),
          RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"string\",\"field\":\"country\",\"phase\":\"beta\",\"register\":\"country\",\"text\":\"The country's 2-letter ISO 3166-2 alpha2 code.\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tsystem\tfield:name\t2017-01-10T17:16:07Z\tsha-256:a7a9f2237dadcb3980f6ff8220279a3450778e9c78b6f0f12febc974d49a4a9f", 4),
            RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"string\",\"field\":\"name\",\"phase\":\"beta\",\"text\":\"The commonly-used name of a record.\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tsystem\tfield:official-name\t2017-01-10T17:16:07Z\tsha-256:5c4728f439f6cbc6c7eea42992b858afc78c182962ba35d169f49db2c88e1e41", 5),
            RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"string\",\"field\":\"official-name\",\"phase\":\"beta\",\"text\":\"The official or technical name of a record.\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tsystem\tfield:citizen-names\t2017-01-10T17:16:07Z\tsha-256:494f6fa9481b2d17d72b8fa4dcf91b72751b88c262c4c8f52012cb370afcfbd1", 6),
            RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"string\",\"field\":\"citizen-names\",\"phase\":\"beta\",\"text\":\"The name of a country's citizens.\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tsystem\tfield:start-date\t2017-08-29T11:30:00Z\tsha-256:f09c439836eb6fccfb0680fa98dfc3d0300d1ceb2a43eb3c26b3eed01a42d2c2", 7),
            RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"datetime\",\"field\":\"start-date\",\"phase\":\"beta\",\"text\":\"The date a record first became relevant to a register.\"}")
        ),
        RegistersClient::Record.new(
            RegistersClient::Entry.new("append-entry\tsystem\tfield:end-date\t2017-08-29T11:31:00Z\tsha-256:c5845bfc15577e8c120970ba084f1dc2c82b10e703f80d1efe4f694295a5a71d", 8),
            RegistersClient::Item.new("add-item\t{\"cardinality\":\"1\",\"datatype\":\"datetime\",\"field\":\"end-date\",\"phase\":\"beta\",\"text\":\"The date a record stopped being applicable.\"}")
        )
      ])
    end

    it 'should get the current field definitions' do
      client = RegistersClient::RegisterClient.new("country", "test", @config_options)

      records = client.get_field_definitions

      expect(records.count).to eq(6)
      expect(records.select{ |record| record.entry.key == 'field:end-date' }.first.entry.item_hash).to eq(@expected_records.to_a[5].entry.item_hash)
      expect(records.select{ |record| record.entry.key == 'field:end-date' }.first.item.hash).to eq(@expected_records.to_a[5].entry.item_hash)
    end

    it 'should order fields as specified in the register definition' do
      client = RegistersClient::RegisterClient.new("country", "test", @config_options)

      fields = client.get_field_definitions.map { |field| field.item.value['field'] }
      register_definition = client.get_register_definition

      expect(fields).to eq(["country","name","official-name","citizen-names","start-date","end-date"])
      expect(fields).to eq(register_definition.item.value['fields'])
    end
  end

  describe 'get_register_definition' do
    before(:each) do
      client = RegistersClient::RegisterClient.new("country", "test", @config_options)
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
      client = RegistersClient::RegisterClient.new("country", "test", @config_options)
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
      client = RegistersClient::RegisterClient.new("country", "test", @config_options)
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
      client = RegistersClient::RegisterClient.new("country", "test", @config_options)
      records = client.get_expired_records

      expect(records.count).to eq(2)
      expect(records.map { |record| record.entry.key }).to contain_exactly("YU", "CS")
    end
  end

  describe 'refresh_data' do
    before(:each) do
      setup
    end

    it 'should update the downloaded register data' do
      client = RegistersClient::RegisterClient.new("country", "test", @config_options)
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
  end

  def setup(config_options = {})
    dir = File.dirname(__FILE__)
    @rsf = File.read(File.join(dir, 'fixtures/country_register.rsf'))
    @update_rsf = File.read(File.join(dir, 'fixtures/country_register_update.rsf'))
    @config_options = { page_size: 100, cache_duration: 30 }.merge(config_options)
    allow_any_instance_of(RegistersClient::RegisterClient).to receive(:download_rsf).with(any_args).and_return(@rsf, @update_rsf)
  end
end