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
  class Locations
    def self.generate_pages(site)
      return unless site.data.member? 'locations'
      locations = site.data['locations']
      locations.each {|l| generate_location_page(site, l)}
    end

    def self.generate_location_page(site, location)
      location_code = location[0]
      page = Page.new(site, File.join('locations', location_code),
        'index.html', 'location.html', location_code)
      page.data['location'] = location_code
      page.data['members'] = location[1]
      site.pages << page
    end
  end
end
