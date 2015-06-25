# @author Mike Bland (michael.bland@gsa.gov)

require_relative "test_helper"
require_relative 'site_builder'

require 'minitest/autorun'

module Hub
  class StaticFilesInCollectionsTest < ::Minitest::Test
    def test_follow_permalink_format_from_collection_config
      basedir = SiteBuilder::BUILD_DIR
      pages_dir = File.join basedir, 'pages'
      refute Dir.exist?(pages_dir), "#{pages_dir} should not exist"

      return if TestHelper::running_on_public_ci
      pages_img = File.join basedir, 'private', 'qa', 'hub.png'
      assert File.exist?(pages_img), "#{pages_img} not found"
    end

    def test_private_files_hidden_by_public_config_defaults
      basedir = SiteBuilder::PUBLIC_BUILD_DIR
      pages_dir = File.join basedir, 'pages'
      refute Dir.exist?(pages_dir), "#{pages_dir} should not exist"

      return if TestHelper::running_on_public_ci
      private_dir = File.join basedir, 'private'
      refute Dir.exist?(private_dir), "#{private_dir} should not exist"
    end
  end
end
