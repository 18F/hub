# 18F Hub - Docs & connections between team members, projects, and skill sets
#
# Written in 2015 by Mike Bland (michael.bland@gsa.gov)
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
require_relative "temp_file_helper"

require "minitest/autorun"

module Hub
  class TempFileHelperTest < ::Minitest::Test
    def setup
      @relative_dir = File.join('temp_file_helper_test', 'testdir')
      @absolute_dir = File.join ENV['TEST_TMPDIR'], @relative_dir
      @helper = TempFileHelper.new
    end

    def test_directory_creation_and_removal
      refute File.exists? @absolute_dir

      assert_equal @absolute_dir, @helper.mkdir(@relative_dir)
      assert File.exists? @absolute_dir

      @helper.teardown
      refute File.exists? @absolute_dir
    end

    def test_file_creation_and_removal
      relative_path = File.join(@relative_dir, 'foo', 'bar')
      absolute_path = File.join(@absolute_dir, 'foo', 'bar')
      refute File.exists? absolute_path

      assert_equal(absolute_path,
        @helper.mkfile(relative_path, content: "baz\n"))
      assert File.exists? absolute_path
      assert_equal "baz\n", File.read(absolute_path)

      @helper.teardown
      refute File.exists? absolute_path
      refute File.exists? @absolute_dir
    end

    def test_multiple_creation_of_same_item_does_not_cause_teardown_error
      assert_equal @absolute_dir, @helper.mkdir(@relative_dir)
      assert_equal @absolute_dir, @helper.mkdir(@relative_dir)
      assert File.exists? @absolute_dir

      relative_path = File.join(@relative_dir, 'foo', 'bar')
      absolute_path = File.join(@absolute_dir, 'foo', 'bar')
      assert_equal(absolute_path,
        @helper.mkfile(relative_path, content: "baz\n"))
      assert_equal(absolute_path,
        @helper.mkfile(relative_path, content: "baz\n"))
      assert File.exists? absolute_path
      assert_equal "baz\n", File.read(absolute_path)

      @helper.teardown
      refute File.exists? absolute_path
      refute File.exists? @absolute_dir
    end
  end
end

