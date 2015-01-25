require 'liquid'
require_relative 'filters'

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

  def dest_dir
    File.join(self.site.dest, 'api')
  end

  def dest_file
    File.join(self.dest_dir, 'pages.json')
  end

  def generate
    FileUtils.mkdir_p(self.dest_dir)
    File.open(self.dest_file, 'w') do |file|
      file << self.data.to_json
    end
    # so that it doesn't get swept up by the Jekyll::Site::Cleaner
    self.site.keep_files << File.join('api', 'pages.json')
  end
end
