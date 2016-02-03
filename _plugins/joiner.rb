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

require 'hash-joiner'
require 'team_hub/private_assets'
require 'weekly_snippets/version'

module Hub

  # Joins the data from +_data+, +_data/public+, and +_data/private+ into
  # +site.data+, making the data look as though it came from a single source.
  # Also filters out private data when +site.config[+'public'] is +true+ (aka
  # "public mode").
  class Joiner

    # Executes all of the steps to join the different data sources into
    # +site.data+ and filters out private data when in public mode.
    #
    # Also deletes +site.data[+'public'] and +site.data[+'private'] when
    # processing is complete.
    #
    # +site+:: Jekyll site data object
    def self.join_data(site)
      impl = JoinerImpl.new site

      impl.extend_location_data
      impl.join_snippet_data SNIPPET_VERSIONS
      # impl.import_guest_users   # remove?

      site.data.delete 'private'
    end

    # Assigns empty default values to Hub data objects to avoid the need for
    # `(collection || [])`-style logic in Hub plugins.
    def self.assign_empty_defaults(site_data)
      ::HashJoiner.assign_empty_defaults(site_data,
        ['team', 'projects', 'working_groups'], ['hub'], [])
      ::HashJoiner.assign_empty_defaults(site_data['hub'],
        ['guest_users'], [], [])
    end

    # Used to standardize snippet data of different versions before joining
    # and publishing.
    SNIPPET_VERSIONS = {
      'v1' => ::WeeklySnippets::Version.new(
        version_name:'v1',
        field_map:{
          'Username' => 'username',
          'Timestamp' => 'timestamp',
          'Name' => 'full_name',
          'Snippets' => 'last-week',
          'No This Week' => 'this-week',
        }
      ),
      'v2' => ::WeeklySnippets::Version.new(
        version_name:'v2',
        field_map:{
          'Timestamp' => 'timestamp',
          'Public vs. Private' => 'public',
          'Last Week' => 'last-week',
          'This Week' => 'this-week',
          'Username' => 'username',
        },
        markdown_supported: true
      ),
      'v3' => ::WeeklySnippets::Version.new(
        version_name:'v3',
        field_map:{
          'Timestamp' => 'timestamp',
          'Public' => 'public',
          'Username' => 'username',
          'Last week' => 'last-week',
          'This week' => 'this-week',
        },
        public_field: 'public',
        public_value: 'Public',
        markdown_supported: true
      ),
    }
  end

  # Implements Joiner operations.
  class JoinerImpl
    attr_reader :site, :data, :public_mode, :team_by_email, :source

    # +site+:: Jekyll site data object
    def initialize(site)
      @site = site
      @data = site.data
      @public_mode = site.config['public']

      if (site.data['private'] || {}).empty?
        @source = 'public'
        @join_source = @data
      else
        @source = 'private'
        @join_source = site.data['private']
      end

      # We'll always need a 'team' property.
      @join_source['team'] ||= []
      ['team', 'projects', 'departments', 'working_groups'].each do |c|
        i = @join_source[c]
        @join_source[c] = JoinerImpl.flatten_index(i) if i.instance_of? Hash
      end
      create_team_by_email_index
    end

    # Populates details of team members in location data
    def extend_location_data
      (@data['locations'] or []).each do |loc|
        (loc['team'] || []).each do |member|
          full_member_record = @data['team'].find {|m| m['name'] == member['name']}
          member.update full_member_record
        end
      end
    end

    # Creates +self.team_by_email+, a hash of email address => username to use
    # as an index into +site.data[+'team'] when joining snippet data.
    #
    # MUST be called before remove_data, or else private email addresses will
    # be inaccessible and snippets will not be joined.
    def create_team_by_email_index
      @team_by_email = self.class.create_team_by_email_index(
        @join_source['team'])
    end

    # Creates an index of team member information keyed by email address.
    # @param team [Array<Hash>] contains individual team member information
    # @return [Hash<String, Hash>] email address => team member
    def self.create_team_by_email_index(team)
      team_by_email = {}
      team.each do |i|
        # A Hash containing only a 'private' property is a list of team
        # members whose information is completely private.
        if i.keys == ['private']
          i['private'].each do |private_member|
            email = private_member['email']
            team_by_email[email] = private_member['name'] if email
          end
        else
          email = i['email']
          email = i['private']['email'] if !email and i.member? 'private'
          team_by_email[email] = i['name'] if email
        end
      end
      team_by_email
    end

    # Joins snippet data into +site.data[+'snippets'] and filters out snippets
    # from team members not appearing in +site.data[+'team'] or
    # +team_by_email+.
    #
    # Snippet data is expected to be stored in files matching the pattern:
    # +_data/+@source/snippets/[version]/[YYYYMMDD].csv
    #
    # resulting in the initial structure:
    # +site.data[@source][snippets][version][YYYYMMDD] = Array<Hash>
    #
    # After this function returns, the new structure will be:
    # +site.data[snippets][YYYYMMDD] = Array<Hash>
    #
    # and each individual snippet will have been converted to a standardized
    # format defined by ::WeeklySnippets::Version.
    def join_snippet_data(snippet_versions)
      standardized = ::WeeklySnippets::Version.standardize_versions(
        @join_source['snippets'], snippet_versions)
      team = {}
      @data['team'].each {|i| team[i['name']] = i}
      result = {}
      standardized.each do |timestamp, snippets|
        joined = []
        snippets.each do |snippet|
          username = snippet['username']
          team_members = team.select do |member|
            (team[member]['name'] == snippet['username'] ||
             team[member]['deprecated_name'] == snippet['username'] ||
             team[member]['email'] == snippet['username'] )
          end
          member, member_data = team_members.first
          if member
            snippet['name'] = member_data['name']
            snippet['full_name'] = member_data['full_name']
            joined << snippet
          end
        end
        result[timestamp] = joined unless joined.empty?
      end
      @data['snippets'] = result
    end

  end
end
