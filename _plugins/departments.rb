module Hub
  class Departments
    def self.generate_pages(site)
      return unless site.data.member? 'departments'
      departments = site.data['departments']
      departments.each {|dept| generate_department_page(site, dept)}
      generate_department_index_page(site, departments)
    end

    def self.generate_department_page(site, department)
      canonicalized_name = Canonicalizer.canonicalize(department['name'])
      page = Page.new(site, File.join('departments', canonicalized_name),
        'index.html', 'department.html', department['name'])
      page.data['department'] = department
      site.pages << page
    end

    def self.generate_department_index_page(site, departments)
      page = Page.new(site, 'departments', 'index.html',
        'department_index.html', 'Departments')
      page.data['departments'] = departments
      site.pages << page
    end
  end
end
