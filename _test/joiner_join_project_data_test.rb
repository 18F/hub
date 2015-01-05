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
require_relative "site"

require "minitest/autorun"

module Hub
  class JoinProjectDataTest < ::Minitest::Test
    def setup
      @site = DummyTestSite.new
      @site.data['private']['team'] = {}
      @site.data['private']['projects'] = [
        {'name' => 'MSB-USA', 'status' => 'Hold'}
      ]
    end

    def test_join_project
      @impl = JoinerImpl.new(@site)
      @impl.join_project_data
      assert_equal([{'name' => 'MSB-USA', 'status' => 'Hold'}],
        @site.data['projects'])
    end

    def test_hide_hold_projects_in_public_mode
      @site.config['public'] = true
      @impl = JoinerImpl.new(@site)
      @impl.join_project_data
      assert_empty @site.data['projects']
    end
  end
end
