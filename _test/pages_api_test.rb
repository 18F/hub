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
require_relative 'site_builder'

require 'minitest/autorun'

module Hub
  class PagesApiTest < ::Minitest::Test
    PATH = File.join(SiteBuilder::BUILD_DIR, 'api', 'v1', 'pages.json')

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

    def homepage_body
      homepage_data['body']
    end

    def posts_with_empty_titles
      entries_data.select { |hash| hash['title'] == '' }
    end

    def posts_with_title_called_untitled
      entries_data.select { |hash| hash['title'] == 'Untitled' }
    end

    def test_files_exist
      assert(File.exist?(PATH), "JSON file doesn't exist.")
    end

    def test_inserts_content
      assert_includes(homepage_body, 'The Hub is getting a new look')
    end

    def test_all_posts_have_titles
      assert_empty posts_with_empty_titles.map { |hash| hash['url'] }
    end

    def test_no_posts_are_untitled
      assert_empty posts_with_title_called_untitled.map { |hash| hash['url'] }
    end
  end
end
