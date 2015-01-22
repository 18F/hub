# 18F Hub - Docs & connections between team members, projects, and skill sets
#
# Written in 2015 by Mike Bland (michael.bland@gsa.gov)
# on behalf of the 18F team, part of the US General Services Administration:
# https://18f.gsa.gov/
#
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
#
# You should have received a copy of the CC0 Public Domain Dedication along
# with this software. If not, see
# <https://creativecommons.org/publicdomain/zero/1.0/>.
#
# @author Mike Bland (michael.bland@gsa.gov)

require_relative "test_helper"
require_relative "../_plugins/private_assets"
require_relative "site"

require "minitest/autorun"
require "test_temp_file_helper"

module Hub
  class PrivateAssetsCopyDirectoryToSiteTest < ::Minitest::Test
    def setup
      @temp_file_helper = ::TestTempFileHelper::TempFileHelper.new
      config = {
        'source' => @temp_file_helper.tmpdir,
        'private_data_path' => File.join('private_assets', 'private_images'),
      }
      @site = DummyTestSite.new(config: config)
      @site.static_files = []
      @source_dir = File.join('assets', 'images', 'team')
    end

    def teardown
      @temp_file_helper.teardown
    end

    def test_private_source_dir_does_not_exist
      PrivateAssets.copy_directory_to_site @site, @source_dir
      assert_empty @site.static_files
    end

    def test_private_source_dir_is_empty
      @temp_file_helper.mkdir(File.join(@site.config['private_data_path'],
        @source_dir))
      PrivateAssets.copy_directory_to_site @site, @source_dir
      assert_empty @site.static_files
    end

    def test_private_assets_copied_over
      img_files = ['mbland', 'afeld', 'gboone'].map {|i| "#{i}.jpg"}
      img_files.each do |filename|
        @temp_file_helper.mkfile(File.join(@site.config['private_data_path'],
            @source_dir, filename))
      end

      PrivateAssets.copy_directory_to_site @site, @source_dir
      expected = img_files.map {|f| File.join @source_dir, f}
      actual = @site.static_files.map {|f| File.join f.relative_path}
      assert_equal expected.sort, actual.sort
    end
  end
end

