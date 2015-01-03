require_relative "../_plugins/joiner"
require_relative "site"

require "minitest/autorun"

module Hub
  class PublishSnippetTest < ::Minitest::Test
    def setup
      @site = DummyTestSite.new
      @impl = JoinerImpl.new(@site)
    end

    def make_snippet(last_week, this_week)
      {'last-week' => last_week ? last_week.join("\n") : last_week,
       'this-week' => this_week ? this_week.join("\n") : this_week,
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
      snippet = make_snippet ['::: Jesse style :::', 'Jesse did stuff'], nil
      published = []
      expected = [make_snippet(
        ["#{JoinerImpl::HEADLINE} Jesse style", '- Jesse did stuff'], nil
      )]
      @impl.publish_snippet snippet, published
      assert_equal expected, published
    end

    def test_convert_elaine_style
      snippet = make_snippet ['*** Elaine style', '-Elaine did stuff'], nil
      published = []
      expected = [make_snippet(
        ["#{JoinerImpl::HEADLINE} Elaine style", '- Elaine did stuff'], nil
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

end
