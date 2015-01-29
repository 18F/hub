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

require 'team_hub/page'

module Hub

  # Functions for generating JSON objects as part of an API
  class Api
    # Generates all of the Hub's API endpoints.
    # +site+:: Jekyll site object
    def self.generate_api(site)
      endpoint_info = [
        generate_team_endpoint(site),
        generate_team_authentication_endpoint(site),
        generate_locations_endpoint(site),
        generate_pages_endpoint(site),
        generate_projects_endpoint(site),
        generate_departments_endpoint(site),
        generate_working_groups_endpoint(site),
      ]
      endpoint_info.concat generate_skills_endpoints(site)
      endpoint_info = endpoint_info.select {|i| i and !i.empty?}
      generate_api_index(site, endpoint_info) unless endpoint_info.empty?
    end

    # Generates an index at /api describing the different endpoints.
    # +site+:: Jekyll site object
    # +endpoint_info+:: a list of [endpoint, title, description] elements
    def self.generate_api_index(site, endpoint_info)
      page = ::TeamHub::Page.generate(site, 'api', 'index.html',
        'api_index.html', 'API Endpoint Index')
      page.data['endpoints'] = endpoint_info.map do |i|
        {'endpoint' => i[0], 'title' => i[1], 'description' => i[2]}
      end
    end

    def self.generate_team_endpoint(site)
      return unless site.data.member? 'team'
      team = site.data['team']
      return if team.empty?
      fields = ['first_name', 'last_name', 'full_name', 'image',
         'pif-round', 'bio', 'email', 'slack', 'location',
         'languages', 'technologies', 'specialties']
      join_fields = {'projects' => 'name', 'departments' => 'name',
         'working_groups' => 'name'}
      data = create_filtered_hash(team, 'name', fields, join_fields)
      generate_endpoint(site, 'team', 'Team',
        'Team member info, indexed by username', data)
    end

    def self.generate_team_authentication_endpoint(site)
      return unless site.data.member? 'team'
      team = site.data['team'].select {|i| i.member? 'email'}
      return if team.empty?
      fields = ['name', 'full_name', 'image']
      data = create_filtered_hash(team, 'email', fields, {})
      generate_endpoint(site, File.join('team', 'auth'),
        'Team Authentication',
        'Basic information on authenticated team members, indexed by email',
        data)
    end

    def self.generate_locations_endpoint(site)
      locations = site.data['locations']
      return if !locations or locations.empty?
      data = {}
      locations.each do |location,members|
        data[location] = members.map {|member| member['name']}
      end
      generate_endpoint(site, 'locations', 'Locations',
        'Index of team members by location code', data)
    end

    def self.generate_pages_endpoint(site)
      # file created through jekyll_pages_api gem, so just need to return
      # information for the index page
      ['v1/pages.json', 'Pages', "Page metadata and content"]
    end

    def self.generate_projects_endpoint(site)
      projects = site.data['projects']
      return if !projects or projects.empty?
      fields = ['project', 'github', 'partner', 'impact', 'stage',
        'milestones', 'contact', 'stack', 'licenses', 'links', 'status']
      join_fields = {'team' => 'name'}
      data = create_filtered_hash(projects, 'name', fields, join_fields)
      generate_endpoint(site, 'projects', 'Projects',
        'Project info, indexed by short project name', data)
    end

    def self.generate_departments_endpoint(site)
      departments = site.data['departments']
      return if !departments or departments.empty?
      generate_endpoint(site, 'departments', 'Departments',
        'Department info, indexed by department name',
        create_filtered_hash(departments, 'name', ['links'], {}))
    end

    def self.generate_working_groups_endpoint(site)
      wg = site.data['working_groups']
      return if !wg or wg.empty?
      fields = ['slack', 'agenda', 'wiki', 'drive', 'links']
      join_fields = {'leads' => 'name', 'members' => 'name'}
      data = create_filtered_hash(wg, 'name', fields, join_fields)
      generate_endpoint(site, 'working_groups', 'Working Groups',
        'Working group info, indexed by name', data)
    end

    # Generates an endpoint for each skill category and returns a list of
    # endpoint info, one element per skill category.
    def self.generate_skills_endpoints(site)
      return [] unless site.data.member? 'skills'
      endpoint_info = []
      ['Languages', 'Technologies', 'Specialties'].each do |category|
        category_index = site.data['skills'][category]
        next if category_index.nil? || category_index.empty?
        skills = {}
        category_index.each do |skill, members|
          skills[skill] = members.map {|i| i['name']}
        end
        endpoint_info << generate_endpoint(site,
          Canonicalizer.canonicalize(category), "#{category}",
          "Index of team members by #{category.downcase}", skills)
      end
      endpoint_info
    end

    # Generates a hash of key_field => filtered object for each object in the
    # collection list.
    # +collection+:: a list of hash objects
    # +key_field+:: key into each hash that will provide the key values for
    #   the returned hash
    # +fields+:: see filter_object()
    # +join_fields+:: see filter_object()
    def self.create_filtered_hash(collection, key_field, fields, join_fields)
      data = {}
      collection.each do |i|
        data[i[key_field]] = filter_object(i, fields, join_fields)
      end
      data
    end

    # Generates a hash containing API data by filtering and flattening data
    # from source.
    # +source+:: hash containing data to export via an API
    # +fields+:: list of field names to copy directly
    # +join_fields+:: hash of field_name => hash_key, where source[field_name]
    #   is a list of hash values, and source[field_name][hash_key] produces
    #   the value used to join the individual hash elements with other data
    def self.filter_object(source, fields, join_fields)
      d = {}
      collect_fields(d, source, fields)
      join_fields.each {|k,v| collect_join_keys(d, source, k, v)}
      d
    end

    # Generates a new API endpoint based on +data+ and returns a list of
    # [endpoint, title, description]. Returns an empty list if data is empty,
    # resulting in no endpoint being generated.
    def self.generate_endpoint(site, endpoint, title, description, data)
      return if data.empty?
      api_endpoint = File.join('api', endpoint)
      page = ::TeamHub::Page.generate(site, api_endpoint, 'index.html',
        'api.json', "API: #{title}")
      page.data['json'] = JSON.generate(data)
      return [endpoint, title, description]
    end

    # Directly copies fields from source to result, if present.
    def self.collect_fields(result, source, fields)
      fields.each do |f|
        val = source[f] if source.member? f
        result[f] = val if val != nil
      end
    end

    # Creates a new list, result[field], whose elements are the values used to
    # join result[field] to other data.
    def self.collect_join_keys(result, source, field, join_key)
      if source.member? field
        result[field] = source[field].map {|i| i[join_key]}
      end
    end
  end
end
