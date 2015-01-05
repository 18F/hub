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

require_relative "test_helper"
require_relative "../_plugins/snippets_publisher"

require "minitest/autorun"

module Snippets
  class PublishSnippetTest < ::Minitest::Test
    HEADLINE = "\n####"

    MARKDOWN_SNIPPET_MUNGER = Proc.new do |text|
      text.gsub!(/^::: (.*) :::$/, "#{HEADLINE} \\1")
    end

    def publisher(public_mode: false)
      Publisher.new(headline: HEADLINE, public_mode: public_mode,
        markdown_snippet_munger: MARKDOWN_SNIPPET_MUNGER)
    end

    def make_snippet(last_week, this_week, markdown: true)
      {'last-week' => last_week ? last_week.join("\n") : last_week,
       'this-week' => this_week ? this_week.join("\n") : this_week,
       'markdown' => markdown,
      }
    end

    def test_publish_nothing_if_snippet_hash_is_empty
      snippet = {}
      published = []
      publisher.publish_snippet snippet, published
      assert_empty published
    end

    def test_publish_nothing_if_snippet_fields_are_empty
      published = []
      publisher.publish_snippet make_snippet([], []), published
      assert_empty published
    end

    def test_publish_as_is_if_markdown_not_supported
      snippet = make_snippet(
        ['Last week:', '- Did Hub stuff',
         'This week:', '- Will do more Hub stuff'],
        nil,
        markdown: false
      )
      published = []
      publisher.publish_snippet snippet, published
      assert_equal [snippet], published
    end

    def test_last_week
      snippet = make_snippet ['- Did stuff'], []
      published = []
      publisher.publish_snippet snippet, published
      assert_equal [snippet], published
    end

    def test_this_week
      snippet = make_snippet [], ['- Will do stuff']
      published = []
      publisher.publish_snippet snippet, published
      assert_equal [snippet], published
    end

    def test_last_week_and_this_week
      snippet = make_snippet ['- Did stuff'], ['- Will do stuff']
      published = []
      publisher.publish_snippet snippet, published
      assert_equal [snippet], published
    end

    def test_fix_item_markers_missing_spaces
      snippet = make_snippet ['-Did stuff'], ['*Will do stuff']
      published = []
      publisher.publish_snippet snippet, published
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
      publisher.publish_snippet snippet, published
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
      publisher.publish_snippet snippet, published
      assert_equal expected, published
    end

    def test_convert_headline_markers
      snippet = make_snippet(
        ['# Hub', '- Did Hub stuff'],
        ['# Hub', '- Will do more Hub stuff']
      )
      published = []
      expected = [make_snippet(
        ["#{HEADLINE} Hub", '- Did Hub stuff'],
        ["#{HEADLINE} Hub", '- Will do more Hub stuff']
      )]
      publisher.publish_snippet snippet, published
      assert_equal expected, published
    end

    def test_markdown_snippet_munger_not_called_if_markdown_not_supported
      snippet = make_snippet(
        ['::: Jesse style :::', 'Jesse did stuff'], nil, markdown: false)
      published = []
      expected = [make_snippet(
        ['::: Jesse style :::', 'Jesse did stuff'], nil, markdown: false
      )]
      publisher.publish_snippet snippet, published
      assert_equal expected, published
    end

    def test_markdown_snippet_munger
      snippet = make_snippet ['::: Jesse style :::', 'Jesse did stuff'], nil
      published = []
      expected = [make_snippet(
        ["#{HEADLINE} Jesse style", '- Jesse did stuff'], nil
      )]
      publisher.publish_snippet snippet, published
      assert_equal expected, published
    end

    def test_insert_headline_markers
      snippet = make_snippet(
        ['Hub', '- Did Hub stuff'],
        ['Hub', '- Will do more Hub stuff']
      )
      published = []
      expected = [make_snippet(
        ["#{HEADLINE} Hub", '- Did Hub stuff'],
        ["#{HEADLINE} Hub", '- Will do more Hub stuff']
      )]
      publisher.publish_snippet snippet, published
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
        ["#{HEADLINE} Hub",
         '- Did Hub stuff',
         "#{HEADLINE} Secret stuff",
         '- Did some secret stuff',
         "#{HEADLINE} Snippets",
         '- Did some redacted snippets',
         '- Did my snippets',
         ],
        ["#{HEADLINE} Hub", '- Will do more Hub stuff']
      )]
      publisher.publish_snippet snippet, published
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
        ["#{HEADLINE} Hub",
         '- Did stuff',
         "#{HEADLINE} Snippets",
         '- Did my snippets',
         ],
        ["#{HEADLINE} Hub", '- Will do more stuff']
      )]
      publisher(public_mode: true).publish_snippet snippet, published
      assert_equal expected, published
    end
  end
end
