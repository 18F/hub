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
  class CrossReferencerCreateXrefsTest < ::Minitest::Test
    def setup
      @team = [
        {'name' => 'mbland'},
        {'name' => 'afeld'},
        {'name' => 'mhz'},
        {'name' => 'gboone'},
        {'name' => 'ekamlley'},
      ]

      @projects = [
        {'name' => 'hub', 'team' => @team.map {|i| i['name']}},
        {'name' => 'c2', 'team' => ['afeld']},
        {'name' => 'eiti', 'team' => ['mhz']},
        {'name' => 'dashboard', 'team' => ['gboone','ekamlley']},
      ]
    end

    def test_empty_collection
      assert_empty CrossReferencer.create_xrefs([], 'unused', {}, 'unused')
    end

    def test_create_xrefs
      projects_to_teams = {
        'hub' => ['mbland', 'afeld', 'mhz', 'gboone', 'ekamlley'],
        'c2' => ['afeld'],
        'eiti' => ['mhz'],
        'dashboard' => ['gboone', 'ekamlley'],
      }

      team_members_to_projects = {
        'mbland' => ['hub'],
        'afeld' => ['hub', 'c2'],
        'mhz' => ['hub', 'eiti'],
        'gboone' => ['hub', 'dashboard'],
        'ekamlley' => ['hub', 'dashboard'],
      }

      team_map = @team.map {|i| [i['name'], i]}.to_h
      assert_same @projects, CrossReferencer.create_xrefs(
        @projects, 'team', team_map, 'projects')
      assert_equal projects_to_teams, CrossReferencer.property_map(
        @projects, 'name', 'team', 'name')
      assert_equal team_members_to_projects, CrossReferencer.property_map(
        @team, 'name', 'projects', 'name')
    end

    def test_ignore_missing_targets
      projects_to_teams = {
        'hub' => ['afeld', 'mhz', 'gboone', 'ekamlley'],
        'c2' => ['afeld'],
        'eiti' => ['mhz'],
        'dashboard' => ['gboone', 'ekamlley'],
      }

      team_members_to_projects = {
        'afeld' => ['hub', 'c2'],
        'mhz' => ['hub', 'eiti'],
        'gboone' => ['hub', 'dashboard'],
        'ekamlley' => ['hub', 'dashboard'],
      }

      @team.shift
      team_map = @team.map {|i| [i['name'], i]}.to_h
      assert_same @projects, CrossReferencer.create_xrefs(
        @projects, 'team', team_map, 'projects')
      assert_equal projects_to_teams, CrossReferencer.property_map(
        @projects, 'name', 'team', 'name')
      assert_equal team_members_to_projects, CrossReferencer.property_map(
        @team, 'name', 'projects', 'name')
    end

    def test_ignore_sources_missing_source_key
      projects_to_teams = {
        'c2' => ['afeld'],
        'eiti' => ['mhz'],
        'dashboard' => ['gboone', 'ekamlley'],
      }

      team_members_to_projects = {
        'afeld' => ['c2'],
        'mhz' => ['eiti'],
        'gboone' => ['dashboard'],
        'ekamlley' => ['dashboard'],
      }

      @projects[0].delete 'team'
      team_map = @team.map {|i| [i['name'], i]}.to_h
      assert_same @projects, CrossReferencer.create_xrefs(
        @projects, 'team', team_map, 'projects')
      assert_equal projects_to_teams, CrossReferencer.property_map(
        @projects, 'name', 'team', 'name')
      assert_equal team_members_to_projects, CrossReferencer.property_map(
        @team, 'name', 'projects', 'name')
    end
  end
end
