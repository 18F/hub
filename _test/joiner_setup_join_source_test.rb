# 18F Hub - Docs & connections between team members, projects, and skill sets
#
# Written in 2014 by Mike Bland (michael.bland@gsa.gov)
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
require_relative "../_plugins/joiner"
require_relative "site"

require "hash-joiner"
require "minitest/autorun"

module Hub
  class SetupJoinSourceTest < ::Minitest::Test
    def setup
      @site = DummyTestSite.new
      @site.data['private']['team'] = [
        {'name' => 'mbland', 'full_name' => 'Mike Bland',
         'private' => {'email' => 'michael.bland@gsa.gov'}
        },
        {'private' => [
          {'name' => 'foobar', 'full_name' => 'Foo Bar'},
          ],
        },
      ]
    end

    def test_remove_private_data
      @site.config['public'] = true
      impl = JoinerImpl.new(@site)
      impl.setup_join_source
      assert_equal(
        [{'name' => 'mbland', 'full_name' => 'Mike Bland'}],
        @site.data['private']['team'])
    end

    def test_promote_private_data
      impl = JoinerImpl.new(@site)
      impl.setup_join_source
      assert_equal(
        [{'name' => 'mbland', 'full_name' => 'Mike Bland',
          'email' => 'michael.bland@gsa.gov',
         },
         {'name' => 'foobar', 'full_name' => 'Foo Bar'},
        ],
        @site.data['private']['team'])
    end

    def test_process_data_using_block
      impl = JoinerImpl.new(@site)
      impl.setup_join_source do |join_source|
        ::HashJoiner.assign_empty_defaults(join_source['team'],
          ['working_groups', 'projects'], [], ['email'])
      end

      assert_equal(
        [{'name' => 'mbland', 'full_name' => 'Mike Bland',
          'email' => 'michael.bland@gsa.gov',
          'working_groups' => [], 'projects' => [],
         },
         {'name' => 'foobar', 'full_name' => 'Foo Bar',
          'email' => '',
          'working_groups' => [], 'projects' => [],
         },
        ],
        @site.data['private']['team'])
    end

  end
end
