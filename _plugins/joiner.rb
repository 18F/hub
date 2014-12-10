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
      impl.join_team_data
      impl.join_project_data

      impl.join_private_data('departments', 'name')
      impl.join_private_data('email_groups', 'name')
      impl.join_private_data('nav_links', 'name')
      impl.join_private_data('working_groups', 'name')

      impl.join_snippet_data
      impl.join_project_status
      impl.filter_private_pages

      site.data.delete 'public'
      site.data.delete 'private'
    end
  end

  # Implements Joiner operations.
  class JoinerImpl
    attr_reader :site, :data, :public_mode, :team_by_email

    # +site+:: Jekyll site data object
    def initialize(site)
      @site = site
      @data = site.data
      @public_mode = site.config['public']
      @team_by_email = {}
    end

    # Joins public and private team data, filters out non-18F PIFs, and builds
    # the +team_by_email+ index used to join snippet data.
    def join_team_data
      @data['team'].each {|i| i['18f'] = true}
      join_public_data('team', 'name')
      remove_team_members
      create_team_by_email_index
      join_private_data('team', 'name')
      convert_to_hash('team', 'name')
      assign_team_member_images
    end

    # Joins public and private project data.
    def join_project_data
      join_public_data('projects', 'name')

      # For now, we don't actually join in any private data from
      # site.data['private']['projects'].
      @data['projects'].each {|p| p['dashboard'] = true}
    end

    # Removes non-18F PIFs.
    def remove_team_members
      @data['team'].delete_if {|i| !i.member? '18f' or !i['18f']}
    end

    # Creates +self.team_by_email+, a hash of email address => username to use
    # as an index into +site.data[+'team'] when joining snippet data.
    def create_team_by_email_index
      @data['private']['team'].each do |i|
        @team_by_email[i['email']] = i['name'] if i.member? 'email'
      end
    end

    # Wrapper around join_data_from_source for public data.
    # +category+:: key into +site.data[+'public'] specifying data collection
    # +key_field+:: primary key for +site.data[+'public'][category] objects
    def join_public_data(category, key_field)
      if @data['public'].member? category
        join_data_from_source('public', category, key_field)
      end
    end

    # Wrapper around join_data_from_source for private data; will omit private
    # data entirely when running in public mode.
    # +category+:: key into +site.data[+'private'] specifying data collection
    # +key_field+:: primary key for +site.data[+'private'][category] objects
    def join_private_data(category, key_field)
      unless @public_mode or !@data['private'].member? category
        join_data_from_source('private', category, key_field)
      end
    end

    # Joins data from the +join_source+ subhash of +site.data+ (i.e. +public+
    # or +private+) so that appears directly within +site.data+. Deletes
    # site.data[join_source][category] when finished.
    #
    # Note: It's possible the current algorithm may need to be updated to
    # handle parallel bits of information contained in both public and private
    # data sources.
    #
    # +join_source+:: 'public' or 'private'
    # +category+:: key into site.data[join_source] specifying collection
    # +key_field+:: primary key for site.data[join_source][category] objects
    def join_data_from_source(join_source, category, key_field)
      unless @data.member? category
        @data[category] = @data[join_source][category]

      else
        joined_data = {}
        @data[category].each {|i| joined_data[i[key_field]] = i}

        @data[join_source][category].each do |v|
          k = v[key_field]
          if joined_data.member?(k)
            joined_data[k].merge!(v)
          else
            joined_data[k] = v
          end
        end
        @data[category] = joined_data.values

      end
      @data[join_source].delete category
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

      @data['private']['snippets'].each do |version, collection|
        collection.each do |timestamp, all_snippets|
          published = []
          all_snippets.each do |snippet|
            s = {}
            snippet.each {|k,v| s[Canonicalizer.canonicalize k] = v}
            member = team[@team_by_email[s['username']]]
            next unless member

            s['name'] = member['name']
            s['full_name'] = member['full_name']
            s['version'] = version
            if version == 'v2'
              publish_v2_snippet(s, published)
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
      site.data['private'].delete 'snippets'
    end

    # Parses and publishes a snippet in v2 format. Filters out private
    # snippets and snippets rendered empty after redaction.
    # +snippet+:: snippet hash in v2 format
    # +published+:: array of snippets to publish
    def publish_v2_snippet(snippet, published)
      is_private = snippet['public-vs.-private'] == 'Private'
      return if @public_mode and is_private
      publish_snippet(snippet, published)
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
    # +snippet+:: snippet hash
    # +published+:: array of snippets to publish
    def publish_snippet(snippet, published)
      ['last-week', 'this-week'].each do |field|
        text = snippet[field]
        next if text == nil
        redact! text
        text.gsub!(/^\n\n+/m, '')

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

      is_empty = snippet['last-week'].empty? and snippet['this-week'].empty?
      published << snippet unless is_empty
    end

    # Parses "{{" and "}}" redaction markers. For public snippets, will redact
    # everything between each set of markers. For internal snippets, will only
    # remove the markers.
    def redact!(text)
      if @public_mode
        text.gsub!(/\{\{.*?\}\}/m,'')
      else
        text.gsub!(/\{\{/,'')
        text.gsub!(/\}\}/,'')
      end
    end

    # Joins project status information into +site.data[+'project_status'].
    def join_project_status
      unless @public_mode
        @data['project_status'] = @data['private']['project_status']
      end
      @data['private'].delete 'project_status'
    end

    # Filters out private pages when generating the public Hub.
    def filter_private_pages
      return unless @public_mode
      @site.pages.delete_if {|p| p.relative_path.start_with? '/pages/private'}
    end
  end
end
