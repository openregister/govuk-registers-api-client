module RegistersClient
  class Entry
    def initialize(rsf_line, entry_number)
      @rsf_line = rsf_line
      @entry_number = entry_number

      @parsed_entry = nil
    end

    def entry_number
      @entry_number
    end

    def key
      get_entry[:key]
    end

    def timestamp
      get_entry[:timestamp]
    end

    def item_hash
      get_entry[:item_hash]
    end

    def value
      get_entry
    end

    private

    def get_entry
      @parsed_entry ||= parse_entry
      @parsed_entry
    end

    def parse_entry
      params = @rsf_line.split("\t")

      # Deallocate rsf line
      @rsf_line = nil

      { key: params[2], timestamp: params[3], item_hash: params[4] }
    end
  end
end