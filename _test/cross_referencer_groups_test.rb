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
  class CrossReferencerGroupsTest < ::Minitest::Test
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

    def test_nonexistent_groups_list
      @xref.xref_groups_and_team_members 'groups', ['leads', 'members']
      assert_nil @site.data['groups']
    end

    def test_empty_groups_list
      @site.data['groups'] = []
      @xref.xref_groups_and_team_members 'groups', ['leads', 'members']
      assert_empty @site.data['groups']
    end

    def test_xref_groups_and_team_members
      @site.data['groups'] = [
        {'name' => 'Documentation',
         'leads' => ['mbland'],
         'members' => @team.map {|i| i['name']},
        },
        {'name' => 'Outreach',
         'leads' => ['gboone', 'ekamlley'],
         'members' => ['gboone', 'ekamlley', 'mhz'],
        },
        {'name' => 'Dev',
         'leads' => ['afeld'],
         'members' => ['afeld', 'mbland'],
        },
      ]

      groups_to_leads = {
        'Documentation' => ['mbland'],
        'Outreach' => ['gboone', 'ekamlley'],
        'Dev' => ['afeld'],
      }

      groups_to_members = {
        'Documentation' => @team.map {|i| i['name']},
        'Outreach' => ['gboone', 'ekamlley', 'mhz'],
        'Dev' => ['afeld', 'mbland'],
      }

      # For leads, the group they lead will come first, since 'leads' will be
      # processed before 'members'. Sort of group names for each team member
      # takes place in the canonicalizer module.
      team_members_to_groups = {
        'mbland' => ['Documentation', 'Dev'],
        'afeld' => ['Dev', 'Documentation'],
        'mhz' => ['Documentation', 'Outreach'],
        'gboone' => ['Outreach', 'Documentation'],
        'ekamlley' => ['Outreach', 'Documentation'],
      }

      @xref.xref_groups_and_team_members 'groups', ['leads', 'members']
      assert_equal groups_to_leads, CrossReferencer.property_map(
        @site.data['groups'], 'name', 'leads', 'name')
      assert_equal groups_to_members, CrossReferencer.property_map(
        @site.data['groups'], 'name', 'members', 'name')
      assert_equal team_members_to_groups, CrossReferencer.property_map(
        @site.data['team'], 'name', 'groups', 'name')
    end
  end
end
