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
  class Projects
    def self.generate_pages(site)
      return unless site.data.member? 'projects'
      projects = site.data['projects']
      projects.each {|project| generate_project_page(site, project)}
    end

    def self.generate_project_page(site, project)
      page = Page.new(site, File.join('projects', project['name']),
        'index.html', 'project.html', project['project'])
      page.data['project'] = project
      site.pages << page
    end
  end
end
