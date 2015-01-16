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
require_relative "temp_file_helper"

require "minitest/autorun"

module Hub
  class PrivateAssetsCopyTeamImagesTest < ::Minitest::Test
    def setup
      config = {
        'source' => ENV['TEST_TMPDIR'],
        'private_data_path' => File.join('private_assets', 'private_images'),
        'team_img_dir' => File.join('assets', 'images', 'team')
      }
      @site = DummyTestSite.new(config: config)
      @site.static_files = []
      @testdir = File.join config['source'], config['private_data_path']

      @temp_file_helper = TempFileHelper.new
      @target_dir = @temp_file_helper.mkdir(
        File.join('private_assets', @site.config['team_img_dir']))
    end

    def teardown
      @temp_file_helper.teardown
    end

    def test_private_image_data_path_does_not_exist
      @temp_file_helper.mkdir @site.config['private_data_path']
      PrivateAssets.copy_team_images(@site)
      assert_empty @site.static_files
    end

    def test_private_image_data_path_is_empty
      @temp_file_helper.mkdir(File.join(@site.config['private_data_path'],
        @site.config['team_img_dir']))
      PrivateAssets.copy_team_images(@site)
      assert_empty @site.static_files
    end

    def test_private_data_images_copied_over
      img_files = ['mbland', 'afeld', 'gboone'].map {|i| "#{i}.jpg"}
      img_files.each do |filename|
        @temp_file_helper.mkfile(File.join(@site.config['private_data_path'],
            @site.config['team_img_dir'], filename))
      end

      PrivateAssets.copy_team_images(@site)
      expected = img_files.map {|f| File.join @site.config['team_img_dir'], f}
      actual = @site.static_files.map {|f| File.join f.relative_path}
      assert_equal expected.sort, actual.sort
    end
  end
end

