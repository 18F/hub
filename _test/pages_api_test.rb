# 18F Hub - Docs & connections between team members, projects, and skill sets
#
# Written in 2015 by Aidan Feldman (aidan.feldman@gsa.gov)
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
# @author Aidan Feldman (aidan.feldman@gsa.gov)

require_relative 'test_helper'

require 'minitest/autorun'

module Hub
  class PagesApiTest < ::Minitest::Test
    # before all
    # TODO isolate the tests better
    `bundle exec jekyll build --destination _test/tmp`
    PATH = File.join(Dir.pwd, '_test', 'tmp', 'api', 'pages.json')

    def read_json(path)
      contents = File.read(path)
      JSON.parse(contents)
    end

    def entries_data
      json = read_json(PATH)
      json['entries']
    end

    def homepage_data
      entries_data.find{|page| page['url'] == '/' }
    end

    def test_files_exist
      assert(File.exist?(PATH), "JSON file doesn't exist.")
    end

    def test_properties
      assert_includes(homepage_data['body'], 'Snippets')
    end

    def test_inserts_content
      assert_includes(homepage_data['body'], 'Team information')
    end

    def test_removes_liquid_tags
      entries_data.each do |page|
        refute_includes(page['body'], '{%')
      end
    end
  end
end
