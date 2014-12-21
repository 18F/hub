require_relative "../_plugins/joiner"
require_relative "page"
require_relative "site"

require "jekyll"
require "jekyll/site"
require "minitest/autorun"

module Hub
  class SelectJoinSourceTest < ::Minitest::Test
    def setup
      @site = DummyTestSite.new
    end

    def test_select_private_source
      @site.data['private'] = 'has private data'
      impl = JoinerImpl.new @site
      assert_equal 'private', impl.source
    end

    def test_select_public_source
      @site.data.delete 'private'
      impl = JoinerImpl.new @site
      assert_equal 'public', impl.source
    end
  end

  class CreateTeamByEmailIndexTest < ::Minitest::Test
    def setup
      @site = DummyTestSite.new
      @team = []
      @site.data['private'] = {'team' => @team}
      @impl = JoinerImpl.new(@site)
    end

    def test_empty_team
      @impl.create_team_by_email_index
      assert_empty @impl.team_by_email
    end

    def test_single_user_index
      @team << {'name' => 'mbland', 'email' => 'michael.bland@gsa.gov'}
      @impl.create_team_by_email_index
      assert_equal({'michael.bland@gsa.gov' => 'mbland'}, @impl.team_by_email)
    end

    def test_single_user_with_private_email_index
      @team << {
        'name' => 'mbland', 'private' => {'email' => 'michael.bland@gsa.gov'},
      }
      @impl.create_team_by_email_index
      assert_equal({'michael.bland@gsa.gov' => 'mbland'}, @impl.team_by_email)
    end

    def test_single_private_user_index
      @team << {
        'private' => [
          {'name' => 'mbland', 'email' => 'michael.bland@gsa.gov'},
        ],
      }
      @impl.create_team_by_email_index
      assert_equal({'michael.bland@gsa.gov' => 'mbland'}, @impl.team_by_email)
    end

    def test_multiple_user_index
      @team << {'name' => 'mbland', 'email' => 'michael.bland@gsa.gov'}
      @team << {
        'name' => 'foobar', 'private' => {'email' => 'foo.bar@gsa.gov'},
      }
      @team << {
        'private' => [
          {'name' => 'bazquux', 'email' => 'baz.quux@gsa.gov'},
        ],
      }

      expected = {
        'michael.bland@gsa.gov' => 'mbland',
        'foo.bar@gsa.gov' => 'foobar',
        'baz.quux@gsa.gov' => 'bazquux',
      }
      @impl.create_team_by_email_index
      assert_equal expected, @impl.team_by_email
    end

    def test_ignore_users_without_email
      @team << {'name' => 'mbland'}
      @team << {'name' => 'foobar', 'private' => {}}
      @team << {'private' => [{'name' => 'bazquux'}]}

      @impl.create_team_by_email_index
      assert_empty @impl.team_by_email
    end
  end

  class JoinProjectDataTest < ::Minitest::Test
    def setup
      @site = DummyTestSite.new
      @site.data['private']['team'] = {}
      @site.data['private']['projects'] = [
        {'name' => 'MSB-USA', 'status' => 'Hold'}
      ]
    end

    def test_join_project
      @impl = JoinerImpl.new(@site)
      @impl.join_project_data
      assert_equal([{'name' => 'MSB-USA', 'status' => 'Hold'}],
        @site.data['projects'])
    end

    def test_hide_hold_projects_in_public_mode
      @site.config['public'] = true
      @impl = JoinerImpl.new(@site)
      @impl.join_project_data
      assert_empty @site.data['projects']
    end
  end

  class RedactionTest < ::Minitest::Test
    def setup
      @site = DummyTestSite.new
    end

    def test_empty_string
      text = ''
      JoinerImpl.new(@site).redact! text
      assert_empty text
      @site.config['public'] = true
      JoinerImpl.new(@site).redact! text
      assert_empty text
    end

    def test_unredacted_string
      text = 'Hello, World!'
      JoinerImpl.new(@site).redact! text
      assert_equal 'Hello, World!', text
      @site.config['public'] = true
      JoinerImpl.new(@site).redact! text
      assert_equal 'Hello, World!', text
    end

    def test_redacted_string_private_mode
      text = 'H{{ell}}o, Wor{{l}}d!'
      JoinerImpl.new(@site).redact! text
      assert_equal 'Hello, World!', text
    end

    def test_redacted_string_public_mode
      text = 'H{{ell}}o, Wor{{l}}d!'
      @site.config['public'] = true
      JoinerImpl.new(@site).redact! text
      assert_equal 'Ho, Word!', text
    end

    def test_multiline_redacted_string_private_mode
      text = "He{{llo,\nWor}}ld!"
      JoinerImpl.new(@site).redact! text
      assert_equal "Hello,\nWorld!", text
    end

    def test_multiline_redacted_string_public_mode
      text = "He{{llo,\nWor}}ld!"
      @site.config['public'] = true
      JoinerImpl.new(@site).redact! text
      assert_equal "Held!", text
    end
  end

  class PublishSnippetTest < ::Minitest::Test
    def setup
      @site = DummyTestSite.new
      @impl = JoinerImpl.new(@site)
    end

    def make_snippet(last_week, this_week)
      {'last-week' => last_week.join("\n"),
       'this-week' => this_week.join("\n"),
      }
    end

    def test_publish_nothing_if_snippet_hash_is_empty
      snippet = {}
      published = []
      @impl.publish_snippet snippet, published
      assert_empty published
    end

    def test_publish_nothing_if_snippet_fields_are_empty
      published = []
      @impl.publish_snippet make_snippet([], []), published
      assert_empty published
    end

    def test_last_week
      snippet = make_snippet ['- Did stuff'], []
      published = []
      @impl.publish_snippet snippet, published
      assert_equal [snippet], published
    end

    def test_this_week
      snippet = make_snippet [], ['- Will do stuff']
      published = []
      @impl.publish_snippet snippet, published
      assert_equal [snippet], published
    end

    def test_last_week_and_this_week
      snippet = make_snippet ['- Did stuff'], ['- Will do stuff']
      published = []
      @impl.publish_snippet snippet, published
      assert_equal [snippet], published
    end

    def test_fix_item_markers_missing_spaces
      snippet = make_snippet ['-Did stuff'], ['*Will do stuff']
      published = []
      @impl.publish_snippet snippet, published
      assert_equal [snippet], published
    end

    def test_compress_newlines
      snippet = make_snippet(
        ['- Did stuff', '', '- Did more stuff', ''],
        ['- Will do stuff', '', '- Will do more stuff', '']
      )
      published = []
      expected = [make_snippet(
        ['- Did stuff', '- Did more stuff'],
        ['- Will do stuff', '- Will do more stuff']
      )]
      @impl.publish_snippet snippet, published
      assert_equal expected, published
    end

    def test_add_item_markers_to_plaintext
      snippet = make_snippet(
        ['Did stuff', 'Did more stuff'],
        ['Will do stuff', 'Will do more stuff']
      )
      published = []
      expected = [make_snippet(
        ['- Did stuff', '- Did more stuff'],
        ['- Will do stuff', '- Will do more stuff']
      )]
      @impl.publish_snippet snippet, published
      assert_equal expected, published
    end

    def test_convert_headline_markers
      snippet = make_snippet(
        ['# Hub', '- Did Hub stuff'],
        ['# Hub', '- Will do more Hub stuff']
      )
      published = []
      expected = [make_snippet(
        ["#{JoinerImpl::HEADLINE} Hub", '- Did Hub stuff'],
        ["#{JoinerImpl::HEADLINE} Hub", '- Will do more Hub stuff']
      )]
      @impl.publish_snippet snippet, published
      assert_equal expected, published
    end

    def test_convert_jesse_style
      snippet = make_snippet ['::: Jesse style :::', 'Jesse did stuff'], []
      published = []
      expected = [make_snippet(
        ["#{JoinerImpl::HEADLINE} Jesse style", '- Jesse did stuff'], []
      )]
      @impl.publish_snippet snippet, published
      assert_equal expected, published
    end

    def test_convert_elaine_style
      snippet = make_snippet ['*** Elaine style', '-Elaine did stuff'], []
      published = []
      expected = [make_snippet(
        ["#{JoinerImpl::HEADLINE} Elaine style", '- Elaine did stuff'], []
      )]
      @impl.publish_snippet snippet, published
      assert_equal expected, published
    end

    def test_insert_headline_markers
      snippet = make_snippet(
        ['Hub', '- Did Hub stuff'],
        ['Hub', '- Will do more Hub stuff']
      )
      published = []
      expected = [make_snippet(
        ["#{JoinerImpl::HEADLINE} Hub", '- Did Hub stuff'],
        ["#{JoinerImpl::HEADLINE} Hub", '- Will do more Hub stuff']
      )]
      @impl.publish_snippet snippet, published
      assert_equal expected, published
    end

    def test_redaction_in_private_mode
      snippet = make_snippet(
        ['# Hub',
         '- Did{{ Hub}} stuff',
         '',
         '{{# Secret stuff',
         '- Did some secret stuff}}',
         '',
         '# Snippets',
         '{{- Did some redacted snippets}}',
         '- Did my snippets',
        ],
        ['# Hub', '- Will do more{{ Hub}} stuff']
      )
      published = []
      expected = [make_snippet(
        ["#{JoinerImpl::HEADLINE} Hub",
         '- Did Hub stuff',
         "#{JoinerImpl::HEADLINE} Secret stuff",
         '- Did some secret stuff',
         "#{JoinerImpl::HEADLINE} Snippets",
         '- Did some redacted snippets',
         '- Did my snippets',
         ],
        ["#{JoinerImpl::HEADLINE} Hub", '- Will do more Hub stuff']
      )]
      @impl.publish_snippet snippet, published
      assert_equal expected, published
    end

    def test_redaction_in_public_mode
      snippet = make_snippet(
        ['# Hub',
         '- Did{{ Hub}} stuff',
         '',
         '{{# Secret stuff',
         '- Did some secret stuff}}',
         '',
         '# Snippets',
         '{{- Did some redacted snippets}}',
         '- Did my snippets',
        ],
        ['# Hub', '- Will do more{{ Hub}} stuff']
      )
      published = []
      expected = [make_snippet(
        ["#{JoinerImpl::HEADLINE} Hub",
         '- Did stuff',
         "#{JoinerImpl::HEADLINE} Snippets",
         '- Did my snippets',
         ],
        ["#{JoinerImpl::HEADLINE} Hub", '- Will do more stuff']
      )]

      @site.config['public'] = true
      @impl = JoinerImpl.new(@site)
      @impl.publish_snippet snippet, published
      assert_equal expected, published
    end
  end

  class JoinSnippetDataTest < ::Minitest::Test
    def setup
      @site = DummyTestSite.new
      @site.data['private']['snippets'] = {'v1' => {}, 'v2' => {}, 'v3' => {}}
      @site.data['private']['team'] = []
      @impl = JoinerImpl.new(@site)
      @expected = {}
    end

    def set_team(team_list)
      @site.data['private']['team'] = team_list
      @impl.create_team_by_email_index
      @impl.join_private_data('team', 'name')
      @impl.convert_to_hash('team', 'name')
    end

    def add_snippet(version, timestamp, name, full_name,
      email, public_or_private, last_week, this_week, expected: true)
      snippets = @site.data['private']['snippets'][version]
      unless snippets.member? timestamp
        snippets[timestamp] = []
      end
      collection = snippets[timestamp]

      case version
      when "v1"
        collection << {
          'Timestamp' => timestamp,
          'Username' => email,
          'Name' => full_name,
          'Snippets' => last_week
        }
      when "v2"
        unless ['Private', ''].include? public_or_private
          raise Exception.new("Invalide public_or_private for v2: "+
            "#{public_or_private}")
        end
        collection << {
          'Timestamp' => timestamp,
          'Public vs. Private' => public_or_private,
          'Last Week' => last_week,
          'This Week' => this_week,
          'Username' => email,
        }
      when "v3"
        unless ['Public', ''].include? public_or_private
          raise Exception.new("Invalide public_or_private for v3: "+
            "#{public_or_private}")
        end
        collection << {
          'Timestamp' => timestamp,
          'Public' => public_or_private,
          'Username' => email,
          'Last week' => last_week,
          'This week' => this_week,
        }
      else
        raise Exception.new "Unknown version: #{version}"
      end

      if expected
        snippet = collection.last
        s = {}
        snippet.each {|k,v| s[Canonicalizer.canonicalize k] = v}
        s['name'] = name
        s['full_name'] = full_name
        s['version'] = version
        unless @expected.member? timestamp
          @expected[timestamp] = []
        end
        @expected[timestamp] << s
      end
    end

    def test_empty_snippet_data
      set_team([])
      @impl.join_snippet_data
      assert_empty @site.data['snippets']
      assert_nil @site.data['private']['snippets']
    end

    def test_publish_nothing_if_no_team
      set_team([])
      add_snippet('v1', '20141218', 'mbland', 'Mike Bland',
        'michael.bland@gsa.gov', 'unused', '- Did stuff', 'unused',
        expected:false)
      add_snippet('v2', '20141225', 'mbland', 'Mike Bland',
        'michael.bland@gsa.gov', '', '- Did stuff', '', expected:false)
      add_snippet('v3', '20141231', 'mbland', 'Mike Bland',
        'michael.bland@gsa.gov', 'Public', '- Did stuff', '', expected:false)
      @impl.join_snippet_data
      assert_empty @site.data['snippets']
      assert_nil @site.data['private']['snippets']
    end

    def test_publish_all_snippets_internally
      set_team([
        {'name' => 'mbland', 'full_name' => 'Mike Bland',
         'email' => 'michael.bland@gsa.gov'},
      ])
      add_snippet('v1', '20141218', 'mbland', 'Mike Bland',
        'michael.bland@gsa.gov', 'unused', '- Did stuff', 'unused')
      add_snippet('v2', '20141225', 'mbland', 'Mike Bland',
        'michael.bland@gsa.gov', '', '- Did stuff', '')
      add_snippet('v3', '20141231', 'mbland', 'Mike Bland',
        'michael.bland@gsa.gov', 'Public', '- Did stuff', '')
      @impl.join_snippet_data
      assert_equal @expected, @site.data['snippets']
      assert_nil @site.data['private']['snippets']
    end

    def test_publish_only_public_v3_snippets_in_public_mode
      @site.config['public'] = true
      @impl = JoinerImpl.new(@site)

      set_team([
        {'name' => 'mbland', 'full_name' => 'Mike Bland',
         'email' => 'michael.bland@gsa.gov'},
      ])
      add_snippet('v1', '20141218', 'mbland', 'Mike Bland',
        'michael.bland@gsa.gov', 'unused', '- Did stuff', 'unused',
        expected:false)
      add_snippet('v2', '20141225', 'mbland', 'Mike Bland',
        'michael.bland@gsa.gov', '', '- Did stuff', '', expected:false)
      add_snippet('v3', '20141231', 'mbland', 'Mike Bland',
        'michael.bland@gsa.gov', 'Public', '- Did stuff', '')
      add_snippet('v3', '20150107', 'mbland', 'Mike Bland',
        'michael.bland@gsa.gov', '', '- Did stuff', '', expected:false)

      @impl.join_snippet_data
      assert_equal @expected, @site.data['snippets']
      assert_nil @site.data['private']['snippets']
    end
  end

  class ImportGuestUsersTest < ::Minitest::Test
    def setup
      @site = DummyTestSite.new
      @site.data.delete 'private'
    end

    def test_no_private_data
      assert_nil JoinerImpl.new(@site).import_guest_users
    end

    def test_no_hub_data
      assert_nil JoinerImpl.new(@site).import_guest_users
      assert_nil @site.data['guest_users']
    end

    def test_no_guest_users
      @site.data['private'] = {'hub' => {}}
      assert_nil JoinerImpl.new(@site).import_guest_users
      assert_nil @site.data['guest_users']
    end

    def test_guest_users_moved_to_top_level
      guests = [
        {'email' => 'michael.bland@gsa.gov',
         'full_name' => 'Mike Bland'},
        ]
      @site.data['private'] = {'hub' => {'guest_users' => guests}}
      assert_equal guests, JoinerImpl.new(@site).import_guest_users
      assert_equal guests, @site.data['guest_users']
      assert_nil @site.data['private']['hub']['guest_users']
    end
  end

  class FilterPrivatePagesTest < ::Minitest::Test
    def setup
      @site = DummyTestSite.new
      @all_page_names = []
      @public_page_names = []
    end

    def add_public_page(filename)
      @site.pages << DummyTestPage.new(@site, '/pages', filename)
      @all_page_names << filename
      @public_page_names << filename
    end

    def add_private_page(filename)
      @site.pages << DummyTestPage.new(@site, '/pages/private', filename)
      @all_page_names << filename
    end

    def filter_pages_in_internal_mode
      @site.config.delete 'public'
      JoinerImpl.new(@site).filter_private_pages
    end

    def filter_pages_in_public_mode
      @site.config['public'] = true
      JoinerImpl.new(@site).filter_private_pages
    end

    def page_names
      @site.pages.map {|p| p.name}
    end

    def test_no_pages
      filter_pages_in_internal_mode
      assert_empty page_names
      filter_pages_in_public_mode
      assert_empty page_names
    end

    def test_single_public_page
      add_public_page 'public.html'
      filter_pages_in_internal_mode
      assert_equal(@all_page_names, page_names)
      filter_pages_in_public_mode
      assert_equal(@public_page_names, page_names)
    end

    def test_single_private_page
      add_private_page 'private.html'
      filter_pages_in_internal_mode
      assert_equal(@all_page_names, page_names)
      filter_pages_in_public_mode
      assert_empty page_names
    end

    def test_public_and_private_pages
      add_private_page 'private-0.html'
      add_public_page 'public-0.html'
      add_private_page 'private-1.html'
      add_public_page 'public-1.html'
      add_private_page 'private-2.html'
      filter_pages_in_internal_mode
      assert_equal(@all_page_names, page_names)
      filter_pages_in_public_mode
      assert_equal(@public_page_names, page_names)
    end
  end
end
