require 'hash-joiner'
require_relative 'canonicalizer'

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
      impl.setup_join_source

      impl.join_team_data
      impl.join_project_data

      impl.join_data 'departments', 'name'
      impl.join_data 'email_groups', 'name'
      impl.join_data 'nav_links', 'name'
      impl.join_data 'working_groups', 'name'

      impl.join_snippet_data
      impl.join_project_status
      impl.import_guest_users
      impl.filter_private_pages

      site.data.delete 'public'
      site.data.delete 'private'
    end
  end

  # Implements Joiner operations.
  class JoinerImpl
    attr_reader :site, :data, :public_mode, :team_by_email, :source

    # +site+:: Jekyll site data object
    def initialize(site)
      @site = site
      @data = site.data
      @public_mode = site.config['public']
      @team_by_email = {}
      private_data = site.data['private'] || {}
      @source = private_data.empty? ? 'public' : 'private'
      @join_source = site.data[@source]
      create_team_by_email_index
    end

    # Joins public and private team data, filters out non-18F PIFs, and builds
    # the +team_by_email+ index used to join snippet data.
    def join_team_data
      join_data 'team', 'name'
      convert_to_hash 'team', 'name'
      assign_team_member_images
    end

    # Joins public and private project data.
    def join_project_data
      join_data 'projects', 'name'

      if @public_mode
        @data['projects'].delete_if {|p| p['status'] == 'Hold'}
      end
    end

    # Creates +self.team_by_email+, a hash of email address => username to use
    # as an index into +site.data[+'team'] when joining snippet data.
    #
    # MUST be called before remove_data, or else private email addresses will
    # be inaccessible and snippets will not be joined.
    def create_team_by_email_index
      source = @data[@source] || {}
      team = source['team'] || []
      team.each do |i|
        # A Hash containing only a 'private' property is a list of team
        # members whose information is completely private.
        if i.keys == ['private']
          i['private'].each do |private_member|
            email = private_member['email']
            @team_by_email[email] = private_member['name'] if email
          end
        else
          email = i['email']
          email = i['private']['email'] if !email and i.member? 'private'
          @team_by_email[email] = i['name'] if email
        end
      end
    end

    # Prepares +site.data[@source]+ prior to joining its data with
    # +site.data+. All data nested within +'private'+ attributes will be
    # stripped when @public_mode is +true+, and will be promoted to the same
    # level as its parent when @public_mode is +false+.
    def setup_join_source
      if @public_mode
        HashJoiner.remove_data @join_source, 'private'
      else
        HashJoiner.promote_data @join_source, 'private'
      end
    end

    # Joins data from +site.data[@source]+ (where +@source+ is +'private'+ or
    # +'public'+) into +site.data+, if it exists.
    # +category+:: key into +site.data[source]+ specifying data collection
    # +key_field+:: if specified, primary key for Array of joined objects
    def join_data(category, key_field)
      HashJoiner.join_data category, key_field, @data, @join_source
    end

    # Converts a list of hash objects within +site.data[+'category'] into a
    # hash of hash objects, using the value of +key_field+ from each object as
    # the hash key for the new hash.
    # +category+:: key into +site.data+ specifying collection
    # +key_field+:: primary key for site.data[category] objects
    def convert_to_hash(category, key_field)
      h = {}
      @data[category].each {|i| h[i[key_field]] = i}
      @data[category] = h
    end

    # Assigns the +image+ property of each team member based on the team
    # member's username and whether or not an image asset exists for that team
    # member. +site.config[+'missing_team_member_img'] is used as the default
    # when no image asset is available.
    def assign_team_member_images
      base = @site.source
      img_dir = site.config['team_img_dir']
      missing = File.join(img_dir, site.config['missing_team_member_img'])

      site.data['team'].each do |name, member|
        img = File.join(img_dir, "#{name}.jpg")

        if (File.exists? File.join(base, img) or
            PrivateAssets.exists?(site, img))
          member['image'] = img
        else
          member['image'] = missing
        end
      end
    end

    # Joins snippet data into +site.data[+'snippets'] and filters out snippets
    # from team members not appearing in +team_by_email+.
    def join_snippet_data
      team = @data['team']
      result = {}

      @data[@source]['snippets'].each do |version, collection|
        collection.each do |timestamp, all_snippets|
          published = []
          all_snippets.each do |snippet|
            s = {}
            snippet.each {|k,v| s[Canonicalizer.canonicalize k] = v}
            username = s['username']
            member = team[username] || team[@team_by_email[username]]
            next unless member

            s['name'] = member['name']
            s['full_name'] = member['full_name']
            s['version'] = version
            if version == 'v2'
              publish_snippet(s, published) unless @public_mode
            elsif version == 'v3'
              publish_v3_snippet(s, published)
            else
              published << s unless @public_mode
            end
          end
          result[timestamp] = published unless published.empty?
        end
      end

      site.data['snippets'] = result
      site.data[@source].delete 'snippets'
    end

    # Parses and publishes a snippet in v3 format. Filters out private
    # snippets and snippets rendered empty after redaction.
    # +snippet+:: snippet hash in v3 format
    # +published+:: array of snippets to publish
    def publish_v3_snippet(snippet, published)
      is_private = snippet['public'] != 'Public'
      return if @public_mode and is_private
      publish_snippet(snippet, published)
    end

    # Used to convert snippet headline markers to h4, since the layout uses
    # h3.
    HEADLINE = "\n####"

    # Parses and publishes a snippet. Filters out snippets rendered empty
    # after redaction.
    # +snippet+:: snippet hash with two fields: +last-week+ and +this-week+
    # +published+:: array of snippets to publish
    def publish_snippet(snippet, published)
      ['last-week', 'this-week'].each do |field|
        text = snippet[field] || ''
        redact! text

        parsed = []
        uses_item_markers = (text =~ /^[-*]/)

        text.each_line do |line|
          line.rstrip!
          # Convert headline markers.
          line.sub!(/^(#+)/, HEADLINE)
          line.sub!(/^::: (.*) :::$/, "#{HEADLINE} \\1") # For jtag. ;-)
          line.sub!(/^\*\*\*/, HEADLINE) # For elaine. ;-)

          # Add item markers for those who used plaintext and didn't add them;
          # add headline markers for those who defined different sections and
          # didn't add them.
          if line =~ /^([A-Za-z0-9])/
            unless uses_item_markers
              line = "- #{line}"
            else
              line = "#{HEADLINE} #{line}"
            end
          end

          # Fixup item markers missing a space.
          line.sub!(/^[-*]([^ ])/, '- \1')
          parsed << line unless line.empty?
        end
        snippet[field] = parsed.join("\n")
      end

      is_empty = snippet['last-week'].empty? && snippet['this-week'].empty?
      published << snippet unless is_empty
    end

    # Parses "{{" and "}}" redaction markers. For public snippets, will redact
    # everything between each set of markers. For internal snippets, will only
    # remove the markers.
    def redact!(text)
      if @public_mode
        text.gsub!(/\n?\{\{.*?\}\}/m,'')
      else
        text.gsub!(/(\{\{|\}\})/,'')
      end
    end

    # Joins project status information into +site.data[+'project_status'].
    def join_project_status
      unless @public_mode
        @data['project_status'] = @data[@source]['project_status']
      end
      @data[@source].delete 'project_status'
    end

    # Imports the guest_users list into the top-level site.data object.
    def import_guest_users
      private_data = site.data[@source] || {}
      hub_data = private_data['hub'] || {}
      if hub_data.member? 'guest_users'
        site.data['guest_users'] = site.data[@source]['hub']['guest_users']
        site.data[@source]['hub'].delete 'guest_users'
      end
    end

    # Filters out private pages when generating the public Hub.
    def filter_private_pages
      if @public_mode
        @site.pages.delete_if do |p|
          p.relative_path.start_with? '/pages/private'
        end
      end
    end
  end
end
