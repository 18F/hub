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
  class Team
    def self.generate_pages(site)
      ::TeamHub::Page.generate_collection_item_pages(site, 'team',
        'team_member', 'full_name')
      team = site.data['team'] || {}
      team.each_value {|i| generate_team_member_snippets_page(site, i)}
      generate_team_member_index_page(site)
    end

    def self.generate_team_member_snippets_page(site, team_member)
      if team_member.member? 'snippets'
        page = ::TeamHub::Page.generate(site, File.join('snippets',
          team_member['name']), 'index.html', 'team_member_snippets.html',
          "#{team_member['full_name']} - Snippets")
        page.data['member'] = team_member
      end
    end

    def self.generate_team_member_index_page(site)
      page = ::TeamHub::Page.generate(site, 'team', 'index.html',
        'team_index.html', 'Team')
      team_members = site.data['team'].values
      page.data['members'] = Canonicalizer.sort_by_last_name! team_members
    end
  end
end
