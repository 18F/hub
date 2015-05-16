require 'jekyll_pages_api'
require 'v8'

module Hub
  class SearchIndexBuilder
    def self.build_index(site)
      corpus_page = find_corpus_page(site.pages)
      raise 'Pages API corpus not found' if corpus_page == nil

      search_config = site.config['jekyll_pages_api_search']
      cxt = V8::Context.new
      cxt.load File.join(site.source, search_config['lunr_js_source'])
      cxt[:index_fields] = search_config['index_fields'] || {}
      cxt.eval("var corpus = #{corpus_page.content};")
      cxt.load(File.join(site.source, '_plugins', 'search.js'))

      index_page = JekyllPagesApi::PageWithoutAFile.new(
        site, site.source, '', 'search-index.json')
      index_page.content = cxt[:result]
      index_page.data['layout'] = nil
      index_page.render(Hash.new, site.site_payload)
      return index_page
    end

    def self.find_corpus_page(pages)
      pages.each {|page| return page if page.name == 'pages.json'}
    end
  end
end
