require_relative 'test_helper'
require_relative 'site_builder'

require 'json'
require 'minitest/autorun'

module Hub
  class SearchTest < ::Minitest::Test
    def test_index_built
      index_file = File.join(SiteBuilder::BUILD_DIR, 'search-index.json')
      assert(File.exist?(index_file), "Serialized search index doesn't exist")

      File.open(index_file, 'r') do |f|
        search_index = JSON.parse f.read, :max_nesting => 200
        refute_empty search_index

        index = search_index['index']
        refute_empty index
        refute_nil index['corpusTokens']
        refute_nil index['documentStore']
        refute_nil index['fields']
        refute_nil index['pipeline']
        refute_nil index['ref']
        refute_nil index['tokenStore']
        refute_nil index['version']

        url_to_doc = search_index['url_to_doc']
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
