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

module Hub

  # Contains Hub-specific Liquid filters.
  module Filters

    # Breaks a YYYYMMDD timestamp into a hyphenated version: YYYY-MM-DD
    # +timestamp+:: timestamp in the form YYYYMMDD
    def hyphenate_yyyymmdd(timestamp)
      Canonicalizer.hyphenate_yyyymmdd timestamp
    end

    # Returns a canonicalized, URL-friendly substitute for an arbitrary string.
    # +s+:: string to canonicalize
    def canonicalize(s)
      Canonicalizer.canonicalize s
    end

    # Slight tweak of
    # https://github.com/Shopify/liquid/blob/v2.6.1/lib/liquid/standardfilters.rb#L71-L74
    # to replace newlines with spaces.
    def condense(input)
      input.to_s.gsub(/\r?\n/, ' '.freeze).strip
    end
  end
end

Liquid::Template.register_filter(Hub::Filters)
