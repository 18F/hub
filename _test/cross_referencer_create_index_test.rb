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
  class CrossReferencerCreateIndexTest < ::Minitest::Test
    def test_empty_collection
      assert_empty CrossReferencer.create_index [], nil
    end

    def test_nonempty_collection
      team = [
        {'name' => 'mbland', 'location' => 'DCA'},
        {'name' => 'afeld', 'location' => 'NYC'},
        {'name' => 'mhz', 'location' => 'TUS'},
        {'name' => 'gboone', 'location' => 'DCA'},
        {'name' => 'ekamlley', 'location' => 'DCA'},
      ]

      expected = {
        'DCA' => [team[0], team[3], team[4]],
        'NYC' => [team[1]],
        'TUS' => [team[2]],
      }

      assert_equal expected, CrossReferencer.create_index(team, 'location')
    end

    def test_skip_items_missing_key
      team = [
        {'name' => 'mbland'},
        {'name' => 'afeld', 'location' => 'NYC'},
        {'name' => 'mhz', 'location' => 'TUS'},
        {'name' => 'gboone', 'location' => 'DCA'},
        {'name' => 'ekamlley', 'location' => 'DCA'},
      ]

      expected = {
        'DCA' => [team[3], team[4]],
        'NYC' => [team[1]],
        'TUS' => [team[2]],
      }

      assert_equal expected, CrossReferencer.create_index(team, 'location')
    end
  end
end
