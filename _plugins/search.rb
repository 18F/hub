require 'v8'

module Hub
  class SearchIndexBuilder
    def self.build_index(site)
      corpus_page = find_corpus_page(site.pages)
      return nil if corpus_page == nil

      cxt = V8::Context.new
      cxt.load(File.join(site.source,
        'assets', 'js', 'vendor', 'lunr.js', 'lunr.js'))
      cxt.load(File.join(site.source, '_plugins', 'search.js'))
      cxt.eval("var corpus = #{corpus_page.content};")
      cxt.eval("var url_to_doc = {};")
      cxt.eval(
        'corpus.entries.forEach(function(page) {' +
        '  index.add(page);' +
        '  url_to_doc[page.url] = {url: page.url, title: page.title};' +
        '});')

      index_page = JekyllPagesApi::PageWithoutAFile.new(
        site, site.source, '', 'index.json')
      index_page.content = cxt.eval("JSON.stringify(index.toJSON());")

      url_to_doc_page = JekyllPagesApi::PageWithoutAFile.new(
        site, site.source, '', 'url_to_doc.json')
      url_to_doc_page.content = cxt.eval("JSON.stringify(url_to_doc);")

      pages = [index_page, url_to_doc_page]
      pages.each do |page|
        page.data['layout'] = nil
        page.render(Hash.new, site.site_payload)
      end
      return pages
    end

    def self.find_corpus_page(pages)
      pages.each {|page| return page if page.name == 'pages.json'}
    end
  end
end
