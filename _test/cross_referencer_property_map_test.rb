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
  class CrossReferencerPropertyMapTest < ::Minitest::Test
    def test_empty_collection
      assert_empty CrossReferencer.property_map [], nil, nil, nil
    end

    def test_nonempty_collection
      team = [
        {'name' => 'mbland'},
        {'name' => 'afeld'},
        {'name' => 'mhz'},
        {'name' => 'gboone'},
        {'name' => 'ekamlley'},
      ]

      projects = [
        {'name' => 'hub', 'team' => team},
        {'name' => 'c2', 'team' => [team[1]]},
        {'name' => 'eiti', 'team' => [team[2]]},
        {'name' => 'dashboard', 'team' => [team[3], team[4]]},
      ]

      projects_to_teams = {
        'hub' => ['mbland', 'afeld', 'mhz', 'gboone', 'ekamlley'],
        'c2' => ['afeld'],
        'eiti' => ['mhz'],
        'dashboard' => ['gboone', 'ekamlley'],
      }

      assert_equal projects_to_teams, CrossReferencer.property_map(
        projects, 'name', 'team', 'name')
    end
  end
end
