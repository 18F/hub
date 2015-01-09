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
  class Departments
    def self.generate_pages(site)
      return unless site.data.member? 'departments'
      departments = site.data['departments']
      departments.each {|dept| generate_department_page(site, dept)}
    end

    def self.generate_department_page(site, department)
      canonicalized_name = Canonicalizer.canonicalize(department['name'])
      page = Page.new(site, File.join('departments', canonicalized_name),
        'index.html', 'department.html', department['name'])
      page.data['department'] = department
      site.pages << page
    end
  end
end
