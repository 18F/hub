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
require_relative "../_plugins/canonicalizer"

require "minitest/autorun"

module Hub
  class SortByLastNameTest < ::Minitest::Test
    def test_sort_empty_team
      assert_empty Canonicalizer.sort_by_last_name! []
    end

    def test_sort_single_entry_without_last_name
      team = [{'name' => 'mbland', 'full_name' => 'Mike Bland'}]
      assert_equal([{'name' => 'mbland', 'full_name' => 'Mike Bland'}],
        Canonicalizer.sort_by_last_name!(team))
    end

    def test_sort_single_entry_without_full_name
      team = [
        {'name' => 'mbland', 'first_name' => 'Mike', 'last_name' => 'Bland'}]
      assert_equal(
        [{'name' => 'mbland', 'first_name' => 'Mike', 'last_name' => 'Bland'}],
        Canonicalizer.sort_by_last_name!(team))
    end

    def test_sort_mixed_entries
      team = [
        {'name' => 'adelevie',
         'first_name' => 'Alan', 'last_name' => 'deLevie'},
        {'name' => 'afeld',
         'first_name' => 'Aidan', 'last_name' => 'Feldman'},
        {'name' => 'annalee', 'full_name' => 'Annalee Flower Horne',
         'first_name' => 'Annalee', 'last_name' => 'Flower Horne'},
        {'name' => 'mbland',
         'full_name' => 'Mike Bland'},
        {'name' => 'mhz',
         'first_name' => 'Michelle', 'last_name' => 'Hertzfeld'},
      ]

      expected = [
        {'name' => 'mbland',
         'full_name' => 'Mike Bland'},
        {'name' => 'adelevie',
         'first_name' => 'Alan', 'last_name' => 'deLevie'},
        {'name' => 'afeld',
         'first_name' => 'Aidan', 'last_name' => 'Feldman'},
        {'name' => 'annalee', 'full_name' => 'Annalee Flower Horne',
         'first_name' => 'Annalee', 'last_name' => 'Flower Horne'},
        {'name' => 'mhz',
         'first_name' => 'Michelle', 'last_name' => 'Hertzfeld'},
      ]
      assert_equal expected, Canonicalizer.sort_by_last_name!(team)
    end
  end
end
