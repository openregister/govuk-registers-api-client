module Paginated
  def filter_and_paginate(sym)
    original_method = :"#{sym}_no_pagination"
    alias_method original_method, sym
    define_method sym do |page, text, *args|
      results = send(original_method, *args)
      filtered = self.class.filter(results, text)
      self.class.paginate(filtered, page, @config_options)
    end
  end

  def filter(results, text)
    if text.empty?
      results
    elsif
      text = text.downcase
      results.select { |record| record[:item].values.to_s.downcase.include?(text) }
    end
  end

  def paginate(results, page, config_options)
    if results.length <= config_options[:page_size]
      {
        data: results,
        page: 1,
        total_results: results.length,
        total_pages: 1,
        more_results: false
      }
    elsif
      start_index = (page - 1) * config_options[:page_size]
      total_results = results.length
      total_pages = (results.length / config_options[:page_size].to_f).ceil

      {
        data: results.slice(start_index, config_options[:page_size]),
        page: page,
        total_results: total_results,
        total_pages: total_pages,
        more_results: page < total_pages
      }
    end
  end
end