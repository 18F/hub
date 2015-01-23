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

  # Builds cross-references between data sets.
  class CrossReferencer
    # Build cross-references between data sets.
    # +site_data+:: Jekyll +site.data+ object
    def self.build_xrefs(site_data)
      impl = CrossReferencerImpl.new site_data
      impl.xref_locations_and_team_members
      impl.xref_projects_and_team_members
      impl.xref_working_groups_and_team_members
      impl.xref_snippets_and_team_members
      impl.xref_skills_and_team_members
    end
  end

  # Implements CrossReferencer operations.
  class CrossReferencerImpl
    attr_reader :site_data

    def initialize(site_data)
      @site_data = site_data
      @team = {}
      @site_data['team'].each {|i| @team[i['name']] = i}
    end

    # Cross-references geographic locations with team members.
    def xref_locations_and_team_members
      locations = {}
      @site_data['team'].each do |member|
        member_location = member['location']
        if member_location
          unless locations.member? member_location
            locations[member_location] = []
          end
          locations[member_location] << member
        end
      end
      locations = locations.to_a
      @site_data['locations'] = locations.sort! unless locations.empty?
    end

    # Cross-references projects with team members. Replaces string-based
    # site_data['projects']['team'] values with team member hashes.
    def xref_projects_and_team_members
      @site_data['projects'].each do |p|
        p['team'] = '' unless p.member? 'team'
        expanded_team = []

        p['team'].split(/, ?/).each do |username|
          # If some team members' info is private, they will not be listed in
          # team and will not appear as part of the project.
          if @team.member? username
            member = @team[username]
            member['projects'] = [] unless member.member? 'projects'
            member['projects'] << p
            expanded_team << member
          end
        end

        p['team'] = expanded_team
      end
    end

    # Cross-references working groups with team members.
    def xref_working_groups_and_team_members
      return unless @site_data.member? 'working_groups'
      working_groups = @site_data['working_groups']
      all_wg_members = {}

      working_groups.each do |wg|
        ['leads', 'members'].each do |member_type|
          add_group_to_members(wg, member_type, all_wg_members)
        end
      end

      all_wg_members.each do |unused_name, member|
        member['working_groups'].sort_by! {|wg| wg['name']}
        member['working_groups'].uniq! {|wg| wg['name']}
      end
    end

    # Adds a working group cross-reference to each working group team member.
    def add_group_to_members(working_group, member_type, all_wg_members)
      return unless working_group.member? member_type

      wg_members = working_group[member_type].map {|i| @team[i]}
      wg_members.compact!
      working_group[member_type] = wg_members

      wg_members.each do |member|
        unless member.member? 'working_groups'
          member['working_groups'] = []
        end
        member['working_groups'] << working_group
        all_wg_members[member['name']] = member
      end
    end

    # Cross-references snippets with team members. Also sets
    # site.data['snippets_latest'].
    def xref_snippets_and_team_members
      return unless @site_data.member? 'snippets'
      members_with_snippets = []

      @site_data['snippets'].each do |timestamp, snippets|
        snippets.each do |snippet|
          member = @team[snippet['name']]
          member['snippets'] = [] unless member.member? 'snippets'
          member['snippets'] << snippet
          members_with_snippets << member
        end

        # Since the snippets are naturally ordered in chronological order,
        # the last will be the latest.
        @site_data['snippets_latest'] = timestamp
      end

      members_with_snippets.sort_by! {|i| i['name']}.uniq!
      @site_data['snippets_team_members'] = members_with_snippets
    end

    # Cross-references skillsets with team members.
    def xref_skills_and_team_members
      skills = {
        'Languages' => Hash.new {|h,k| h[k] = Array.new},
        'Technologies' => Hash.new {|h,k| h[k] = Array.new},
        'Specialties' => Hash.new {|h,k| h[k] = Array.new},
      }

      @site_data['team'].each do |member|
        skills.each do |category, category_xref|
          add_skill_xref_if_present(category.downcase, member, category_xref)
        end
      end

      skills.delete_if {|category,skill_xref| skill_xref.empty?}
      @site_data['skills'] = skills unless skills.empty?
    end

    # Adds a team member cross reference for each of a team member's skills.
    # +category+:: category of skill (e.g. Languages, Technologies)
    # +team_member+:: team member to add to skill cross-references
    # +category_xref+:: hash representing a skill index for +category+
    def add_skill_xref_if_present(category, team_member, category_xref)
      if team_member.member? category
        team_member[category].each do |skill|
          category_xref[skill] << team_member
        end
      end
    end
  end
end
