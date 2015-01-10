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

module Hub
  # Hub-specfic Page object that standardizes how pages are generated.
  #
  # This Page object allows us to create target pages on the fly using
  # ::Jekyll::Generator plugins. Just creating factory functions that invoke
  # ::Jekyll::Page.new cause initialization failures, as
  # ::Jekyll::Page::initialize will try to open the page specified by
  # File.join(base, dir, filename) directly. 
  class Page < ::Jekyll::Page
    private_class_method :new

    def initialize(site, dir, filename, layout, title)
      @site = site
      @base = site.source
      @dir = dir
      @name = filename

      self.process(filename)
      self.read_yaml(File.join(site.source, '_layouts'), layout)
      self.data['title'] = "#{title} - 18F Hub"
    end

    # Creates a +Hub::Page+ object and adds it to +site.pages+.
    #
    # @param site [Jekyll::Site] Jekyll site object
    # @param page_dir [String] directory containing the generated page
    # @param filename [String] generated page file name
    # @param layout [String] Jekyll page layout for the generated page
    # @param title [String] page title
    # @return [Hub::Page]
    def self.generate(site, page_dir, filename, layout, title)
      page = new(site, page_dir, filename, layout, title)
      site.pages << page
      page
    end
  end
end
