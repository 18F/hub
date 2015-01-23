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

    # Canonicalizes the order and names of certain fields within site_data.
    def self.canonicalize_data(site_data)
      sort_by_last_name! site_data['team']
      canonicalize_locations(site_data)
      canonicalize_projects(site_data)
      canonicalize_working_groups(site_data)
      canonicalize_snippets(site_data)
      canonicalize_skills(site_data)
    end

    def self.canonicalize_locations(site_data)
      if site_data.member? 'locations'
        site_data['locations'].each {|l| sort_by_last_name! l[1]}
      end
    end

    def self.canonicalize_projects(site_data)
      if site_data.member? 'projects'
        site_data['projects'].each {|p| sort_by_last_name! p['team']}
      end
    end

    def self.canonicalize_working_groups(site_data)
      if site_data.member? 'working_groups'
        site_data['working_groups'].each do |wg|
          ['leads', 'members'].each do |member_type|
            sort_by_last_name! wg[member_type] if wg.member? member_type
          end
        end
      end
    end

    def self.canonicalize_snippets(site_data)
      if site_data.member? 'snippets_team_members'
        sort_by_last_name! site_data['snippets_team_members']
      end
    end

    def self.canonicalize_skills(site_data)
      if site_data.member? 'skills'
        site_data['skills'].each {|unused,xref| combine_skills! xref}
      end
    end

    # Returns a canonicalized, URL-friendly substitute for an arbitrary string.
    # +s+:: string to canonicalize
    def self.canonicalize(s)
      s.downcase.gsub(/\s+/, '-')
    end

    # Returns a canonicalized, URL-friendly substitute for the 'name' field of
    # an arbitrary hash.
    # +data+:: hash containing a 'name' field
    def self.canonicalize_name(data)
      self.canonicalize(data['name'])
    end

    # Sorts in-place an array of data hashes based on the 'name' field.
    # Case-insensitive. Returns the sorted, original array object.
    # +data+:: hash containing a 'name' field
    def self.sort_by_name!(data)
      data.sort_by! {|i| i['name'].downcase}
    end

    # Sorts in-place an array of team member data hashes based on the team
    # members' last names. Returns the sorted, original array object.
    # +team+:: An array of team member data hashes containing 'last_name'
    def self.sort_by_last_name!(team)
      team.sort_by! do |i|
        n = i['full_name'].downcase.split(',')[0]
        l = n.split.last
        [l, n]
      end
    end

    # Breaks a YYYYMMDD timestamp into a hyphenated version: YYYY-MM-DD
    # +timestamp+:: timestamp in the form YYYYMMDD
    def self.hyphenate_yyyymmdd(timestamp)
      "#{timestamp[0..3]}-#{timestamp[4..5]}-#{timestamp[6..7]}"
    end

    # Consolidate skills entries that are not exactly the same. Selects the
    # lexicographically smaller version of the skill name as a standard.
    #
    # In the future, we may just consider raising an error if there are two
    # different strings for the same thing.
    #
    # +skills_ref+:: hash from skills => team members; updated in-place
    def self.combine_skills!(skills_xref)
      canonical_skills = {}
      skills_xref.each do |skill, members|
        canonicalized_skill = Canonicalizer.canonicalize(skill)

        if not canonical_skills.member? canonicalized_skill
          canonical_skills[canonicalized_skill] = skill
        else
          current_canonical = canonical_skills[canonicalized_skill]
          if current_canonical < skill
            skills_xref[current_canonical].concat(members)
            members.clear
          else
            members.concat(skills_xref[current_canonical])
            skills_xref[current_canonical].clear
            canonical_skills[canonicalized_skill] = skill
          end
        end
      end
      skills_xref.delete_if {|unused_skill,members| members.empty?}
    end
  end
end
