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

    # @param site [Jekyll::Site] Jekyll site object
    # @param page_dir [String] directory containing the generated page
    # @param filename [String] generated page file name
    # @param layout [String] Jekyll page layout for the generated page
    # @param title [String] page title
    def initialize(site, page_dir, filename, layout, title)
      @site = site
      @base = site.source
      @dir = page_dir
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

    # Generates a series of +Hub::Page+ objects for each item in
    # +site.data[+collection_name], where the collection is an +Array<Hash>,
    # and adds them to +site.pages+.
    #
    # @param site [Jekyll::Site] Jekyll site object
    # @param collection_name [String] key into site.data
    # @param item_name [String] identifies the item page layout using the
    #   format "#{item_name}.html" and the property used to access item data
    #   within the layout (i.e. +page.item_name+)
    # @param primary_key [String] hash key corresponding to the unique
    #   identifier within each item, i.e. item[primary_key]
    # @param title_key [String] hash key of the item field used to generate
    #   the page title, i.e. item[title_key]
    # @param collection_dir [String] if specified, the directory into which
    #   pages will be generated; otherwise +collection_name+ will be used as
    #   the directory name
    # @param [String] if specified, a format string containing a '%s' field
    #   used to generate page titles from item[title_key]; otherwise
    #   item[title_key] will be used to generate the title directly
    def self.generate_pages_from_array(site, collection_name, item_name,
      primary_key, title_key, collection_dir: nil, title_format: '%s')
      collection_dir = collection_name unless collection_dir
      collection = site.data[collection_name] || []
      collection.each do |item|
        item_id = Canonicalizer.canonicalize(item[primary_key])
        page = generate(site, File.join(collection_dir, item_id),
          'index.html', "#{item_name}.html", title_format % item[title_key])
        page.data[item_name] = item
      end
    end
  end
end
