require_relative 'test_helper'
require_relative 'site_builder'

require 'json'
require 'minitest/autorun'

module Hub
  class SearchTest < ::Minitest::Test
    def test_index_built
      index_file = File.join(SiteBuilder::BUILD_DIR, 'index.json')
      assert(File.exist?(index_file), "Serialized lunr.js index doesn't exist")

      File.open(index_file, 'r') do |f|
        index = JSON.parse f.read, :max_nesting => 200
        refute_empty index
        refute_nil index['corpusTokens']
        refute_nil index['documentStore']
        refute_nil index['fields']
        refute_nil index['pipeline']
        refute_nil index['ref']
        refute_nil index['tokenStore']
        refute_nil index['version']
      end
    end

    def test_url_to_doc_map_built
      url_to_doc_file = File.join(SiteBuilder::BUILD_DIR, 'url_to_doc.json')
      assert(File.exist?(url_to_doc_file),
        "Serialized URL-to-doc info index doesn't exist")
      File.open(url_to_doc_file, 'r') do |f|
        url_to_doc = JSON.parse f.read
        refute_empty url_to_doc
        url_to_doc.each do |k,v|
          refute_nil v['url']
          refute_nil v['title']
          assert_equal k, v['url']
        end
      end
    end
  end
end
