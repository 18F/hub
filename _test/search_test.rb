require_relative 'test_helper'
require_relative 'site_builder'

require 'minitest/autorun'

module Hub
  class SearchTest < ::Minitest::Test
    def test_index_built
      assert(File.exist?(File.join(SiteBuilder::BUILD_DIR, 'index.json')),
        "Serialized lunr.js index doesn't exist")
    end

    def test_url_to_doc_map_built
      assert(File.exist?(File.join(SiteBuilder::BUILD_DIR, 'url_to_doc.json')),
        "Serialized URL-to-doc info index doesn't exist")
    end
  end
end
