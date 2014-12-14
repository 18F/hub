require "jekyll"
require "jekyll/page"

module Hub
  class DummyTestPage < ::Jekyll::Page
    def initialize(site, dir, filename)
      @site = site
      @base = 'fake_test_basedir'
      @dir = dir
      @name = filename
    end
  end
end
