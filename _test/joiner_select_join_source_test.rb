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
require_relative "../_plugins/joiner"
require_relative "site"

require "minitest/autorun"

module Hub
  class SelectJoinSourceTest < ::Minitest::Test
    def setup
      @site = DummyTestSite.new
    end

    def test_select_private_source
      @site.data['private']['sample_source_content'] = 'has private data'
      impl = JoinerImpl.new @site
      assert_equal 'private', impl.source
    end

    def test_select_public_source
      @site.data.delete 'private'
      impl = JoinerImpl.new @site
      assert_equal 'public', impl.source
    end
  end
end
