# 18F Hub - Docs & connections between team members, projects, and skill sets
#
# Written in 2015 by Mike Bland (michael.bland@gsa.gov)
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

require 'liquid'

module Hub

  # Contains Hub-specific Liquid tags.
  class EditLinkTag < Liquid::Tag
    # Pass page.edit_info into this filter to produce the "Edit this page »"
    # link.
    def render(context)
      page = context['page'] || {}
      edit_info = page['edit_info']
      return '' unless edit_info

      path = page['path']
      site = context['site']
      prefix = edit_info['prefix']

      if prefix and path.start_with? prefix
        path = path[prefix.length..-1]
      end

      return "<a href=\"#{site['editor_url']}#{edit_info['repo']}/edit/" +
        "#{edit_info['branch']}/#{path}\">Edit this page »</a>"
    end
  end
end

Liquid::Template.register_tag('edit_link', Hub::EditLinkTag)
