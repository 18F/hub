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
require_relative "../_plugins/cross_referencer"
require_relative "site"

require "minitest/autorun"

module Hub
  class CrossReferencerLocationsTest < ::Minitest::Test
    def setup
      config = {
      }
      @site = DummyTestSite.new(config: config)
      @site.data.delete 'private'
      @site.data.delete 'public'
    end

    def create_xref_using_team_data(team)
      @site.data['team'] = team
      CrossReferencerImpl.new @site.data
    end

    def test_no_locations_member_created_if_team_is_empty
      xref = create_xref_using_team_data []
      xref.xref_locations_and_team_members
      assert_nil @site.data['locations']
    end

    def test_xref_locations_and_team_members
      team = [
        {'name' => 'mbland', 'location' => 'DCA'},
        {'name' => 'afeld', 'location' => 'NYC'},
        {'name' => 'mhz', 'location' => 'TUS'},
        {'name' => 'gboone', 'location' => 'DCA'},
        {'name' => 'ekamlley', 'location' => 'DCA'},
      ]

      xref = create_xref_using_team_data team
      xref.xref_locations_and_team_members

      expected = [
        ['DCA', [team[0], team[3], team[4]]],
        ['NYC', [team[1]]],
        ['TUS', [team[2]]],
      ]
      assert_equal expected, @site.data['locations']
    end
  end
end
