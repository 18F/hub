require_relative "../_plugins/joiner"
require_relative "site"

require "minitest/autorun"

module Hub
  class SelectJoinSourceTest < ::Minitest::Test
    def setup
      @site = DummyTestSite.new
    end

    def test_select_private_source
      @site.data['private'] = 'has private data'
      impl = JoinerImpl.new @site
      assert_equal 'private', impl.source
    end

    def test_select_public_source
      @site.data.delete 'private'
      impl = JoinerImpl.new @site
      assert_equal 'public', impl.source
    end
  end
end
