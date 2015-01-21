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
  class WorkingGroups
    def self.generate_pages(site)
      ::TeamHub::Page.generate_collection_item_pages(site, 'working_groups',
        'working_group', 'name', primary_key: 'name',
        collection_dir: 'wg', title_format: '%s Working Group')
    end
  end
end
