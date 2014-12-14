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
