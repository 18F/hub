require_relative "../_plugins/joiner"
require_relative "site"

require "minitest/autorun"

module Hub
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

end
