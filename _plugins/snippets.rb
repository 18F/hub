module Hub
  class Snippets
    def self.generate_pages(site)
      return unless site.data.member? 'snippets'
      site.data['snippets'].each do |timestamp, snippets|
        generate_snippets_page(site, timestamp, snippets)
      end
    end

    def self.generate_snippets_page(site, timestamp, snippets)
      page = Page.new(site, 'snippets', "#{timestamp}.html",
        "snippets.html",
        "Snippets for #{Canonicalizer.hyphenate_yyyymmdd(timestamp)}")
      page.data['snippets'] = snippets
      site.pages << page
    end
  end
end
