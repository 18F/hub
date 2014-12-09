module Hub
  class Projects
    def self.generate_pages(site)
      return unless site.data.member? 'projects'
      projects = site.data['projects']
      projects.each {|project| generate_project_page(site, project)}
      generate_project_index_page(site, projects)
    end

    def self.generate_project_page(site, project)
      page = Page.new(site, File.join('projects', project['name']),
        'index.html', 'project.html', project['project'])
      page.data['project'] = project
      site.pages << page
    end

    def self.generate_project_index_page(site, projects)
      page = Page.new(site, 'projects', 'index.html', 'project_index.html',
        'Projects')
      page.data['projects'] = projects
      site.pages << page
    end
  end
end
