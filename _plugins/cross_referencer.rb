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
      impl.xref_groups_and_team_members 'working_groups', ['leads', 'members']
      impl.xref_snippets_and_team_members
      impl.xref_skills_and_team_members(
        ['Languages', 'Technologies', 'Specialties'])
    end

    # Creates an index of +collection+ items based on +key+.
    #
    # @param collection [Array<Hash>] collection from which to build an index
    # @param key [String] property used to build the index
    # @return [Hash]
    def self.create_index(collection, key)
      index = {}
      collection.each {|i| (index[i[key]] ||= Array.new) << i if i[key]}
      index
    end

    # Creates cross-references between Hash objects in +sources+ and Hash
    # objects in +targets+.
    #
    # Each object in +sources+ should have a +source_key+ member that is an
    # Array<String> of target identifiers (keys into +targets+) that will be
    # replaced with an Array<Hash> of object references from +targets+.
    #
    # Objects in +targets+ should not yet contain an +target_key+ member. This
    # member will be created as an Array<Hash> of object references from
    # +sources+.
    #
    # If an object cross-referenced by an object in +sources+ does not exist
    # in +targets+, that cross-reference will be skipped without error. If an
    # object from +sources+ does not contain a +source_key+ property, it will
    # also be skipped.
    #
    # @param sources [Array<Hash>] objects containing the information
    #   needed to establish cross-references with objects in +targets+
    # @param source_key [String] identifies the cross-referenced property from
    #   +sources+
    # @param targets [Hash<Hash>] index of objects to cross-reference with
    #   objects from +sources+
    # @param target_key [String] identifies the cross-referenced property from
    #   +targets+
    def self.create_xrefs(sources, source_key, targets, target_key)
      (sources || []).each do |source|
        (source[source_key] || []).map! do |target_id|
          target = targets[target_id]
          (target[target_key] ||= Array.new) << source if target
          target
        end.compact!
      end
    end

    # Creates a copy of +collection+ where each item's +property+ member has
    # had its objects replaced with an Array of +property_key+ values.
    #
    # The primary use case is to "flatten" a list of Hash objects that have a
    # cross-reference links back to Hash objects in +collection+. While
    # cross-referencing objects make it easy to traverse the object graph
    # in-memory, it is useful to flatten these cross-references when
    # serializing data, generating API data, checking cross-references in
    # automated tests (in concert with property_map, to avoid producing
    # voluminous output for assertion failures due to extraneous data and the
    # infinite recursion between cross-referenced objects), logging, and error
    # reporting.
    #
    # @param collection [Array<Hash>] objects for which to flatten the
    #   +property+ collection
    # @param property [String] property of objects in +collection+
    #   corresponding to a list of (possibly cross-referenced) Hash objects
    # @param property_key [String] primary key of cross-referenced objects; the
    #   corresponding value should be a String
    # @return [Array] a copy of collection with +property+ items flattened
    def self.flatten_property(collection, property, property_key)
      collection.map do |i|
        item = i.clone
        item[property] = i[property].map {|p| p[property_key]} if i[property]
        item
      end
    end

    # The in-place version of flatten_property which directly replaces the
    # +property+ member of each item of +collection+ with an Array of
    # +property_key+ values.
    #
    # In addition to the use cases described in the the flatten_property
    # comment, the in-place version may be useful to help free memory by
    # eliminating circular object references.
    #
    # @see flatten_property
    def self.flatten_property!(collection, property, property_key)
      collection.each do |i|
        i[property].map! {|p| p[property_key]} if i[property]
      end
    end

    # Creates a map from +primary_key+ values to flattened +property+ values
    # for each item in +collection+.
    #
    # For checking cross-referenced property values in automated tests,
    # first process +collection+ using flatten_property to avoid voluminous
    # output due to the infinite recursion between cross-referenced objects.
    #
    # @param collection [Array<Hash>] objects for which to flatten the
    #   +property+ collection
    # @param primary_key [String] primary key for objects in +collection+; the
    #   corresponding value should be a String
    # @param property [String] property of objects in +collection+
    #   corresponding to a list of (possibly cross-referenced) Hash objects
    # @param property_key [String] primary key of cross-referenced objects; the
    #   corresponding value should be a String
    # @return [Hash<String, Array<String>>] +primary_key+ values =>
    #   flattened +property+ values
    # @see flatten_property
    def self.property_map(collection, primary_key, property, property_key)
      collection.map do |i|
        [i[primary_key], i[property].map {|p| p[property_key]}] if i[property]
      end.compact.to_h
    end
  end

  # Implements CrossReferencer operations.
  class CrossReferencerImpl
    attr_reader :site_data

    def initialize(site_data)
      @site_data = site_data
      @team = @site_data['team'].map {|i| [i['name'], i]}.to_h
    end

    # Cross-references geographic locations with team members.
    #
    # The resulting site.data['locations'] collection will be an Array of
    # [location code, Array<Hash> of team members].
    def xref_locations_and_team_members
      locations = CrossReferencer.create_index(@site_data['team'], 'location')
      @site_data['locations'] = locations.to_a.sort! unless locations.empty?
    end

    # Cross-references projects with team members. Replaces string-based
    # site_data['projects']['team'] values with team member hashes.
    def xref_projects_and_team_members
      projects = @site_data['projects']
      projects.each {|p| p['team'] = p['team'].split(/, ?/) if p['team']}
      CrossReferencer.create_xrefs projects, 'team', @team, 'projects'
    end

    # Cross-references groups with team members.
    #
    # @param groups_name [String] site.data key identifying the group
    #   collection, e.g. 'working_groups'
    # @param member_type_list_names [Array<String>] names of the properties
    #   identifying lists of members, e.g. ['leads', 'members']
    def xref_groups_and_team_members(groups_name, member_type_list_names)
      member_type_list_names.each do |member_type|
        CrossReferencer.create_xrefs(
          @site_data[groups_name], member_type, @team, groups_name)
      end
      @team.values.each {|i| (i[groups_name] || []).uniq! {|g| g['name']}}
    end

    # Cross-references snippets with team members. Also sets
    # site.data['snippets_latest'] and @site_data['snippets_team_members'].
    def xref_snippets_and_team_members
      (@site_data['snippets'] || []).each do |timestamp, snippets|
        snippets.each do |snippet|
          (@team[snippet['name']]['snippets'] ||= Array.new) << snippet
        end

        # Since the snippets are naturally ordered in chronological order,
        # the last will be the latest.
        @site_data['snippets_latest'] = timestamp
      end

      @site_data['snippets_team_members'] = @team.values.select do |i|
        i['snippets']
      end unless (@site_data['snippets'] || []).empty?
    end

    # Cross-references skillsets with team members.
    #
    # @param skills [Array<String>] list of skill categories; may be
    #   capitalized, though the members of site.data['team'] pertaining to
    #   each category should be lowercased
    def xref_skills_and_team_members(categories)
      skills = categories.map {|category| [category, Hash.new]}.to_h

      @team.values.each do |i|
        skills.each do |category, xref|
          (i[category.downcase] || []).each {|s| (xref[s] ||= Array.new) << i}
        end
      end

      skills.delete_if {|category, skill_xref| skill_xref.empty?}
      @site_data['skills'] = skills unless skills.empty?
    end
  end
end
