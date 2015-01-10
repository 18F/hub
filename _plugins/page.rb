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

require_relative "canonicalizer"

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
      title_format = site.config['generated_page_title_format'] || '%s'
      self.data['title'] = title_format % title
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
    # +site.data[+collection_name], where the collection is a
    # +Hash<String, Hash>+ or an +Array<Hash>, and adds them to +site.pages+.
    #
    # @param site [Jekyll::Site] Jekyll site object
    # @param collection_name [String] key into site.data
    # @param item_name [String] identifies the item page layout using the
    #   format "#{item_name}.html" and the property used to access item data
    #   within the layout (i.e. +page.item_name+)
    # @param title_key [String] hash key of the item field used to generate
    #   the page title, i.e. item[title_key]
    # @param primary_key [String] hash key corresponding to the unique
    #   identifier within each item, i.e. item[primary_key]; required if the
    #   collection is an Array
    # @param collection_dir [String] if specified, the directory into which
    #   pages will be generated; otherwise +collection_name+ will be used as
    #   the directory name
    # @param [String] if specified, a format string containing a '%s' field
    #   used to generate page titles from item[title_key]; otherwise
    #   item[title_key] will be used to generate the title directly
    def self.generate_collection_item_pages(site, collection_name, item_name,
      title_key, primary_key: nil, collection_dir: nil, title_format: '%s')
      collection_dir = collection_name unless collection_dir
      get_collection(site, collection_name, primary_key).each do |id, item|
        page = generate(site, File.join(collection_dir, id),
          'index.html', "#{item_name}.html", title_format % item[title_key])
        page.data[item_name] = item
      end
    end

    # Raised by +get_collection+ if +site.data[+collection_name] is of the
    # wrong type.
    class CollectionTypeError < ::Exception
    end

    # Retrieves site.data[collection_name]. Converts an Array<Hash> into a
    # Hash, and returns the empty hash if site.data[collection_name] does not
    # exist.
    #
    # @param site [Jekyll::Site] Jekyll site object
    # @param collection_name [String] key into site.data
    # @param primary_key [String] hash key corresponding to the unique
    #   identifier within each item, i.e. item[primary_key]; required if the
    #   collection is an Array
    # @return [Hash] a hash from item ID => item
    # @raise [CollectionTypeError] if site.data[collection_name] isn't a Hash
    #   or an Array
    def self.get_collection(site, collection_name, primary_key)
      collection = site.data[collection_name] || {}

      if collection.instance_of? ::Hash
        collection
      elsif collection.instance_of? ::Array
        collection_hash = {}
        collection.each do |item|
          id = Canonicalizer.canonicalize(item[primary_key])
          collection_hash[id] = item
        end
        collection_hash
      else
        raise CollectionTypeError.new("site.data[#{collection_name}] " +
          "should be a Hash<String, Hash> or an Array<Hash>, " +
          "but is of type #{collection.class}")
      end
    end
  end
end
