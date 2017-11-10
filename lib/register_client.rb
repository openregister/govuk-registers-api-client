require 'rest-client'
require 'json'
require 'date'
require 'mini_cache'
require 'paginated'

module RegistersClient
  class RegisterClient
    extend Paginated

    def initialize(register, phase, config_options)
      @store = MiniCache::Store.new
      @register = register
      @phase = phase
      @config_options = config_options

      get_data
    end

    def get_entries
      get_data[:entries][:user]
    end
    filter_and_paginate :get_entries

    def get_records
      get_data[:records][:user].map { |_k, v| v.last }
    end
    filter_and_paginate :get_records

    def get_records_with_history
      get_data[:records][:user]
    end
    filter_and_paginate :get_records_with_history

    def get_current_records
      get_records_no_pagination.select { |record| record[:item]['end-date'].nil? }
    end
    filter_and_paginate :get_current_records

    def get_expired_records
      get_records_no_pagination.select { |record| record[:item]['end-date'].present? }
    end
    filter_and_paginate :get_expired_records

    def get_metadata_records
      get_data[:records][:system].map { |_k, v| v.last }
    end
    filter_and_paginate :get_metadata_records

    def get_field_definitions
      get_metadata_records_no_pagination.select { |record| record[:key].start_with?('field:') }
    end
    filter_and_paginate :get_field_definitions

    def get_register_definition
      get_metadata_records_no_pagination.select { |record| record[:key].start_with?('register:') }.first
    end

    def get_custodian
      get_metadata_records_no_pagination.select { |record| record[:key] == 'custodian'}.first
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
      items = []
      entries = { user: [], system: [] }
      records = { user: {}, system: {} }

      rsf.each_line do |line|
        line.slice!("\n")
        params = line.split("\t")

        command = params[0]

        if command == 'add-item'
          items << parse_item(params[1])
        elsif command == 'append-entry'
          key = params[2]
          entry_number = entries[:user].count + 1
          entry_timestamp = params[3]
          current_item_hash = params[4]
          record = parse_entry(key, entry_number, entry_timestamp, current_item_hash, JSON.parse(items.find { |item| item[:hash] == current_item_hash }[:item]))

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