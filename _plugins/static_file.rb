require 'jekyll/static_file'
require 'jekyll/url'

module Jekyll
  # Reopens the class to provide new implementations of :destination_rel_dir,
  # and :write?, making it collection- and defaults-aware.
  class StaticFile
    # Allows the StaticFile to be written to the same output directory as all
    # the Jekyll::Documents in the same collection.
    old_desination_rel_dir = instance_method :destination_rel_dir
    define_method :destination_rel_dir do
      @collection.nil? ? @dir : File.dirname(self.url)
    end

    # Allows the StaticFile to be hidden from the output directory based on
    # the defaults for the destination path as defined in _config.yml.
    old_write = instance_method :write?
    define_method :write? do
      self.defaults['published'] != false
    end

    # Applies a similar URL-building technique as Jekyll::Document that takes
    # the collection's URL template into account. The default URL template can
    # be overriden in the collection's configuration in _config.yml.
    def url
      @url ||= @collection.nil? ? self.relative_path : ::Jekyll::URL.new({
        template:  @collection.url_template,
        placeholders: {
          collection: @collection.label,
          path: self.relative_path[
            @collection.relative_directory.size..self.relative_path.size],
        },
      }).to_s
    end

    # Returns the type of the collection if present, nil otherwise.
    def type
      @type ||= @collection.nil? ? nil : @collection.label.to_sym
    end

    # Returns the front matter defaults defined for the file's URL and/or type
    # as defined in _config.yml.
    def defaults
      @defaults ||= @site.frontmatter_defaults.all self.url, self.type
    end
  end
end
