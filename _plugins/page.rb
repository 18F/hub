module Hub
  # Hub-specfic Page object that standardizes how pages are generated.
  #
  # This Page object allows us to create target pages on the fly using
  # ::Jekyll::Generator plugins. Just creating factory functions that invoke
  # ::Jekyll::Page.new cause initialization failures, as
  # ::Jekyll::Page::initialize will try to open the page specified by
  # File.join(base, dir, filename) directly. 
  class Page < ::Jekyll::Page
    def initialize(site, dir, filename, layout, title)
      @site = site
      @base = site.source
      @dir = dir
      @name = filename

      self.process(filename)
      self.read_yaml(File.join(site.source, '_layouts'), layout)
      self.data['title'] = "#{title} - 18F Hub"
    end
  end
end
