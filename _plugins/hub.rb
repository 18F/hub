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

# Jekyll plugins for the 18F Hub (https://hub.18f.us)
#
# The Hub::Generator class contains the logic for all Hub-specific data
# processing and page generation.

require 'hash-joiner'
require 'team_hub'

module Hub

  # Processes site data, generates authorization artifacts, publishes an API,
  # and generates cross-linked Hub pages.
  class Generator < ::Jekyll::Generator
    safe true

    # Executes all of the data processing and artifact/page generation phases
    # for the Hub.
    def generate(site)
      Joiner.join_data(site)
      Snippets.publish(site)
      CrossReferencer.build_xrefs(site.data)
      Canonicalizer.canonicalize_data(site.data)
      Auth.generate_artifacts(site)
      ::HashJoiner.prune_empty_properties(site.data)
      ::TeamHub::PrivateAssets.copy_to_site(site)
      Generator.copy_files site, site.config['private_pages_path'], 'assets'
      Api.generate_api(site)

      Team.generate_pages(site)
      Projects.generate_pages(site)
      Departments.generate_pages(site)
      WorkingGroups.generate_pages(site)
      Snippets.generate_pages(site)
      Skills.generate_pages(site)
    end

    def self.copy_files(site, relative_root_path, dir_to_copy)
      abs_dir_to_copy_path = File.join(site.source, relative_root_path,
        dir_to_copy)
      begin_path = abs_dir_to_copy_path.size + File::SEPARATOR.size
      Dir[File.join(abs_dir_to_copy_path, '**', '*')].each do |filename|
        next unless File.file? filename
        site.static_files << ::Jekyll::StaticFile.new(
          site, relative_root_path, dir_to_copy, filename[begin_path..-1])
      end
    end
  end
end
