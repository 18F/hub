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

require 'weekly_snippets/publisher'

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
      publisher = ::WeeklySnippets::Publisher.new(
        headline: HEADLINE, public_mode: site.config['public'],
        markdown_snippet_munger: MARKDOWN_SNIPPET_MUNGER)
      site.data['snippets'] = publisher.publish site.data['snippets']
    end

    def self.generate_pages(site)
      snippets = site.data['snippets'].each || {}
      snippets.each do |timestamp, snippets|
        page = Page.generate(site, 'snippets', "#{timestamp}.html",
          "snippets.html",
          "Snippets for #{Canonicalizer.hyphenate_yyyymmdd(timestamp)}")
        page.data['snippets'] = snippets
      end
    end
  end
end
