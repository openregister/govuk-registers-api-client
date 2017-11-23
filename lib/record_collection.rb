module RegistersClient
  class RecordCollection
    include Enumerable

    def initialize(data, page_size = 100)
      @data = data
      @page_size = page_size
    end

    def each
      @data.each do |record|
        yield record
      end
    end

    def page(page = 1)
      if @data.length <= @page_size
        @data
      else
        start_index = (page - 1) * @page_size
        @data.slice(start_index, @page_size)
      end
    end
  end
end