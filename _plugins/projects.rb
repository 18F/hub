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
