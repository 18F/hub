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

require "minitest/autorun"

module Hub
  class CrossReferencerFlattenPropertyTest < ::Minitest::Test
    def setup
      @team = [
        {'name' => 'mbland'},
        {'name' => 'afeld'},
        {'name' => 'mhz'},
        {'name' => 'gboone'},
        {'name' => 'ekamlley'},
      ]

      @projects = [
        {'name' => 'hub', 'team' => @team},
        {'name' => 'c2', 'team' => [@team[1]]},
        {'name' => 'eiti', 'team' => [@team[2]]},
        {'name' => 'dashboard', 'team' => [@team[3],@team[4]]},
      ]

      @expected_projects = [
        {'name' => 'hub', 'team' => @team.map {|i| i['name']}},
        {'name' => 'c2', 'team' => ['afeld']},
        {'name' => 'eiti', 'team' => ['mhz']},
        {'name' => 'dashboard', 'team' => ['gboone','ekamlley']},
      ]
    end

    def test_empty_collection
      assert_empty CrossReferencer.flatten_property([], 'unused', 'unused')
    end

    def test_flatten_property
      result = CrossReferencer.flatten_property @projects, 'team', 'name'
      assert_equal @expected_projects, result
      refute_equal @projects, result
    end

    def test_flatten_property_handle_missing_property
      @projects[0].delete 'team'
      @expected_projects[0].delete 'team'
      result = CrossReferencer.flatten_property @projects, 'team', 'name'
      assert_equal @expected_projects, result
      refute_equal @projects, result
    end

    def test_flatten_property_in_place
      result = CrossReferencer.flatten_property! @projects, 'team', 'name'
      assert_equal @expected_projects, result
      assert_equal @projects, result
    end

    def test_flatten_property_in_place_handle_missing_property
      @projects[0].delete 'team'
      @expected_projects[0].delete 'team'
      result = CrossReferencer.flatten_property! @projects, 'team', 'name'
      assert_equal @expected_projects, result
      assert_equal @projects, result
    end
  end
end
