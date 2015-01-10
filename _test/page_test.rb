# 18F Hub - Docs & connections between team members, projects, and skill sets
#
# Written in 2014 by Mike Bland (michael.bland@gsa.gov)
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
require_relative "site"
require_relative "../_plugins/page"

require "minitest/autorun"

module Hub

  # This class overrides the Hub::Page class to isolate core Hub::Page
  # functionality for testing.
  class TestPage < Page
    attr_accessor :processed_filename, :layout_dir, :layout_filename

    def process(filename)
      @processed_filename = filename
    end

    def read_yaml(layout_dir, layout_filename)
      @layout_dir = layout_dir
      @layout_filename = layout_filename
      @data = {}
    end
  end

  class PageTest < ::Minitest::Test
    def setup
      @site = DummyTestSite.new(config: {
        'source' => 'test_source_dir',
        'generated_page_title_format' => '%s &mdash; 18F Hub',
      })
    end

    def test_generate
      assert_empty @site.pages
      page = TestPage.generate(@site, 'page_dir', 'index.html',
        'layout.html', 'Test Page Title')
      assert_equal [page], @site.pages
      assert_same page, @site.pages.first
      assert_equal 'index.html', page.processed_filename
      assert_equal File.join('test_source_dir', '_layouts'), page.layout_dir
      assert_equal 'layout.html', page.layout_filename
      assert_equal({'title' => 'Test Page Title &mdash; 18F Hub'}, page.data)
    end

    def test_get_collection_returns_empty_hash_if_collection_does_not_exist
      assert_equal({}, TestPage.get_collection(@site, 'team', '[key_ignored]'))
    end

    def test_get_collection_returns_original_hash
      team = {
        'mbland' => {'name' => 'mbland', 'full_name' => 'Mike Bland'},
      }
      @site.data['team'] = team
      assert_same team, TestPage.get_collection(@site, 'team', '[key_ignored]')
    end

    def test_get_collection_transforms_array_to_hash
      team = [{'name' => 'mbland', 'full_name' => 'Mike Bland'}]
      @site.data['team'] = team
      expected = {
        'mbland' => {'name' => 'mbland', 'full_name' => 'Mike Bland'},
      }
      assert_equal expected, TestPage.get_collection(@site, 'team', 'name')
    end

    def test_get_collection_raises_if_collection_is_not_array_or_hash
      error = assert_raises(Page::CollectionTypeError) do
        @site.data['team'] = 'not a valid collection'
        TestPage.get_collection(@site, 'team', 'name')
      end
      assert_equal("site.data[team] should be a Hash<String, Hash> or an " +
        "Array<Hash>, but is of type String", error.to_s)
    end

    def test_generate_collection_item_pages_from_nonexistent_collection
      TestPage.generate_collection_item_pages(@site, 'team', 'team_member',
        'full_name', primary_key: 'name')
      assert_empty @site.pages
    end

    def test_generate_collection_item_pages_from_array
      team = [{'name' => 'mbland', 'full_name' => 'Mike Bland'}]
      @site.data['team'] = team
      TestPage.generate_collection_item_pages(@site, 'team', 'team_member',
        'full_name', primary_key: 'name')
      assert_equal 1, @site.pages.size

      page = @site.pages.first
      assert_equal 'index.html', page.processed_filename
      assert_equal File.join('test_source_dir', '_layouts'), page.layout_dir
      assert_equal 'team_member.html', page.layout_filename

      expected_data = {
        'title' => 'Mike Bland &mdash; 18F Hub',
        'team_member' => team.first,
      }
      assert_equal expected_data, page.data
    end
  end
end
