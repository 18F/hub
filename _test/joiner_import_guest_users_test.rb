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

require "minitest/autorun"

module Hub
  class ImportGuestUsersTest < ::Minitest::Test
    def setup
      @site = DummyTestSite.new
      @site.data.delete 'private'
    end

    def new_impl
      impl = JoinerImpl.new(@site)
      impl.setup_join_source do |join_source|
        ::HashJoiner.assign_empty_defaults(join_source,
          [], ['hub'], [])
        ::HashJoiner.assign_empty_defaults(join_source['hub'],
          ['guest_users'], [], [])
      end
      impl
    end

    def test_no_private_data
      assert_empty new_impl.import_guest_users
    end

    def test_no_hub_data
      assert_empty new_impl.import_guest_users
      assert_empty @site.data['guest_users']
    end

    def test_no_guest_users
      @site.data['private'] = {'hub' => {}}
      assert_empty new_impl.import_guest_users
      assert_empty @site.data['guest_users']
    end

    def test_guest_users_moved_to_top_level
      guests = [
        {'email' => 'michael.bland@gsa.gov',
         'full_name' => 'Mike Bland'},
        ]
      @site.data['private'] = {'hub' => {'guest_users' => guests}}
      assert_equal guests, new_impl.import_guest_users
      assert_equal guests, @site.data['guest_users']
    end
  end
end
