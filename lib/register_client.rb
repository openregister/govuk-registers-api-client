require 'rest-client'
require 'json'
require 'date'
require 'mini_cache'
require 'record_collection'
require 'record_map_collection'
require 'entry_collection'
require 'entry'
require 'item'
require 'record'

module RegistersClient
  class RegisterClient
    def initialize(register, phase, config_options)
      @store = MiniCache::Store.new
      @register = register
      @phase = phase
      @config_options = config_options

      get_data
    end

    def get_entries
      EntryCollection.new(get_data[:entries][:user], @config_options.fetch(:page_size))
    end

    def get_records
      RecordCollection.new(get_data[:records][:user].map do |_k, record_entry_numbers|
        entry = get_data[:entries][:user][record_entry_numbers.last - 1]
        item = get_data[:items][entry.item_hash]

        Record.new(entry, item)
      end, @config_options.fetch(:page_size))
    end

    def get_metadata_records
      RecordCollection.new(get_data[:records][:system].map do |_k, record_entry_numbers|
        entry = get_data[:entries][:system][record_entry_numbers.last - 1]
        item = get_data[:items][entry.item_hash]

        Record.new(entry, item)
      end, @config_options.fetch(:page_size))
    end

    def get_field_definitions
      ordered_fields = get_register_definition.item.value['fields']
      ordered_records = ordered_fields.map { |f| get_metadata_records.find { |record| record.entry.key == "field:#{f}" } }
      @field_definitions ||= RecordCollection.new(ordered_records, @config_options.fetch(:page_size))
      @field_definitions
    end

    def get_register_definition
      get_metadata_records.select { |record| record.entry.key.start_with?('register:') }.first
    end

    def get_custodian
      get_metadata_records.select { |record| record.entry.key == 'custodian'}.first
    end

    def get_records_with_history
      records_with_history = {}

      get_data[:records][:user].map do |_k, record_entry_numbers|
        records_with_history[_k] = []

        record_entry_numbers.each do |entry_number|
          entry = get_data[:entries][:user][entry_number - 1]
          item = get_data[:items][entry.item_hash]
          records_with_history[_k] << Record.new(entry, item)
        end
      end

      RecordMapCollection.new(records_with_history, @config_options.fetch(:page_size))
    end

    def get_metadata_records_with_history
      metadata_records_with_history = {}

      get_data[:records][:system].map do |_k, record_entry_numbers|
        metadata_records_with_history[_k] = []

        record_entry_numbers.each do |entry_number|
          entry = get_data[:entries][:system][entry_number - 1]
          item = get_data[:items][entry.item_hash]
          metadata_records_with_history[_k] << Record.new(entry, item)
        end
      end

      RecordMapCollection.new(metadata_records_with_history, @config_options.fetch(:page_size))
    end

    def get_current_records
      RecordCollection.new(get_records.select { |record| !record.item.has_end_date }, @config_options.fetch(:page_size))
    end

    def get_expired_records
      RecordCollection.new(get_records.select { |record| record.item.has_end_date }, @config_options.fetch(:page_size))
    end

    def refresh_data
      @store.set('data') do
        rsf = download_rsf(@register, @phase)
        data = parse_rsf(rsf)
        MiniCache::Data.new(data, expires_in: @config_options[:cache_duration])
      end
    end

    private

    def get_data
      @store.get_or_set('data') do
        rsf = download_rsf(@register, @phase)
        data = parse_rsf(rsf)
        MiniCache::Data.new(data, expires_in: @config_options[:cache_duration])
      end
    end

    def download_rsf(register, phase)
      RestClient.get("https://#{register}.#{phase}.openregister.org/download-rsf")
    end

    def parse_rsf(rsf)
      items = {}
      entries = { user: [], system: [] }
      records = { user: {}, system: {} }
      user_entry_number = 1
      system_entry_number = 1

      rsf.each_line do |line|
        line.slice!("\n")
        params = line.split("\t")
        command = params[0]

        if command == 'add-item'
          item = RegistersClient::Item.new(line)
          items[item.hash.to_s] = item
        elsif command == 'append-entry'
          if params[1] == 'user'
            entry = Entry.new(line, user_entry_number)
            entries[:user] << entry

            if !records[:user].key?(entry.key)
              records[:user][entry.key] = []
            end

            records[:user][entry.key] << user_entry_number

            user_entry_number += 1
          else
            entry = Entry.new(line, system_entry_number)
            entries[:system] << entry

            if !records[:system].key?(entry.key)
              records[:system][entry.key] = []
            end

            records[:system][entry.key] << system_entry_number

            system_entry_number += 1
          end
        end
      end

      { records: records, entries: entries, items: items }
    end
  end
end