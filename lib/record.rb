module RegistersClient
  class Record
    def initialize(entry, item)
      @entry = entry
      @item = item
    end

    def entry
      @entry
    end

    def item
      @item
    end
  end
end