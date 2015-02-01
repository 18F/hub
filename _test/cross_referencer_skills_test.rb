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
  class CrossReferencerSkillsTest < ::Minitest::Test
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

    def test_nonexistent_skills
      @xref.xref_skills_and_team_members ['Languages', 'Specialties']
      assert_nil @site.data['skills']
    end

    def test_empty_skill_category_not_created
      @team[0]['languages'] = ['C++']
      @xref.xref_skills_and_team_members ['Languages', 'Specialties']
      refute_nil @site.data['skills']
      assert_equal({'C++' => ['mbland']},
        @site.data['skills']['Languages'].each do |unused_language, members|
          members.map! {|i| i['name']}
        end)
      assert_nil @site.data['skills']['Specialties']
    end

    def test_xref_skills_and_team_members
      @team[0]['languages'] = ['C++', 'Python']
      @team[0]['specialties'] = ['Automated Testing', 'Blues Guitar']
      @team[1]['languages'] = ['Ruby', 'Javascript']
      @team[1]['specialties'] = ['Dancing']
      @team[2]['languages'] = ['Javascript', 'CSS']
      @team[2]['specialties'] = ['Info Architecture', 'Hiking']
      @team[3]['languages'] = ['Python', 'Ruby']
      @team[3]['specialties'] = ['Outreach', 'Blues Guitar']
      @team[4]['languages'] = ['Javascript', 'CSS']
      @team[4]['specialties'] = ['Outreach', 'Info Architecture']

      expected_languages = {
        'C++' => ['mbland'],
        'Python' => ['mbland', 'gboone'],
        'Ruby' => ['afeld', 'gboone'],
        'Javascript' => ['afeld', 'mhz', 'ekamlley'],
        'CSS' => ['mhz', 'ekamlley'],
      }

      expected_specialties = {
        'Automated Testing' => ['mbland'],
        'Blues Guitar' => ['mbland', 'gboone'],
        'Dancing' => ['afeld'],
        'Info Architecture' => ['mhz', 'ekamlley'],
        'Hiking' => ['mhz'],
        'Outreach' => ['gboone', 'ekamlley'],
      }

      @xref.xref_skills_and_team_members ['Languages', 'Specialties']
      refute_nil @site.data['skills']
      assert_equal(expected_languages,
        @site.data['skills']['Languages'].each do |unused, members|
          members.map! {|i| i['name']}
        end)
      assert_equal(expected_specialties,
        @site.data['skills']['Specialties'].each do |unused, members|
          members.map! {|i| i['name']}
        end)
    end
  end
end
