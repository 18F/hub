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

  # Builds cross-references between data sets.
  class CrossReferencer
    # Build cross-references between data sets.
    # +site_data+:: Jekyll +site.data+ object
    def self.build_xrefs(site_data)
      impl = ::TeamHub::CrossReferencerImpl.new site_data
      impl.xref_projects_and_team_members
      impl.xref_groups_and_team_members 'working_groups', ['leads', 'members']
      impl.xref_snippets_and_team_members
      impl.xref_skills_and_team_members(['Skills', 'Interests'])
      impl.xref_locations
    end
  end
end
