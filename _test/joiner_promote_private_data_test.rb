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
  class PromotePrivateDataTest < ::Minitest::Test
    def setup
      @site = DummyTestSite.new
    end

    def test_no_impact_if_source_is_not_private
      @site.data['team'] = [
        {'name' => 'mbland', 'full_name' => 'Mike Bland',
         'email' => 'michael.bland@gsa.gov'},
      ]
      impl = JoinerImpl.new(@site)
      impl.promote_private_data 'team'
      assert_equal(
        [{'name' => 'mbland', 'full_name' => 'Mike Bland',
          'email' => 'michael.bland@gsa.gov'}],
        @site.data['team'])
    end

    def test_promote_team_data_from_private_source
      @site.data['private']['team'] = [
        {'name' => 'mbland', 'full_name' => 'Mike Bland',
         'email' => 'michael.bland@gsa.gov'},
      ]
      impl = JoinerImpl.new(@site)
      impl.promote_private_data 'team'
      assert_equal(
        [{'name' => 'mbland', 'full_name' => 'Mike Bland',
          'email' => 'michael.bland@gsa.gov'}],
        @site.data['team'])
    end
  end
end
