require "jekyll"
require "jekyll/page"

module Hub
  class DummyTestSite < ::Jekyll::Site
    def initialize
      @config = {}
      @data = {'public' => {}, 'private' => {}}
      @pages = []
    end
  end
end
