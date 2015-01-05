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

require_relative "../_plugins/joiner"
require_relative "page"
require_relative "site"

require "minitest/autorun"

module Hub
  class FilterPrivatePagesTest < ::Minitest::Test
    def setup
      @site = DummyTestSite.new
      @all_page_names = []
      @public_page_names = []
    end

    def add_public_page(filename)
      @site.pages << DummyTestPage.new(@site, '/pages', filename)
      @all_page_names << filename
      @public_page_names << filename
    end

    def add_private_page(filename)
      @site.pages << DummyTestPage.new(@site, '/pages/private', filename)
      @all_page_names << filename
    end

    def filter_pages_in_internal_mode
      @site.config.delete 'public'
      JoinerImpl.new(@site).filter_private_pages
    end

    def filter_pages_in_public_mode
      @site.config['public'] = true
      JoinerImpl.new(@site).filter_private_pages
    end

    def page_names
      @site.pages.map {|p| p.name}
    end

    def test_no_pages
      filter_pages_in_internal_mode
      assert_empty page_names
      filter_pages_in_public_mode
      assert_empty page_names
    end

    def test_single_public_page
      add_public_page 'public.html'
      filter_pages_in_internal_mode
      assert_equal(@all_page_names, page_names)
      filter_pages_in_public_mode
      assert_equal(@public_page_names, page_names)
    end

    def test_single_private_page
      add_private_page 'private.html'
      filter_pages_in_internal_mode
      assert_equal(@all_page_names, page_names)
      filter_pages_in_public_mode
      assert_empty page_names
    end

    def test_public_and_private_pages
      add_private_page 'private-0.html'
      add_public_page 'public-0.html'
      add_private_page 'private-1.html'
      add_public_page 'public-1.html'
      add_private_page 'private-2.html'
      filter_pages_in_internal_mode
      assert_equal(@all_page_names, page_names)
      filter_pages_in_public_mode
      assert_equal(@public_page_names, page_names)
    end
  end
end
