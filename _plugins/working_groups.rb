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
  class WorkingGroups
    def self.generate_pages(site)
      return unless site.data.member? 'working_groups'
      working_groups = site.data['working_groups']
      working_groups.each {|wg| generate_working_group_page(site, wg)}
    end

    def self.generate_working_group_page(site, working_group)
      wg_name = working_group['name']
      canonicalized_name = Canonicalizer.canonicalize(wg_name)
      page = Page.new(site, File.join('wg', canonicalized_name), 'index.html',
        'working_group.html', "#{wg_name} Working Group")
      page.data['working_group'] = working_group
      site.pages << page
    end
  end
end
