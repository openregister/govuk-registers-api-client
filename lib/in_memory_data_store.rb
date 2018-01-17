require 'data_store'
require 'date'
require 'record_collection'
require 'record_map_collection'
require 'entry_collection'
require 'item_collection'
require 'entry'
require 'item'
require 'record'

module RegistersClient
  class InMemoryDataStore
    include DataStore

    def initialize(config_options)
      @config_options = config_options

      @data = {
        records: { user: {}, system: {} },
        entries: { user: [], system: [] },
        items: {},
        user_entry_number: 0,
        system_entry_number: 0
      }

    end

    def add_item(item)
      @data[:items][item.hash.to_s] = item
    end

    def append_entry(entry)
      entry_type = entry.entry_type == 'user' ? :user : :system

      @data[:entries][entry_type] << entry

      if !@data[:records][entry_type].key?(entry.key)
        @data[:records][entry_type][entry.key] = []
      end

      @data[:records][entry_type][entry.key] << entry.entry_number
    end

    def get_item(item_hash)
      @data[:items].has_key?(item_hash) ? @data[:items][item_hash] : nil
    end

    def get_items
      ItemCollection.new(@data[:items].values)
    end

    def get_entry(entry_type, entry_number)
      if (entry_number < 1 || entry_number > @data[:entries][entry_type].count)
        nil
      else
        @data[:entries][entry_type][entry_number - 1]
      end
    end

    def get_record(entry_type, key)
      if (@data[:records][entry_type].has_key?(key))
        record_entry_numbers = @data[:records][entry_type][key]
        entry = get_data[:entries][entry_type][record_entry_numbers.last - 1]

        Record.new(entry, get_data[:items][entry.item_hash])
      end
    end

    def get_entries(entry_type)
      EntryCollection.new(get_data[:entries][entry_type], @config_options.fetch(:page_size))
    end

    def get_records(entry_type)
      RecordCollection.new(get_data[:records][entry_type].map do |_k, record_entry_numbers|
        entry = get_data[:entries][entry_type][record_entry_numbers.last - 1]
        item = get_data[:items][entry.item_hash]

        Record.new(entry, item)
      end, @config_options.fetch(:page_size))
    end

    def get_latest_entry_number(entry_type)
      entry = @data[:entries][entry_type].last
      entry.nil? ? 0 : entry.entry_number
    end

    def after_load
    end

    private

    def get_data
      @data
    end
  end
end