require 'json'

module RegistersClient
  class Item
    def initialize(rsf_line)
      @item_json = rsf_line.split("\t")[1]
      @item_hash = 'sha-256:' + Digest::SHA256.hexdigest(@item_json)

      @parsed_item = nil
    end

    def hash
      @item_hash
    end

    def value
      get_item
    end

    def has_end_date
      if !@item_json.nil?
        !@item_json.index("end-date").nil?
      else
        !@parsed_item['end-date'].nil?
      end
    end

    private

    def get_item
      if @parsed_item.nil?
        @parsed_item = parse_item
      end

      @parsed_item
    end

    def parse_item
      parsed_item = JSON.parse(@item_json)

      # Deallocate item JSON
      @item_json = nil

      parsed_item
    end
  end
end