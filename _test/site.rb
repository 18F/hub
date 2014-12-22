require "jekyll"
require "jekyll/site"

module Hub
  class DummyTestSite < ::Jekyll::Site
    def initialize
      @config = {}
      @data = {'public' => {}, 'private' => {}}
      @pages = []
    end
  end
end
