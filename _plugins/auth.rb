module Hub
  # Generates artifacts used by authenticated login features.
  class Auth

    # Generate authentication artifacts unless +site.config[+'public'] is
    # true.
    # +site+:: Jekyll site object
    def self.generate_artifacts(site)
      return if site.config['public']
      team = site.data['team'].values.select {|i| i.member? 'email'}
      return if team.empty?
      team.each {|i| generate_team_authentication_include(site, i)}
      generate_hub_authenticated_emails(site, team)
    end

    # Generates the upper-right-corner divs used to identify the authenticated
    # user. The divs are imported via a Server Side Include directive in
    # _layouts/bare.html.
    # +site+:: Jekyll site object
    # +member+:: team member hash
    def self.generate_team_authentication_include(site, member)
      username = member['email'].sub(/@.+$/, '')
      page = Page.new(site, File.join('auth', username), 'index.html',
        'team_member_auth_include.html',
        "#{member['full_name']} Authentication Include")
      page.data['member'] = member
      site.pages << page
    end

    # Generates the list of email addresses permitted to access the Hub after
    # passing through the google_auth_proxy. See deploy/README.md for details.
    # +site+:: Jekyll site object
    # +team+:: array of team member hashes
    def self.generate_hub_authenticated_emails(site, team)
      page = Page.new(site, 'auth', 'hub-authenticated-emails.txt',
        'hub-authenticated-emails.txt', 'Authenticated Emails')
      page.data['addrs'] = team.map {|i| i['email']}.sort!
      site.pages << page
    end
  end
end
