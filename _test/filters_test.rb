require_relative "test_helper"
require_relative "../_plugins/filters"

require "minitest/autorun"

module Hub
  class TestFilters
    include Filters
  end

  class FiltersTest < ::Minitest::Test
    def test_trim_suffix
      assert_equal 'foo', TestFilters.new().trim_suffix('foo.js', '.js')
      assert_equal 'foo.js', TestFilters.new().trim_suffix('foo.js', '.css')
    end
  end
end
