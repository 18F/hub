require 'uglifier'

module Hub
  # Compresses any Javascript and CSS files that can't be automatically
  # compressed using the jekyll-assets plugin.
  #
  # Effectively, this applies only to assets/js/main.js, which is
  # asynchronously loaded by require.js and itself contains references to
  # other scripts compiled by jekyll-assets. Hence, main.js contains Liquid
  # tags from jekyll-assets and must processed as a normal Jekyll page _after_
  # jekyll-assets has compressed all the other files and generated their
  # cache-busting names (containing the MD5 sum of the content).
  class Compressor
    def self.compress(site)
      site.pages.each do |p|
        if p.name == 'main.js'
          p.content = ::Uglifier.compile p.content
          break
        end
      end
    end
  end
end
