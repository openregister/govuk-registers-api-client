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

      @data = {
        records: { user: {}, system: {} },
        entries: { user: [], system: [] },
        items: {},
        user_entry_number: 0,
        system_entry_number: 0
      }

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
        update_cache(@register, @phase)
      end
    end

    private

    def get_data
      @store.get_or_set('data') do
        update_cache(@register, @phase)
      end
    end

    def update_cache(register, phase)
      rsf = download_rsf(register, phase, @data[:user_entry_number])
      update_data_from_rsf(rsf, @data)
      @data
    end

    def download_rsf(register, phase, start_entry_number)
      RestClient.get("https://#{register}.#{phase}.openregister.org/download-rsf/#{start_entry_number}")
    end

    def update_data_from_rsf(rsf, data)
      rsf.each_line do |line|
        line.slice!("\n")
        params = line.split("\t")
        command = params[0]

        if command == 'add-item'
          item = RegistersClient::Item.new(line)
          data[:items][item.hash.to_s] = item
        elsif command == 'append-entry'
          if params[1] == 'user'
            data[:user_entry_number] += 1

            entry = Entry.new(line, data[:user_entry_number])
            data[:entries][:user] << entry

            if !data[:records][:user].key?(entry.key)
              data[:records][:user][entry.key] = []
            end

            data[:records][:user][entry.key] << data[:user_entry_number]
          else
            data[:system_entry_number] += 1

            entry = Entry.new(line, data[:system_entry_number])
            data[:entries][:system] << entry

            if !data[:records][:system].key?(entry.key)
              data[:records][:system][entry.key] = []
            end

            data[:records][:system][entry.key] << data[:system_entry_number]
          end
        end
      end
    end
  end
end