require_relative "../_plugins/snippets_publisher"

require "minitest/autorun"

module Snippets
  class PublisherPublishTest < ::Minitest::Test
    def setup
      @original = {}
      @expected = {}
    end

    def publisher(public_mode: false)
      Publisher.new(headline: "\n####", public_mode: public_mode)
    end

    def make_snippet(last_week, is_public: false)
      {
        'last-week' => last_week ? last_week.join("\n") : last_week,
        'this-week' => nil,
        'markdown' => true,
        'public' => is_public,
      }
    end

    def add_snippet(timestamp, snippet, expected: true)
      @original[timestamp] = [] unless @original.member? timestamp
      @original[timestamp] << snippet

      if expected
        @expected[timestamp] = [] unless @expected.member? timestamp
        @expected[timestamp] << snippet
      end
    end

    def test_empty_snippets
      assert_equal @expected, publisher.publish(@original)
    end

    def test_publish_all_snippets
      add_snippet('20141218', make_snippet(['- Did stuff']))
      add_snippet('20141225', make_snippet(['- Did stuff']))
      add_snippet('20141231', make_snippet(['- Did stuff']))
      add_snippet('20150107', make_snippet(['- Did stuff'], is_public: true))
      assert_equal @expected, publisher.publish(@original)
    end

    def test_publish_only_public_snippets_in_public_mode
      add_snippet('20141218', make_snippet(['- Did stuff']), expected: false)
      add_snippet('20141225', make_snippet(['- Did stuff']), expected: false)
      add_snippet('20141231', make_snippet(['- Did stuff']), expected: false)
      add_snippet('20150107', make_snippet(['- Did stuff'], is_public: true))
      assert_equal @expected, publisher(public_mode: true).publish(@original)
    end
  end
end
