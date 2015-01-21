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

require 'team_hub/page'

module Hub
  class Skills
    def self.generate_pages(site)
      skills = site.data['skills'] || {}
      skills.each do |category, category_xref|
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
      page = ::TeamHub::Page.generate(site, dir, 'index.html', 'skills.html',
        "#{category}: #{skill}")
      page.data['category'] = category
      page.data['skill_name'] = skill
      page.data['members'] = team_members
    end

    def self.generate_skills_index_page(site, category, category_xref)
      page = ::TeamHub::Page.generate(site,
        Canonicalizer.canonicalize(category), 'index.html',
        'skills_index.html', category)
      page.data['category'] = category
      page.data['skills'] = category_xref.to_a.sort!
    end
  end
end
