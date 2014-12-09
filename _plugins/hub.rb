# Jekyll plugins for the 18F Hub (https://hub.18f.us)
#
# The Hub::Generator class contains the logic for all Hub-specific data
# processing and page generation.
module Hub

  # Processes site data, generates authorization artifacts, publishes an API,
  # and generates cross-linked Hub pages.
  class Generator < ::Jekyll::Generator
    safe true

    # Executes all of the data processing and artifact/page generation phases
    # for the Hub.
    def generate(site)
      Joiner.join_data(site)
      CrossReferencer.build_xrefs(site.data)
      Canonicalizer.canonicalize_data(site.data)
      PrivateAssets.copy_to_site(site)
      Auth.generate_artifacts(site)
      Api.generate_api(site)

      Team.generate_pages(site)
      Locations.generate_pages(site)
      Projects.generate_pages(site)
      Departments.generate_pages(site)
      WorkingGroups.generate_pages(site)
      Snippets.generate_pages(site)
      Skills.generate_pages(site)
    end
  end
end
