require 'rest-client'
require 'json'
require 'date'
require 'mini_cache'
require 'record_collection'
require 'record_map_collection'
require 'entry_collection'

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
      @entries ||= EntryCollection.new(get_data[:entries][:user], @config_options.fetch(:page_size))
      @entries
    end

    def get_records
      @records ||= RecordCollection.new(get_data[:records][:user].map { |_k, v| v.last }, @config_options.fetch(:page_size))
      @records
    end

    def get_metadata_records
      @metadata_records ||= RecordCollection.new(get_data[:records][:system].map { |_k, v| v.last }, @config_options.fetch(:page_size))
      @metadata_records
    end

    def get_field_definitions
      @field_definitions ||= RecordCollection.new(get_metadata_records.select { |record| record[:key].start_with?('field:') }, @config_options.fetch(:page_size))
      @field_definitions
    end

    def get_register_definition
      get_metadata_records.select { |record| record[:key].start_with?('register:') }.first
    end

    def get_custodian
      get_metadata_records.select { |record| record[:key] == 'custodian'}.first
    end

    def get_records_with_history
      @records_with_history ||= RecordMapCollection.new(get_data[:records][:user], @config_options.fetch(:page_size))
      @records_with_history
    end

    def get_current_records
      @current_records ||= RecordCollection.new(get_records.select { |record| record[:item]['end-date'].nil? }, @config_options.fetch(:page_size))
      @current_records
    end

    def get_expired_records
      @expired_records ||= RecordCollection.new(get_records.reject { |record| record[:item]['end-date'].nil? }, @config_options.fetch(:page_size))
      @expired_records
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
      entry_number = 1

      rsf.each_line do |line|
        line.slice!("\n")
        params = line.split("\t")

        command = params[0]

        if command == 'add-item'
          item = parse_item(params[1])
          items[item[:hash].to_s] = item
        elsif command == 'append-entry'
          key = params[2]
          entry_timestamp = params[3]
          current_item_hash = params[4]
          record = parse_entry(key, entry_number, entry_timestamp, current_item_hash, JSON.parse(items[current_item_hash][:item]))

          if params[1] == 'user'
            if !records[:user].key?(key)
              records[:user][key] = []
            end

            records[:user][key] << record
            entries[:user] << record
          else
            if !records[:system].key?(key)
              records[:system][key] = []
            end

            records[:system][key] << record
            entries[:system] << record
          end
        end

        entry_number += 1
      end

      { records: records, entries: entries, items: items }
    end

    def parse_item(item_json)
      payload_sha = Digest::SHA256.hexdigest item_json
      { hash: 'sha-256:' + payload_sha, item: item_json }
    end

    def parse_entry(key, entry_number, entry_timestamp, hash, current_item)
      { key: key, entry_number: entry_number, timestamp: entry_timestamp, hash: hash, item: current_item }
    end
  end
end