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

module Hub
  class TempFileHelper
    def initialize(tmpdir: nil)
      @tmpdir = tmpdir || ENV['TEST_TMPDIR']
      @files = []
      @dirs = []
    end

    # Creates a temporary test directory relative to TEST_TMPDIR.
    # @param relative_path [String] directory to create
    # @return [String] File.join(@tmpdir, relative_path)
    def mkdir(relative_path)
      components = relative_path.split(File::SEPARATOR)
      components = components.delete_if {|i| i == '.'}
      current = @tmpdir
      until components.empty?
        current = File.join current, components.shift
        Dir.mkdir current unless File.exists? current
        @dirs << current
      end
      @dirs.last 
    end

    # Creates a temporary file relative to TEST_TMPDIR.
    # @param relative_path [String] file to create
    # @param content [String] (optional) content to include in the file
    # @return [String] File.join(@tmpdir, relative_path)
    def mkfile(relative_path, content: '')
      mkdir File.dirname(relative_path)
      filename = File.join(@tmpdir, relative_path)
      File.open(filename, 'w') {|f| f << content}
      @files << filename
      filename
    end

    def teardown
      @files.sort.uniq.each {|f| File.unlink f}
      @dirs.sort.uniq.reverse.each {|d| Dir.rmdir d}
    end
  end
end
