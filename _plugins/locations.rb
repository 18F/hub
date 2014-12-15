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
