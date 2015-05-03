require_relative 'test_helper'
require_relative 'site_builder'

require 'minitest/autorun'

module Hub
  class CompressorTest < ::Minitest::Test
    def test_compressed_javascript
      path = File.join('assets', 'js', 'vendor', 'angular', 'angular.js')
      orig_path = File.join(File.dirname(__FILE__), '..', path)
      compressed_path = File.join(SiteBuilder::BUILD_DIR, path)
      assert(File.exist?(orig_path),
        "Original path doesn't exist: #{orig_path}")
      assert(File.exist?(compressed_path),
        "Compressed path doesn't exist: #{compressed_path}")

      orig_size = File.stat(orig_path).size
      compressed_size = File.stat(compressed_path).size

      assert(compressed_size < orig_size,
        "The compressed size of #{compressed_path} (#{compressed_size}) " +
        "is not smaller than the original size of #{orig_path} (#{orig_size})")
    end
  end
end
