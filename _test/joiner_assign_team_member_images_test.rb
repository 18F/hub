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
require_relative "../_plugins/joiner"
require_relative "site"

require "minitest/autorun"
require "test_temp_file_helper"

module Hub
  class AssignTeamMemberImagesTest < ::Minitest::Test
    def setup
      @temp_file_helper = ::TestTempFileHelper::TempFileHelper.new
      @team_img_dir = File.join 'assets', 'images' ,'team'
      @private_data_path = File.join '_data', 'private'
      @missing_team_member_img = 'logo-18f.jpg'

      @site = DummyTestSite.new(config:{
        'source' => @temp_file_helper.tmpdir,
        'team_img_dir' => @team_img_dir,
        'private_data_path' => @private_data_path,
        'missing_team_member_img' => @missing_team_member_img,
      })

      @member = {'name' => 'mbland'}
      @member_image = "#{@member['name']}.jpg"
      @site.data['team'] = {@member['name'] => @member}

      @joiner = JoinerImpl.new @site
    end

    def test_member_without_image_file_gets_missing_team_member_img
      @joiner.assign_team_member_images
      assert_equal(File.join(@team_img_dir, @missing_team_member_img),
        @member['image'])
    end

    def test_member_with_image_file
      @temp_file_helper.mkfile(File.join @team_img_dir, @member_image)
      @joiner.assign_team_member_images
      assert_equal File.join(@team_img_dir, @member_image), @member['image']
    end

    def test_member_with_private_image_file
      @temp_file_helper.mkfile(
        File.join @private_data_path, @team_img_dir, @member_image)
      @joiner.assign_team_member_images
      assert_equal File.join(@team_img_dir, @member_image), @member['image']
    end
  end
end

