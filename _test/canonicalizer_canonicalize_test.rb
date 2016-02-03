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
  class CanonicalizeTest < ::Minitest::Test
    def test_no_changes_needed
      result = Canonicalizer.canonicalize "service"
      assert_equal(result, "service")
    end

    def test_space_is_replaced
      result = Canonicalizer.canonicalize "public service"
      assert_equal(result, "public-service")
    end

    def test_multiple_spaces_are_replaced_once
      result = Canonicalizer.canonicalize "public   service"
      assert_equal(result, "public-service")
    end
  end
end
