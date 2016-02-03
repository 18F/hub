# 18F Hub - Docs & connections between team members, projects, and skill sets
#
# Written in 2016 by Catherine Devlin (catherine.devlin@gsa.gov)
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
# @author Catherine Devlin (catherine.devlin@gsa.gov)

require_relative "test_helper"
require_relative "../_plugins/canonicalizer"

require "minitest/autorun"

module Hub
  class HyphenateDateTest < ::Minitest::Test
    def test_string_hyphenated
      result = Canonicalizer.hyphenate_yyyymmdd "20170202"
      assert_equal(result, "2017-02-02")
    end
  end
end
