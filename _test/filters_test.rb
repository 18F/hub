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

  class PhotoOrPlaceholderFilterTest < ::Minitest::Test
    include Filters

    @@sample_team_member_name = 'sample.teammember'
    @@image_directory_name = File.join("_test", "tmp")
    @@imagefile_path = File.join(@@image_directory_name, "#{@@sample_team_member_name}.jpg")
    @@site = {'team_img_dir' => @@image_directory_name,
      'missing_team_member_img' => 'no_image.jpg'}

    def setup
      img_file = File.new(@@imagefile_path, 'wb')
      img_file.close
    end

    def teardown
      File.delete(@@imagefile_path)
    end

    def test_when_photo_present
      result = photo_or_placeholder(@@sample_team_member_name, @@site)
      assert_equal(result, File.join("", @@imagefile_path))
    end

    def test_when_photo_absent
      result = photo_or_placeholder("nonexistent", @@site)
      assert_equal(result, File.join("", @@image_directory_name, "no_image.jpg"))
    end

  end
end
