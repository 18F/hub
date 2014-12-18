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
      impl.import_guest_users
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
      create_team_by_email_index
      join_private_data('team', 'name')
      convert_to_hash('team', 'name')
      assign_team_member_images
    end

    # Recursively removes data from +collection+ matching +key+.
    #
    # +collection+:: Hash or Array from which to strip information
    # +key+:: key determining data to be stripped from +collection+
    def self.remove_data(collection, key)
      if collection.instance_of? ::Hash
        collection.delete key if collection.member? key
        collection.each_value {|i| remove_data i, key}
      elsif collection.instance_of? ::Array
        collection.each {|i| remove_data i, key}
        collection.delete_if {|i| i.empty?}
      end
    end

    # Raised by deep_merge() if lhs and rhs are of different types.
    class MergeError < ::Exception
    end

    # Performs a deep merge of Hash and Array structures. If the collections
    # are Hashes, Hash or Array members of +rhs+ will be deep-merged with
    # any existing members in +lhs+. If the collections are Arrays, the values
    # from +rhs+ will be appended to lhs.
    #
    # Raises MergeError if lhs and rhs are of different classes, or if they
    # are of classes other than Hash or Array.
    #
    # +lhs+:: merged data sink (left-hand side)
    # +rhs+:: merged data source (right-hand side)
    def self.deep_merge(lhs, rhs)
      mergeable_classes = [::Hash, ::Array]

      if lhs.class != rhs.class
        raise MergeError.new("LHS (#{lhs.class}): #{lhs}\n" +
          "RHS (#{rhs.class}): #{rhs}")
      elsif !mergeable_classes.include? lhs.class
        raise MergeError.new "Class not mergeable: #{lhs.class}"
      end

      if rhs.instance_of? ::Hash
        rhs.each do |key,value|
          if lhs.member? key and mergeable_classes.include? value.class
            deep_merge(lhs[key], value)
          else
            lhs[key] = value
          end
        end

      elsif rhs.instance_of? ::Array
        lhs.concat rhs
      end
    end

    # Recursively promotes data within the +collection+ matching +key+ to the
    # same level as +key+ itself. After promotion, each +key+ reference will
    # be deleted.
    #
    # +collection+:: Hash or Array from which to promote information
    # +key+:: key determining data to be promoted within +collection+
    def self.promote_data(collection, key)
      if collection.instance_of? ::Hash
        if collection.member? key
          data_to_promote = collection[key]
          collection.delete key
          deep_merge collection, data_to_promote
        end
        collection.each_value {|i| promote_data i, key}

      elsif collection.instance_of? ::Array
        collection.each do |i|
          # If the Array entry is a hash that contains only the target key,
          # then that key should map to an Array to be promoted.
          if i.instance_of? ::Hash and i.keys == [key]
            data_to_promote = i[key]
            i.delete key
            deep_merge collection, data_to_promote
          else
            promote_data i, key
          end
        end

        collection.delete_if {|i| i.empty?}
      end
    end

    # Raised by join_data() if an error is encountered.
    class JoinError < ::Exception
    end

    # Joins objects in +lhs[category]+ with data from +rhs[category]+. If the
    # object collections are of type Array of Hash, key_field will be used as
    # the primary key; otherwise key_field is ignored.
    #
    # Raises JoinError if an error is encountered.
    #
    # +category+:: determines member of +lhs+ to join with +rhs+
    # +key_field+:: if specified, primary key for Array of joined objects
    # +lhs+:: joined data sink of type Hash (left-hand side)
    # +rhs+:: joined data source of type Hash (right-hand side)
    def self.join_data(category, key_field, lhs, rhs)
      rhs_data = rhs[category]
      return unless rhs_data

      lhs_data = lhs[category]
      if !(lhs_data and [::Hash, ::Array].include? lhs_data.class)
        lhs[category] = rhs_data
      elsif lhs_data.instance_of? ::Hash
        self.deep_merge lhs_data, rhs_data
      else
        self.join_array_data key_field, lhs_data, rhs_data
      end
    end

    # Raises JoinError if +h+ is not a Hash, or if
    # +key_field+ is absent from any element of +lhs+ or +rhs+.
    def self.assert_is_hash_with_key(h, key, error_prefix)
      if !h.instance_of? ::Hash
        raise JoinError.new("#{error_prefix} is not a Hash: #{h}")
      elsif !h.member? key
        raise JoinError.new("#{error_prefix} missing \"#{key}\": #{h}")
      end
    end

    # Joins data in the +lhs+ Array with data from the +rhs+ Array based on
    # +key_field+. Both +lhs+ and +rhs+ should be of type Array of Hash.
    # Performs a deep_merge on matching objects; assigns values from +rhs+ to
    # +lhs+ if no corresponding object yet exists in lhs.
    #
    # Raises JoinError if either lhs or rhs is not an Array of Hash, or if
    # +key_field+ is absent from any element of +lhs+ or +rhs+.
    #
    # +key_field+:: primary key for joined objects
    # +lhs+:: joined data sink (left-hand side)
    # +rhs+:: joined data source (right-hand side)
    def self.join_array_data(key_field, lhs, rhs)
      unless lhs.instance_of? ::Array and rhs.instance_of? ::Array
        raise JoinError.new("Both lhs (#{lhs.class}) and " +
          "rhs (#{rhs.class}) must be an Array of Hash")
      end

      lhs_index = {}
      lhs.each do |i|
        self.assert_is_hash_with_key(i, key_field, "LHS element")
        lhs_index[i[key_field]] = i
      end

      rhs.each do |i|
        self.assert_is_hash_with_key(i, key_field, "RHS element")
        key = i[key_field]
        if lhs_index.member? key
          deep_merge lhs_index[key], i
        else
          lhs << i
        end
      end
    end

    # Joins public and private project data.
    def join_project_data
      join_private_data('projects', 'name')

      # For now, we don't actually join in any private data from
      # site.data['private']['projects'].
      @data['projects'].each {|p| p['dashboard'] = true}
    end

    # Creates +self.team_by_email+, a hash of email address => username to use
    # as an index into +site.data[+'team'] when joining snippet data.
    #
    # MUST be called before remove_data, or else private email addresses will
    # be inaccessible and snippets will not be joined.
    def create_team_by_email_index
      team = @data['private']['team']
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

    # Joins data from +site.data[+'private'] into +site.data+.
    # +category+:: key into +site.data[+'private'] specifying data collection
    # +key_field+:: if specified, primary key for Array of joined objects
    def join_private_data(category, key_field)
      JoinerImpl.join_data category, key_field, @data, @data['private']
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

    # Imports the guest_users list into the top-level site.data object.
    def import_guest_users
      private_data = site.data['private'] || {}
      hub_data = private_data['hub'] || {}
      if hub_data.member? 'guest_users'
        site.data['guest_users'] = site.data['private']['hub']['guest_users']
        site.data['private']['hub'].delete 'guest_users'
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
