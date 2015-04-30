require_relative 'test_helper'
require_relative 'site_builder'

require 'minitest/autorun'

module Hub
  class SearchTest < ::Minitest::Test
    def test_index_built
      assert(File.exist?(File.join(SiteBuilder::BUILD_DIR, 'index.json')),
        "Serialized lunr.js index doesn't exist")
    end
  end
end
