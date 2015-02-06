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
  class CrossReferencerSnippetsTest < ::Minitest::Test
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

    def test_nonexistent_snippets_list
      @xref.xref_snippets_and_team_members
      assert_nil @site.data['snippets']
      assert_nil @site.data['snippets_team_members']
    end

    def test_empty_snippets_list
      @site.data['snippets'] = []
      @xref.xref_snippets_and_team_members
      assert_empty @site.data['snippets']
      assert_nil @site.data['snippets_team_members']
    end

    def test_xref_snippets_and_team_members
      # We programmatically add the timestamp to each "snippet".
      @site.data['snippets'] = {
        '20150112' => [
          {'name' => 'mbland'},
          {'name' => 'afeld'},
          {'name' => 'mhz'},
        ],
        '20150120' => [
          {'name' => 'mbland'},
          {'name' => 'afeld'},
          {'name' => 'gboone'},
        ],
        '20150126' => [
          {'name' => 'mbland'},
          {'name' => 'mhz'},
          {'name' => 'ekamlley'},
        ],
      }.each do |timestamp, snippets|
        snippets.each {|i| i['timestamp'] = timestamp}
      end

      team_members_to_snippets = {
        'mbland' => ['20150112', '20150120', '20150126'],
        'afeld' => ['20150112', '20150120'],
        'mhz' => ['20150112', '20150126'],
        'gboone' => ['20150120'],
        'ekamlley' => ['20150126'],
      }

      # Team member objects are not directly assigned to snippets, so we only
      # need to check the link from team members to snippets.
      @xref.xref_snippets_and_team_members
      assert_equal team_members_to_snippets, CrossReferencer.property_map(
        @site.data['team'], 'name', 'snippets', 'timestamp')
      assert_equal(@team.map {|i| i['name']},
        @site.data['snippets_team_members'].map {|i| i['name']})
    end
  end
end
