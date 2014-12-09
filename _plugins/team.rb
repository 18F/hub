module Hub
  class Team
    def self.generate_pages(site)
      return unless site.data.member? 'team'
      site.data['team'].each do |unused_k, member|
        generate_team_member_page(site, member)
        generate_team_member_snippets_page(site, member)
      end
      generate_team_member_index_page(site)
    end

    def self.generate_team_member_page(site, team_member)
      page = Page.new(site, File.join('team', team_member['name']),
        'index.html', 'team_member.html', team_member['full_name'])
      page.data['member'] = team_member
      site.pages << page
    end

    def self.generate_team_member_snippets_page(site, team_member)
      if team_member.member? 'snippets'
        page = Page.new(site, File.join('snippets', team_member['name']),
          'index.html', 'team_member_snippets.html',
          "#{team_member['full_name']} - Snippets")
        page.data['member'] = team_member
        site.pages << page
      end
    end

    def self.generate_team_member_index_page(site)
      page = Page.new(site, 'team', 'index.html', 'team_index.html', 'Team')
      team_members = site.data['team'].values
      page.data['members'] = Canonicalizer.sort_by_last_name! team_members
      site.pages << page
    end
  end
end
