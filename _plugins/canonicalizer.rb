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

  # Contains utility functions for canonicalizing names and the order of data.
  class Canonicalizer

    # Returns a canonicalized, URL-friendly substitute for an arbitrary string.
    # +s+:: string to canonicalize
    def self.canonicalize(s)
      s.downcase.gsub(/\s+/, '-')
    end

    # Sorts in-place an array of team member data hashes based on the team
    # members' last names. Returns the sorted, original array object.
    # +team+:: An array of team member data hashes
    def self.sort_by_last_name!(team)
      team.sort_by! do |i|
        if i['last_name']
          [i['last_name'].downcase, i['first_name'].downcase]
        else
          n = i['full_name'].downcase.split(',')[0]
          l = n.split.last
          [l, n]
        end
      end
    end

    # Breaks a YYYYMMDD timestamp into a hyphenated version: YYYY-MM-DD
    # +timestamp+:: timestamp in the form YYYYMMDD
    def self.hyphenate_yyyymmdd(timestamp)
      "#{timestamp[0..3]}-#{timestamp[4..5]}-#{timestamp[6..7]}"
    end
  end
end
