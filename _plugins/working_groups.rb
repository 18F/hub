module Hub
  class WorkingGroups
    def self.generate_pages(site)
      return unless site.data.member? 'working_groups'
      working_groups = site.data['working_groups']
      working_groups.each {|wg| generate_working_group_page(site, wg)}
      generate_working_group_index_page(site, working_groups)
    end

    def self.generate_working_group_page(site, working_group)
      wg_name = working_group['name']
      canonicalized_name = Canonicalizer.canonicalize(wg_name)
      page = Page.new(site, File.join('wg', canonicalized_name), 'index.html',
        'working_group.html', "#{wg_name} Working Group")
      page.data['working_group'] = working_group
      site.pages << page
    end

    def self.generate_working_group_index_page(site, working_groups)
      page = Page.new(site, 'wg', 'index.html', 'working_groups_index.html',
      'Working Groups')
      page.data['working_groups'] = working_groups
      site.pages << page
    end
  end
end
