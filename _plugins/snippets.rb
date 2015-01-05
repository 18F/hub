require_relative 'snippets_publisher'

module Hub
  class Snippets
    # Used to convert snippet headline markers to h4, since the layout uses
    # h3.
    HEADLINE = "\n####"

    MARKDOWN_SNIPPET_MUNGER = Proc.new do |text|
      text.gsub!(/^::: (.*) :::$/, "#{HEADLINE} \\1") # For jtag. ;-)
      text.gsub!(/^\*\*\*/, HEADLINE) # For elaine. ;-)
    end

    def self.publish(site)
      publisher = ::Snippets::Publisher.new(
        headline: HEADLINE, public_mode: site.config['public'],
        markdown_snippet_munger: MARKDOWN_SNIPPET_MUNGER)
      site.data['snippets'] = publisher.publish site.data['snippets']
    end

    def self.generate_pages(site)
      return unless site.data.member? 'snippets'
      site.data['snippets'].each do |timestamp, snippets|
        generate_snippets_page(site, timestamp, snippets)
      end
    end

    def self.generate_snippets_page(site, timestamp, snippets)
      page = Page.new(site, 'snippets', "#{timestamp}.html",
        "snippets.html",
        "Snippets for #{Canonicalizer.hyphenate_yyyymmdd(timestamp)}")
      page.data['snippets'] = snippets
      site.pages << page
    end
  end
end
