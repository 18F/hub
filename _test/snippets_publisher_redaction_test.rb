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
  class PublisherRedactionTest < ::Minitest::Test
    def publisher(public_mode: false)
      Publisher.new(headline: '', public_mode: public_mode)
    end

    def test_empty_string
      text = ''
      publisher.redact! text
      assert_empty text
      publisher(public_mode: true).redact! text
      assert_empty text
    end

    def test_unredacted_string
      text = 'Hello, World!'
      publisher.redact! text
      assert_equal 'Hello, World!', text
      publisher(public_mode: true).redact! text
      assert_equal 'Hello, World!', text
    end

    def test_redacted_string_private_mode
      text = 'H{{ell}}o, Wor{{l}}d!'
      publisher.redact! text
      assert_equal 'Hello, World!', text
    end

    def test_redacted_string_public_mode
      text = 'H{{ell}}o, Wor{{l}}d!'
      publisher(public_mode: true).redact! text
      assert_equal 'Ho, Word!', text
    end

    def test_multiline_redacted_string_private_mode
      text = [
        '- Did stuff{{ including private details}}',
        '{{- Did secret stuff}}',
        '- Did more stuff',
        '{{- Did more secret stuff',
        '- Yet more secret stuff}}',
      ].join('\n')
      expected = [
        '- Did stuff including private details',
        '- Did secret stuff',
        '- Did more stuff',
        '- Did more secret stuff',
        '- Yet more secret stuff',
      ].join('\n')
      publisher.redact! text
      assert_equal expected, text
    end

    def test_multiline_redacted_string_public_mode
      text = [
        '- Did stuff{{ including private details}}',
        '{{- Did secret stuff}}',
        '- Did more stuff',
        '{{- Did more secret stuff',
        '- Yet more secret stuff}}',
      ].join("\n")
      expected = [
        '- Did stuff',
        '- Did more stuff',
      ].join("\n")
      publisher(public_mode: true).redact! text
      assert_equal expected, text
    end
  end
end
