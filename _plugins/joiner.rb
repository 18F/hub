require 'hash-joiner'
require_relative 'snippets_version'

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

      impl.join_snippet_data SNIPPET_VERSIONS
      impl.join_project_status
      impl.import_guest_users
      impl.filter_private_pages

      site.data.delete 'public'
      site.data.delete 'private'
    end

    # Used to standardize snippet data of different versions before joining
    # and publishing.
    SNIPPET_VERSIONS = {
      'v1' => Snippets::Version.new(
        version_name:'v1',
        field_map:{
          'Username' => 'username',
          'Timestamp' => 'timestamp',
          'Name' => 'full_name',
          'Snippets' => 'last-week',
          'No This Week' => 'this-week',
        }
      ),
      'v2' => Snippets::Version.new(
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
      'v3' => Snippets::Version.new(
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

    # Raised by +join_snippet_data+ if the snippet version is unknown.
    class SnippetVersionError < ::Exception
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
    # and +'version'+ is a property of each +Hash+ in the +Array<Hash>+
    # containing snippet data.
    #
    # @raise [SnippetVersionError] if any snippets correspond to versions not
    #   in +snippet_versions+
    def join_snippet_data(snippet_versions)
      result = {}
      team = @data['team']

      @data[@source]['snippets'].each do |version, collection|
        snippet_version = snippet_versions[version]
        unless snippet_version
          raise SnippetVersionError.new("Unknown snippet version: #{version}")
        end
        collection.each do |timestamp, all_snippets|
          joined = []
          all_snippets.each do |snippet|
            snippet_version.standardize snippet
            username = snippet['username']
            member = team[username] || team[@team_by_email[username]]

            if member
              snippet['name'] = member['name']
              snippet['full_name'] = member['full_name']
              joined << snippet
            end
          end
          result[timestamp] = joined unless joined.empty?
        end
      end
      site.data['snippets'] = result
      site.data[@source].delete 'snippets'
      publish_snippet_data
    end

    # Processes +site.data[+'snippets'] entries for publication. Any snippets
    # that should not appear when in +public_mode+ are removed from
    # +site.data[+'snippets'].
    def publish_snippet_data
      result = {}
      @data['snippets'].each do |timestamp, all_snippets|
        published = []
        all_snippets.each do |snippet|
          unless @public_mode and !snippet['public']
            publish_snippet(snippet, published)
          end
        end
        result[timestamp] = published unless published.empty?
      end
      site.data['snippets'] = result
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
        # TODO(mbland): Hoist these team member-specific hacks out
        text.gsub!(/^::: (.*) :::$/, "#{HEADLINE} \\1") # For jtag. ;-)
        text.gsub!(/^\*\*\*/, HEADLINE) # For elaine. ;-)
        redact! text

        parsed = []
        uses_item_markers = (text =~ /^[-*]/)

        text.each_line do |line|
          line.rstrip!
          # Convert headline markers.
          line.sub!(/^(#+)/, HEADLINE)

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
        snippet[field] = parsed.empty? ? nil : parsed.join("\n")
      end

      is_empty = (snippet['last-week'] || '').empty? && (
        snippet['this-week'] || '').empty?
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
