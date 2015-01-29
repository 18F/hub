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
  class CrossReferencerProjectsTest < ::Minitest::Test
    def setup
      config = {
      }
      @site = DummyTestSite.new(config: config)
      @site.data.delete 'private'
      @site.data.delete 'public'

      @team = [
        {'name' => 'mbland'},
        {'name' => 'afeld'},
        {'name' => 'mhz'},
        {'name' => 'gboone'},
        {'name' => 'ekamlley'},
      ]

      @site.data['team'] = @team
      @xref = CrossReferencerImpl.new @site.data
    end

    def test_empty_projects_list
      @site.data['projects'] = []
      @xref.xref_projects_and_team_members
      assert_empty @site.data['projects']
    end

    def test_xref_projects_and_team_members
      @site.data['projects'] = [
        {'name' => 'hub', 'team' => @team.map {|i| i['name']}.join(',')},
        {'name' => 'c2', 'team' => 'afeld'},
        {'name' => 'eiti', 'team' => 'mhz'},
        {'name' => 'dashboard', 'team' => 'gboone,ekamlley'},
      ]

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

      @xref.xref_projects_and_team_members
      assert_equal projects_to_teams, CrossReferencer.property_map(
        @site.data['projects'], 'name', 'team', 'name')
      assert_equal team_members_to_projects, CrossReferencer.property_map(
        @site.data['team'], 'name', 'projects', 'name')
    end
  end
end
