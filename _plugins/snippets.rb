module Hub
  class Snippets
    def self.generate_pages(site)
      return unless site.data.member? 'snippets'
      site.data['snippets'].each do |timestamp, snippets|
        generate_snippets_page(site, timestamp, snippets)
      end
      generate_snippets_index_page(site)
    end

    def self.generate_snippets_page(site, timestamp, snippets)
      page = Page.new(site, 'snippets', "#{timestamp}.html",
        "snippets.html",
        "Snippets for #{Canonicalizer.hyphenate_yyyymmdd(timestamp)}")
      page.data['snippets'] = snippets
      site.pages << page
    end

    def self.generate_snippets_index_page(site)
      page = Page.new(site, 'snippets', 'index.html', 'snippets_index.html',
        'Snippets')

      snippets = []
      site.data['snippets'].each do |t,s|
        snippets << {'timestamp'=>t, 'snippets'=>s}
      end

      page.data['snippets'] = snippets
      page.data['members'] = site.data['snippets_team_members']
      site.pages << page
    end
  end
end
