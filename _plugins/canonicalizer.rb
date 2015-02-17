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
        site_data['projects'].each do |p|
          sort_by_last_name! p['team'] if p['team']
        end
      end
    end

    def self.canonicalize_working_groups(site_data)
      if site_data.member? 'working_groups'
        site_data['working_groups'].each do |wg|
          ['leads', 'members'].each do |member_type|
            sort_by_last_name! wg[member_type] if wg.member? member_type
          end
        end

        site_data['team'].each do |member|
          (member['working_groups'] || []).sort_by! {|wg| wg['name']}
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

    # Consolidate skills entries that are not exactly the same. Selects the
    # lexicographically smaller version of the skill name as a standard.
    #
    # In the future, we may just consider raising an error if there are two
    # different strings for the same thing.
    #
    # +skills_ref+:: hash from skills => team members; updated in-place
    def self.combine_skills!(skills_xref)
      canonicals = {}
      skills_xref.each do |skill, members|
        canonicalized = Canonicalizer.canonicalize(skill)

        if not canonicals.member? canonicalized
          canonicals[canonicalized] = skill
        else
          current = canonicals[canonicalized]
          if current < skill
            skills_xref[current].concat(members)
            members.clear
          else
            members.concat(skills_xref[current])
            skills_xref[current].clear
            canonicals[canonicalized] = skill
          end
        end
      end
      skills_xref.delete_if {|unused_skill,members| members.empty?}
    end
  end
end
