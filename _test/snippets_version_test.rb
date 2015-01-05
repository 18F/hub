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
require_relative "../_plugins/snippets_version"

require "minitest/autorun"

module Snippets
  class VersionTest < ::Minitest::Test
    def test_raises_if_required_field_mapping_missing
      error = assert_raises Version::InitError do
        Version.new(
          version_name:'v1',
          field_map:{'Username' => 'username', 'Timestamp' => 'timestamp'})
      end
      assert_equal(
        'Snippet version "v1" missing mappings for fields: ' +
          '["last-week", "this-week"]',
        error.to_s)
    end

    def test_raises_if_public_field_is_set_but_public_value_is_not
      error = assert_raises Version::InitError do
        Version.new(
          version_name:'v3',
          field_map:{
            'Timestamp' => 'timestamp',
            'Public' => 'public',
            'Username' => 'username',
            'Last week' => 'last-week',
            'This week' => 'this-week',
          },
          public_field: 'public'
      )
      end
      assert_equal(
        'Snippet version "v3" has public_field and public_value mismatched: ' +
          'public_field == "public"; public_value == nil',
        error.to_s)
    end

    def test_raises_if_public_field_is_not_set_but_public_value_is
      error = assert_raises Snippets::Version::InitError do
        Version.new(
          version_name:'v3',
          field_map:{
            'Timestamp' => 'timestamp',
            'Public' => 'public',
            'Username' => 'username',
            'Last week' => 'last-week',
            'This week' => 'this-week',
          },
          public_value: 'Public'
      )
      end
      assert_equal(
        'Snippet version "v3" has public_field and public_value mismatched: ' +
          'public_field == nil; public_value == "Public"',
        error.to_s)
    end

    def test_raise_if_snippet_contains_unrecognized_fields_not_in_field_map
      version = Version.new(
        version_name:'v1',
        field_map:{
          'Username' => 'username',
          'Timestamp' => 'timestamp',
          'Name' => 'full_name',
          'Snippets' => 'last-week',
          'No This Week' => 'this-week',
        }
      )
      error = assert_raises Version::UnknownFieldError do
        version.standardize({'Public' => ''})
      end
      assert_equal('Snippet field not recognized by version "v1": Public',
        error.to_s)
    end

    def test_standardize_private_snippet_no_markdown
      version = Version.new(
        version_name:'v1',
        field_map:{
          'Username' => 'username',
          'Timestamp' => 'timestamp',
          'Name' => 'full_name',
          'Snippets' => 'last-week',
          'No This Week' => 'this-week',
        }
      )
      snippet = {
        'Username' => 'mbland',
        'Timestamp' => '2014-12-31',
        'Name' => 'Mike Bland',
        'Snippets' => '- Did stuff',
      }
      expected = {
        'username' => 'mbland',
        'timestamp' => '2014-12-31',
        'full_name' => 'Mike Bland',
        'last-week' => '- Did stuff',
        'public' => false,
        'markdown' => false
      }
      assert_equal expected, version.standardize(snippet)
    end

    def test_standardize_public_snippet_with_markdown
      version = Version.new(
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
        markdown_supported: true,
      )
      snippet = {
        'Timestamp' => '2014-12-31',
        'Public' => 'Public',
        'Username' => 'mbland',
        'Last week' => '- Did stuff',
        'This week' => '- Do more stuff',
      }
      expected = {
        'timestamp' => '2014-12-31',
        'public' => true,
        'username' => 'mbland',
        'last-week' => '- Did stuff',
        'this-week' => '- Do more stuff',
        'markdown' => true
      }
      assert_equal expected, version.standardize(snippet)
    end
  end
end
