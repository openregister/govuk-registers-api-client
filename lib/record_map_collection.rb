module RegistersClient
  class RecordMapCollection
    include Enumerable

    def initialize(data, page_size = 100)
      @data = data
      @page_size = page_size
    end

    def each
      @data.each do |key,val|
        result = {key: key, records: val}
        yield result
      end
    end

    def get_records_for_key(key)
      @data.fetch(key)
    end

    def paginator
      @data.each_slice(@page_size)
    end
  end
end