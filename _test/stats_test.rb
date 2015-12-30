# 18F Hub - Docs & connections between team members, projects, and skill sets
#
# Written in 2015 by Aidan Feldman (aidan.feldman@gsa.gov)
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
# @author Aidan Feldman (aidan.feldman@gsa.gov)

require_relative 'test_helper'
require_relative 'site_builder'

require 'minitest/autorun'

module Hub
  class StatsTest < ::Minitest::Test
    def test_returns_nil_for_zero_members
      site = ::Jekyll::Site.new(::Jekyll::Configuration::DEFAULTS)
      site.data['team'] = []

      result = Stats.percent_remote(site)
      assert_equal nil, result
    end
  end
end
