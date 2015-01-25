require 'liquid'
require_relative 'filters'
require_relative 'jekyll/page_without_a_file'

class PagesApi
  # This is a hack to allow the module functions to be used
  class Filterer
    include Liquid::StandardFilters
    include Hub::Filters
  end

  attr_reader :filterer, :site

  def initialize(site)
    @filterer = Filterer.new
    @site = site
  end

  def pages
    self.site.pages.select {|page| %w(.html .md).include?(page.ext) }
  end

  def get_output(page)
    filterer.condense(filterer.strip_html(page.content))
  end

  def pages_data
    self.pages.map do |page|
      {
        title: page.data['title'],
        url: page.url,
        body: self.get_output(page)
      }
    end
  end

  def data
    {
      entries: pages_data
    }
  end

  def page
    # based on https://github.com/jekyll/jekyll-sitemap/blob/v0.7.0/lib/jekyll-sitemap.rb#L51-L54
    page = Jekyll::PageWithoutAFile.new(self.site, File.dirname(__FILE__), 'api', 'pages.json')
    page.content = self.data.to_json
    page.data['layout'] = nil
    page.render(Hash.new, self.site.site_payload)

    page
  end

  def generate
    self.site.pages << self.page
  end
end
