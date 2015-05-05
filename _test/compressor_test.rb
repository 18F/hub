require_relative "test_helper"
require_relative "../_plugins/compressor"
require_relative "page"
require_relative "site"

require "minitest/autorun"

module Hub
  class CompressorTest < ::Minitest::Test
    def test_compress_main_js
      site = DummyTestSite.new
      page = DummyTestPage.new site, '', 'main.js'
      site.pages << page
      page.content = "function my_func() { var foo = 0; return foo; }"
      Compressor.compress site
      assert_equal "function my_func(){var n=0;return n}", page.content
    end
  end
end
