module Hub
  class Skills
    def self.generate_pages(site)
      return unless site.data.member? 'skills'
      site.data['skills'].each do |category, category_xref|
        generate_skills_pages(site, category, category_xref)
      end
    end

    def self.generate_skills_pages(site, category, category_xref)
      category_xref.each do |skill, members|
        generate_skills_page(site, category, skill, members)
      end
      generate_skills_index_page(site, category, category_xref)
    end

    def self.generate_skills_page(site, category, skill, team_members)
      dir = File.join(Canonicalizer.canonicalize(category),
        Canonicalizer.canonicalize(skill))
      page = Page.new(site, dir, 'index.html', 'skills.html',
        "#{category}: #{skill}")
      page.data['category'] = category
      page.data['skill_name'] = skill
      page.data['members'] = team_members
      site.pages << page
    end

    def self.generate_skills_index_page(site, category, category_xref)
      page = Page.new(site, Canonicalizer.canonicalize(category),
        'index.html', 'skills_index.html', category)
      page.data['category'] = category
      page.data['skills'] = category_xref.to_a.sort!
      site.pages << page
    end
  end
end
