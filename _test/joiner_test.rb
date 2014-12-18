require_relative "../_plugins/joiner"
require_relative "page"

require "jekyll"
require "jekyll/site"
require "minitest/autorun"

module Hub
  class DeepMergeTest < ::Minitest::Test
    def test_raise_if_classes_differ
      assert_raises JoinerImpl::MergeError do
        JoinerImpl.deep_merge({}, [])
      end
    end

    def test_raise_if_not_mergeable
      assert_raises JoinerImpl::MergeError do
        JoinerImpl.deep_merge(true, false)
      end
    end

    def test_merge_into_empty_hash
      lhs = {}
      rhs = {:foo => true}
      JoinerImpl.deep_merge lhs, rhs
      assert_equal rhs, lhs
    end

    def test_merge_into_empty_array
      lhs = []
      rhs = [{:foo => true}]
      JoinerImpl.deep_merge lhs, rhs
      assert_equal rhs, lhs
    end

    def test_rhs_hash_overwrites_nonmergeable_lhs_hash_values
      lhs = {:foo => false}
      rhs = {:foo => true}
      JoinerImpl.deep_merge lhs, rhs
      assert_equal rhs, lhs
    end

    def test_rhs_appends_values_to_lhs
      lhs = [{:foo => false}]
      rhs = [{:foo => true}]
      JoinerImpl.deep_merge lhs, rhs
      assert_equal [{:foo => false}, {:foo => true}], lhs
    end

    def test_recursively_merge_hashes
      lhs = {
        'name' => 'mbland',
        'languages' => ['C++'],
        'age' => 'None of your business',
        'guitars' => {
          'strats' => 'too many',
          'acoustics' => 1,
          },
        }
      rhs = {
        'full_name' => 'Mike Bland',
        'languages' => ['Python', 'Ruby'],
        'age' => 'Not gonna say it',
        'guitars' => {
          'strats' => 'not enough',
          'les_pauls' => 1,
          },
        }
      JoinerImpl.deep_merge lhs, rhs

      expected = {
        'name' => 'mbland',
        'full_name' => 'Mike Bland',
        'languages' => ['C++', 'Python', 'Ruby'],
        'age' => 'Not gonna say it',
        'guitars' => {
          'strats' => 'not enough',
          'acoustics' => 1,
          'les_pauls' => 1,
          },
        }

      assert_equal expected, lhs
    end
  end

  class PromoteDataTest < ::Minitest::Test
    def test_ignore_if_not_a_collection
      assert_nil JoinerImpl.promote_data 27, 'private'
      assert_nil JoinerImpl.promote_data 'foobar', 'private'
      assert_nil JoinerImpl.promote_data :msb, 'private'
      assert_nil JoinerImpl.promote_data true, 'private'
    end

    def test_no_effect_on_empty_collections
      hash_data = {}
      JoinerImpl.promote_data hash_data, 'private'
      assert_empty hash_data

      array_data = []
      JoinerImpl.promote_data array_data, 'private'
      assert_empty array_data
    end

    def test_promote_private_hash_data
      data = {
        'name' => 'mbland',
        'private' => {'email' => 'michael.bland@gsa.gov'},
        'full_name' => 'Mike Bland',
      }

      expected = {
        'name' => 'mbland',
        'email' => 'michael.bland@gsa.gov',
        'full_name' => 'Mike Bland',
      }

      JoinerImpl.promote_data data, 'private'
      assert_equal expected, data
    end

    def test_promote_private_array_data
      data = [
        {'name' => 'mbland', 'full_name' => 'Mike Bland'},
        {'private' => [{'name' => 'foobar'}]},
      ]

      expected = [
        {'name' => 'mbland', 'full_name' => 'Mike Bland'},
        {'name' => 'foobar'},
      ]

      JoinerImpl.promote_data data, 'private'
      assert_equal expected, data
    end

    def test_promote_private_data_in_array_at_different_depths
      data =[
        {'name' => 'mbland',
         'full_name' => 'Michael S. Bland',
         'languages' => ['C++'],
         'private' => {
           'full_name' => 'Mike Bland',
           'email' => 'michael.bland@gsa.gov',
           'languages' => ['Python', 'Ruby'],
         },
        },
        {'private' => [
           {'name' => 'foobar',
            'full_name' => 'Foo Bar',
            'email' => 'foo.bar@gsa.gov',
           },
         ],
        },
      ]

      expected = [
        {'name' => 'mbland',
         'full_name' => 'Mike Bland',
         'email' => 'michael.bland@gsa.gov',
         'languages' => ['C++', 'Python', 'Ruby'],
        },
        {'name' => 'foobar',
         'full_name' => 'Foo Bar',
         'email' => 'foo.bar@gsa.gov',
        },
      ]

      JoinerImpl.promote_data data, 'private'
      assert_equal expected, data
    end

    def test_promote_private_data_in_hash_at_different_depths
      data = {
        'team' => [
          {'name' => 'mbland',
           'private' => {'email' => 'michael.bland@gsa.gov'}},
          {'private' => [
            {'name' => 'foobar', 'email' => 'foo.bar@gsa.gov'},
            ],
          },
        ],
        'projects' => [
          {'name' => 'hub', 'private' => {'repo' => '18F/hub'}},
          {'private' => [
            {'name' => 'snippets', 'repo' => '18F/hub'},
            ],
          },
        ],
      }

      expected = {
        'team' => [
          {'name' => 'mbland','email' => 'michael.bland@gsa.gov'},
          {'name' => 'foobar', 'email' => 'foo.bar@gsa.gov'},
        ],
        'projects' => [
          {'name' => 'hub', 'repo' => '18F/hub'},
          {'name' => 'snippets', 'repo' => '18F/hub'},
        ],
      }

      JoinerImpl.promote_data data, 'private'
      assert_equal expected, data
    end
  end

  class RemovePrivateDataTest < ::Minitest::Test
    def test_ignore_if_not_a_collection
      assert_nil JoinerImpl.remove_data 27, 'private'
      assert_nil JoinerImpl.remove_data 'foobar', 'private'
      assert_nil JoinerImpl.remove_data :msb, 'private'
      assert_nil JoinerImpl.remove_data true, 'private'
    end

    def test_ignore_empty_collections
      assert_equal({}, JoinerImpl.remove_data({}, 'private'))
      assert_equal([], JoinerImpl.remove_data([], 'private'))
    end

    def test_remove_top_level_private_data_from_hash
      assert_equal({'name' => 'mbland', 'full_name' => 'Mike Bland'},
        JoinerImpl.remove_data(
          {'name' => 'mbland', 'full_name' => 'Mike Bland',
           'private' => {'email' => 'michael.bland@gsa.gov'}}, 'private'))
    end

    def test_remove_top_level_private_data_from_array
      assert_equal([{'name' => 'mbland', 'full_name' => 'Mike Bland'}],
        JoinerImpl.remove_data(
          [{'name' => 'mbland', 'full_name' => 'Mike Bland'},
           {'private' => {'name' => 'foobar'}}], 'private'))
    end

    def test_remove_private_data_from_object_array_at_different_depths
      assert_equal([{'name' => 'mbland', 'full_name' => 'Mike Bland'}],
        JoinerImpl.remove_data(
          [{'name' => 'mbland', 'full_name' => 'Mike Bland',
            'private' => {'email' => 'michael.bland@gsa.gov'}},
           {'private' => [{'name' => 'foobar'}]}], 'private'))
    end
  end

  class JoinArrayDataTest < ::Minitest::Test
    def test_empty_arrays
      assert_empty JoinerImpl.join_array_data('unused', [], [])
    end

    def test_assert_raises_if_lhs_and_rhs_are_not_arrays
      assert_raises JoinerImpl::JoinError do
        assert_empty JoinerImpl.join_array_data('unused', [], {})
      end

      assert_raises JoinerImpl::JoinError do
        assert_empty JoinerImpl.join_array_data('unused', {}, [])
      end

      assert_raises JoinerImpl::JoinError do
        assert_empty JoinerImpl.join_array_data('unused', {}, {})
      end
    end

    def test_assert_raises_if_key_field_is_missing
      assert_raises JoinerImpl::JoinError do
        assert_empty JoinerImpl.join_array_data('key', [{'key'=>true}], [{}])
      end

      assert_raises JoinerImpl::JoinError do
        assert_empty JoinerImpl.join_array_data('key', [{}], [{'key'=>true}])
      end
    end

    def test_leave_lhs_alone_if_rhs_is_empty
      lhs = [{'key'=>true}]
      rhs = []
      JoinerImpl.join_array_data('key', lhs, rhs)
      assert_equal [{'key'=>true}], lhs
    end

    def test_lhs_matches_rhs_if_lhs_is_empty
      lhs = []
      rhs = [{'key'=>true}]
      JoinerImpl.join_array_data('key', lhs, rhs)
      assert_equal [{'key'=>true}], lhs
    end

    def test_join_single_item
      lhs = [
        {'name' => 'mbland',
         'full_name' => 'Mike Bland',
         'languages' => ['C++'],
        },
      ]
      rhs = [
        {'name' => 'mbland',
         'email' => 'michael.bland@gsa.gov',
         'languages' => ['Python', 'Ruby'],
        },
      ]
      expected = [
        {'name' => 'mbland',
         'full_name' => 'Mike Bland',
         'email' => 'michael.bland@gsa.gov',
         'languages' => ['C++', 'Python', 'Ruby'],
        },
      ]
      JoinerImpl.join_array_data('name', lhs, rhs)
      assert_equal expected, lhs
    end

    def test_join_multiple_items
      lhs = [
        {'name' => 'mbland',
         'full_name' => 'Mike Bland',
         'languages' => ['C++'],
        },
        {'name' => 'foobar',
         'full_name' => 'Foo Bar',
        },
      ]
      rhs = [
        {'name' => 'foobar',
         'email' => 'Foo.Bar@gsa.gov',
        },
        {'name' => 'mbland',
         'email' => 'michael.bland@gsa.gov',
         'languages' => ['Python', 'Ruby'],
        },
        {'name' => 'bazquux',
         'full_name' => 'Baz Quux',
         'email' => 'baz.quux@gsa.gov',
        },
      ]
      expected = [
        {'name' => 'mbland',
         'full_name' => 'Mike Bland',
         'email' => 'michael.bland@gsa.gov',
         'languages' => ['C++', 'Python', 'Ruby'],
        },
        {'name' => 'foobar',
         'full_name' => 'Foo Bar',
         'email' => 'Foo.Bar@gsa.gov',
        },
        {'name' => 'bazquux',
         'full_name' => 'Baz Quux',
         'email' => 'baz.quux@gsa.gov',
        },
      ]
      JoinerImpl.join_array_data('name', lhs, rhs)
      assert_equal expected, lhs
    end

  end

  class CreateTeamByEmailIndexTest < ::Minitest::Test
    def setup
      @site = ::Jekyll::Site.new ::Jekyll::Configuration::DEFAULTS
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

  class JoinDataTest < ::Minitest::Test
    def setup
      @site = ::Jekyll::Site.new ::Jekyll::Configuration::DEFAULTS
    end

    def test_ignore_if_rhs_empty
      lhs = {'team' => [{'name' => 'mbland'}]}
      rhs = {}
      JoinerImpl.join_data 'team', 'name', lhs, rhs
      assert_equal({'team' => [{'name' => 'mbland'}]}, lhs)
    end

    def test_assign_value_if_lhs_empty
      lhs = {}
      rhs = {'team' => [{'name' => 'mbland'}]}
      JoinerImpl.join_data 'team', 'name', lhs, rhs
      assert_equal rhs, lhs
    end

    def test_overwrite_nonmergeable_values
      lhs = {'team' => 'mbland'}
      rhs = {'team' => 'foobar'}
      JoinerImpl.join_data 'team', 'name', lhs, rhs
      assert_equal rhs, lhs
    end

    def test_join_hashes_via_deep_merge
      lhs = {'team' => {
        'mbland' => {'languages' => ['C++']},
        'foobar' => {'full_name' => 'Foo Bar'},
        },
      }

      rhs = {
        'team' => {
          'mbland' => {'languages' => ['Python', 'Ruby']},
          'foobar' => {'email' => 'foo.bar@gsa.gov'},
          'bazquux' => {'email' => 'baz.quux@gsa.gov'},
        },
      }

      expected = {
        'team' => {
          'mbland' => {'languages' => ['C++', 'Python', 'Ruby']},
          'foobar' => {
            'full_name' => 'Foo Bar', 'email' => 'foo.bar@gsa.gov'},
          'bazquux' => {'email' => 'baz.quux@gsa.gov'},
        },
      }

      JoinerImpl.join_data 'team', 'name', lhs, rhs
      assert_equal expected, lhs
    end

    def test_join_arrays_of_hashes
      lhs = {'team' => [
        {'name' => 'mbland', 'languages' => ['C++']},
        {'name' => 'foobar', 'full_name' => 'Foo Bar'},
        ],
      }
      rhs = {
        'team' => [
          {'name' => 'mbland', 'languages' => ['Python', 'Ruby']},
          {'name' => 'foobar', 'email' => 'foo.bar@gsa.gov'},
          {'name' => 'bazquux', 'email' => 'baz.quux@gsa.gov'},
        ],
      }
      expected = {
        'team' => [
          {'name' => 'mbland', 'languages' => ['C++', 'Python', 'Ruby']},
          {'name' => 'foobar', 'full_name' => 'Foo Bar',
           'email' => 'foo.bar@gsa.gov'},
          {'name' => 'bazquux', 'email' => 'baz.quux@gsa.gov'},
        ],
      }
      JoinerImpl.join_data 'team', 'name', lhs, rhs
      assert_equal expected, lhs
    end
  end

  class JoinProjectDataTest < ::Minitest::Test
    def setup
      @site = ::Jekyll::Site.new ::Jekyll::Configuration::DEFAULTS
      @site.data['private'] = {}
      @site.data['private']['projects'] = [
        {'name' => 'MSB-USA', 'status' => 'Hold'}
      ]
    end

    def test_join_project
      @impl = JoinerImpl.new(@site)
      @impl.join_project_data
      assert_equal(
        [{'name' => 'MSB-USA', 'status' => 'Hold', 'dashboard' => true}],
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
      @site = ::Jekyll::Site.new ::Jekyll::Configuration::DEFAULTS
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
      @site = ::Jekyll::Site.new ::Jekyll::Configuration::DEFAULTS
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
      @site = ::Jekyll::Site.new ::Jekyll::Configuration::DEFAULTS
      @site.data['private'] = {}
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
      @site = ::Jekyll::Site.new ::Jekyll::Configuration::DEFAULTS
    end

    def test_no_private_data
      assert_nil JoinerImpl.new(@site).import_guest_users
    end

    def test_no_hub_data
      @site.data['private'] = {}
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
      @site = ::Jekyll::Site.new ::Jekyll::Configuration::DEFAULTS
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
